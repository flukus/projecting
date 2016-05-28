echom 'loadinng autoload/make'
augroup projecting_make_async " {
	au BufWritePost * call projecting_make_async#Auto()
augroup END "

"just to trigger lazy load
function! projecting_make_async#activated()
endfunction

function! projecting_make_async#deactivated()
endfunction


function! projecting_make_async#Auto()
	if !exists('b:project') || !exists('b:project.makeAuto') || b:project.makeAuto == 0
		return
	endif
	call projecting_make_async#Build()
endfunction

function! OutHandler(job, message)
endfunction

function! projecting_make_async#Build(...)
	if !exists('b:project')
		return
	endif

	if b:project.vars.building == 1
		let b:project.vars.queueBuild = 1
		return
	endif
	let b:project.vars.building = 1

	let b:project.errorCount = '*'
	exec "AirlineRefresh"

	let target = exists('b:project.makeDefault') ? b:project.makeDefault : ''
	if a:0 > 0
		let target = join(a:000, " ")
	endif

	let currentBuf = bufnr('%')
	let makeBufNum = bufnr('make_buffer', 1)
	let b:project.vars.makeBufNum = makeBufNum
	exec makeBufNum . 'bufdo %d'
	exec 'b ' . currentBuf

	let cmd = b:project.makePrg . ' ' . target
	let job = job_start(cmd, {'out_io': 'buffer', 'out_name': 'make_buffer', 'out_cb': 'OutHandler', 'exit_cb': 'projecting_make_async#ExitHandler'})
	"let job.project = b:project

endfunction

function! projecting_make_async#MakeComplete(arg, line, pos)
	return exists('b:project.makeOptions') ? b:project.makeOptions : []
endfunction
command! -n=* -complete=customlist,projecting_make_async#MakeComplete ProjectMake call projecting_make_async#Build(<f-args>)

function! projecting_make_async#ExitHandler(job, status)
	let b:project.vars.building = 0
	"set the error format
	if exists('b:project.efm')
		let &efm = b:project.efm
	elseif exists('b:project.efmFunc')
		exec 'call ' . b:project.efmFunc . '()'
	endif

	"load the errors from the make buffer
	exec 'silent! cb! ' . b:project.vars.makeBufNum

	"set the error count for display in airline
	let list = getqflist()
	let ecount = 0
	for i in list
		if i.type == "E"
			let ecount+=1
		endif
	endfor
	let b:project.errorCount = ecount
	exec "AirlineRefresh"

	if b:project.vars.queueBuild == 1
		let b:project.vars.queueBuild = 0
		call projecting_make_async#Build()
	endif

endfunction

