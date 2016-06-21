
let g:snipMate = get(g:, 'snipMate', {}) " Allow for vimrc re-sourcing
fun! projecting_snipMate#activated()
	let settings = b:project.ext_snipMate
	echo settings.scope_aliases
	if exists('settings.scope_aliases')
		for k in keys(settings.scope_aliases)
			let g:snipMate.scope_aliases[k] = settings.scope_aliases[k]
		endfor
	endif
endf

fun! projecting_snipMate#deactivated()
	if exists('settings.scope_aliases')
		for k in keys(settings.scope_aliases)
			let g:snipMate.scope_aliases[k] = settings.scope_aliases[k]
		endfor
	endif
endf
