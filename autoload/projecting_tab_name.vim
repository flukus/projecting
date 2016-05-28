
fun! projecting_tab_name#activated()

	call projecting#debug('projecting_tab_name#activated')
	if exists('b:project')
		if exists('b:ext_tab_name.name')
			let t:ext_tab_name = b:project.ext_tab_name.name
		else
			let t:ext_tab_name = b:project.name
		endif
	endif

endf

fun! projecting_tab_name#deactivated()
endf

"set tab label to project dir
fun! projecting_tab_name#getName()
	"if the tab name is overwritten then use that
	if exists('t:ext_tab_name_override')
		return t:ext_tab_name_override
	endif

	if exists('t:ext_tab_name')
		return t:ext_tab_name
	endif

	if exists('b:project.name')
		return b:project.name
	endif

		"default to the file name
	return expand('%:t')
endf

fun! projecting_tab_name#setTabName(name)
	if a:name == '' 
		if exists('t:ext_tab_name_override')
			unlet t:ext_tab_name_override
		endif
	else
		let t:ext_tab_name_override = a:name
	endif
endf

command! -n=? -complete=dir -bar RenameTab call projecting_tab_name#setTabName(<q-args>)


