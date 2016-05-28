
function! projecting_ctrlp#activated()
	let ignore = { 'dir': '' , 'file': '', 'link': ''}
	if exists('b:project.ext_ctrlp.ignoreDir')
		let ignore.dir = b:project.ext_ctrlp.ignoreDir 
	endif
	if exists('b:project.ext_ctrlp.ignoreFile')
		let ignore.dir = b:project.ext_ctrlp.ignoreFile 
	endif
	if exists('b:project.ext_ctrlp.ignoreLink')
		let ignore.dir = b:project.ext_ctrlp.ignoreLink 
	endif

	let g:ctrlp_custom_ignore = ignore
endfunction

function! projecting_ctrlp#deactivated()
	let g:ctrlp_custom_ignore = {}
endfunction


