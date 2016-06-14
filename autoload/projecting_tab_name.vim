
fun! projecting_tab_name#activated()
endf

fun! projecting_tab_name#deactivated()
endf

"set tab label to project dir
fun! projecting_tab_name#getName()
	"if the tab name is overwritten then use that
	if exists('t:ext_tab_name_override')
		return t:ext_tab_name_override
	endif

	if exists('b:project')
		if exists('b:ext_tab_name.name')
			return  b:project.ext_tab_name.name
		else
			return  b:project.name
		endif
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


