augroup projecting_make_async " {
	au BufWritePost * call projecting_make_async#Auto()
augroup END "

function! projecting_make_async#activated()

endfunction

function! projecting_make_async#deactivated()
endfunction


function! projecting_make_async#Auto()
	call projecting#debug('projecting_make_async#Auto')
	if !exists('b:project') || !exists('b:project.ext_make.makeAuto') || b:project.ext_make.makeAuto == 0
		return
	endif
	call projecting_make_async#Build()
endfunction

function! OutHandler(job, message)
endfunction

function! projecting_make_async#Build(...)
	call projecting#debug('projecting_make_async#Build')
	if !exists('b:project')
		return
		call projecting#debug('no project, skipping build')
	endif

	if exists('b:project.vars.building') &&b:project.vars.building == 1
		call projecting#debug('already building, queueing new build')
		let b:project.vars.queueBuild = 1
		return
	endif
	let b:project.vars.building = 1

	if !exists('b:project.vars.makeBufNum')
		call projecting#debug('create make buffer')
		let currentBuf = bufnr('%')
		new
		set ro
		let makeBufNum = bufnr('%')
		exec currentBuf 'b'
		let b:project.vars.makeBufNum = makeBufNum
		call projecting#debug('make buffer is"' . b:project.vars.makeBufNum)
	endif

	let currentBuf = bufnr('%')
	let makeBufNum = b:project.vars.makeBufNum
	exec makeBufNum . 'b'
	%d
	exec currentBuf 'b'

	let b:project.errorCount = '*'
	exec "AirlineRefresh"

	let target = exists('b:project.ext_make.default') ? b:project.ext_make.default : ''
	if a:0 > 0
		let target = join(a:000, " ")
	endif


	let cmd = b:project.ext_make.prg . ' ' . target
	call projecting#debug(cmd)
	let job = job_start(cmd, {'out_io': 'buffer', 'out_buf': b:project.vars.makeBufNum, 'out_cb': 'OutHandler', 'err_io': 'buffer', 'err_buf': b:project.vars.makeBufNum, 'exit_cb': 'projecting_make_async#ExitHandler'})
	"let job.project = b:project

endfunction

function! projecting_make_async#ExitHandler(job, status)
	call projecting#debug('projecting_make_async#ExitHandler')
	let b:project.vars.building = 0
	"set the error format
	if exists('b:project.ext_make.efm')
		let &efm = b:project.ext_make.efm
	elseif exists('b:project.ext_make.efmFunc')
		exec 'call ' . b:project.ext_make.efmFunc . '()'
	endif

	"load the errors from the make buffer
	exec 'cgetb ' . b:project.vars.makeBufNum

	"set the error count for display in airline
	"let list = getqflist()
	"let ecount = 0
	"for i in list
		"if i.type == "E"
			"let ecount+=1
		"endif
	"endfor
	"let b:project.errorCount = ecount
	"exec "AirlineRefresh"

	if exists('b:project.vars.queueBuild') && b:project.vars.queueBuild == 1
		let b:project.vars.queueBuild = 0
		call projecting_make_async#Build()
	endif

endfunction

