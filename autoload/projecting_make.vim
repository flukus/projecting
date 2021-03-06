
if !exists('g:projecting_make#makeAsync')
	let g:projecting_make#makeAsync = 0
endif
function! projecting_make#async(arg)
	let g:projecting_make#makeAsync = a:arg
endfunction

function! projecting_make#activated()
	if g:projecting_make#makeAsync == 1
		call projecting_make_async#activated()
	endif
	command! -n=* -complete=customlist,projecting_make#makeComplete Make call projecting_make#make(<f-args>)
	command! -n=0 MakeReset call projecting_make#MakeReset()
endfunction

function! projecting_make#deactivated()
	if g:projecting_make#makeAsync == 1
		call projecting_make_async#deactivated()
	endif
	if exists(':Make')
		delc Make
		delc MakeReset
	endif
endfunction

function! projecting_make#make(...)
	if g:projecting_make#makeAsync == 1
		"call projecting_make_async#Build(a:000)
		call call('projecting_make_async#Build', a:000)
		return
	endif
	if !exists('b:project')
		return
	endif
	let ext = b:project.ext_make
	let target = exists('ext.default') ? ext.default : ''
	if a:0 > 0
		let target = join(a:000, " ")
	endif

	if exists('ext.efm')
		let &efm = ext.efm
	elseif exists('ext.efmFunc')
		exec 'let &efm = call' . ext.efmFunc . '()'
	endif

	let &makeprg = ext.prg
	let myMake = ':make! ' . target
	echom myMake
	exec myMake
endfunction

function! projecting_make#makeComplete(arg, line, pos)
	if !exists('b:project.ext_make.options') 
		return []
	endif
	let results = []
	for x in b:project.ext_make.options
		let isMatch = x =~? a:arg
		if isMatch
			let results += [x]
		endif
	endfor
	call sort(results)
	return results
endfunction

fun! projecting_make#MakeReset()
	let b:project.vars.building = 0
	let b:project.vars.queueBuild = 0
endf!
