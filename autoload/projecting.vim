augroup projecting " {
	autocmd!
	au BufEnter * call projecting#autoLoad()
augroup END " }

if !exists('s:projects')
	let s:projects = { }
endif

if exists('s:currentProject')
	unlet s:currentProject
endif
if !exists('s:extensions')
	let s:extensions = { }
endif

function! projecting#create(project)
	call projecting#debug('Creating project')
	if !exists('s:projects.' . a:project.name)
		let s:projects[a:project.name] = { '_projects': {} }
	endif
	let l:p = s:projects[a:project.name]
	for kvp in items(a:project)
		let l:p[kvp[0]] = kvp[1]
	endfor

	if exists('l:p.parent')
		let parent = {}
		if exists('s:projects.' . l:p.parent)
			let parent = s:projects[l:p.parent]
		else
			let parent = p"rojecting#create({'name': l:p.parent})
		end
		"not nice, but better than the user doing it
		let parent._projects[l:p.name] = l:p
		let l:p._parent = l:p
	endif

	return l:p
endfunction

function! projecting#load(name)
	call projecting#debug('projecting#load(' . a:name . ')')
	if !has_key(s:projects, a:name)
		echoerr 'unknown project'
		return
	endif
	let project = s:projects[a:name]
	call projecting#debug('creating empty buffer')
	enew
	call projecting#initProject(project)
	if exists('project.defaultFile') && project.defaultFile != ''
		"this will autoload and set the project
		call projecting#debug('opening default file')
		exec 'e '. project.defaultFile
	else
		"no file so have to set the project
		call projecting#setCurrentProject(project)
	endif
endfunction

function! projecting#loadComplete(ArgLead, CmdLine, CursorPos)
	let results = []
	for x in  keys(s:projects)
		let isMatch = x =~? a:ArgLead
		if isMatch
			let results += [x]
		endif
	endfor
	call sort(results)
	return results
endfunction

function! projecting#autoLoad()
	call projecting#debug('projecting#autoLoad')
	let fname = expand('%:p')
	call projecting#debug('filename: ' . fname)
	if fname == '' && !exists('b:project')
		return
	endif
	if exists('b:project')
		call projecting#debug('project exists, setting as current')
		call projecting#setCurrentProject(b:project)
		return
	endif
	call projecting#debug('finding project for file')
	let l:project = projecting#findProject(fname, s:projects)
	if exists('l:project.name')
		call projecting#debug('project found: ' . l:project.name)
	else
		call projecting#debug('project not found')
	endif
	call projecting#initProject(l:project)
	call projecting#setCurrentProject(l:project)
	call projecting#debug('project set complete')
endfunction

function! projecting#findProject(dir, projects)
	call projecting#debug('projecting#findProject')
	for l:project in values(a:projects)
		let x = a:dir =~? l:project.dir
		if x == 1
			call projecting#debug('matched project: ' . l:project.name)
			let l:innerProject = projecting#findProject(a:dir, l:project._projects)
			if !empty(l:innerProject)
				return l:innerProject
			else
				return l:project
			endif
		endif
	endfor
	return { }
endfunction

fun! projecting#initProject(project)
	call projecting#debug('projecting#initProject')
	if empty(a:project)
		return
	endif
	let b:project = a:project
	let projdir = substitute(a:project.dir, '\\\\', '\\','g')
	exec 'lcd '. projdir
	if !exists('b:project.vars')
		let b:project.vars = { }
	endif
endf

function! projecting#setCurrentProject(project)
	call projecting#debug('projecting#setCurrentProject')
	"set a null project
	if exists('s:currentProject') && empty(a:project)
		call projecting#deactivateProject(s:currentProject)
		unlet s:currentProject
		return
	endif

	if empty(a:project)
		if empty('b:project')
			unlet b:project
		endif
		return
	endif

	if exists('s:currentProject') && s:currentProject.name == a:project.name
		return
	elseif exists('s:currentProject')
		call projecting#deactivateProject(s:currentProject)
	endif

	call projecting#activateProject(a:project)
	let s:currentProject = a:project
	
endfunction

function! projecting#activateProject(project)
	call projecting#debug('projecting#activateProject')
	if exists('*' . a:project.name . '#onActivate')
		exec 'call ' . a:project.name . '#onActivate()'
	endif

	for kvp in items(a:project)
		if kvp[0] =~ 'ext_'
			let extName = substitute(kvp[0], 'ext_', '', '')
			try
				call projecting#debug('actiating extension: ' . extName)
				exec 'call projecting_' . extName . '#activated()'
			catch
				echoerr 'unkown extension: ' . extName
			endtry
		endif
	endfor
endfunction

function! projecting#deactivateProject(project)
	call projecting#debug('projecting#deactivateProject')
	if exists('*' . a:project.name . '#onDeactivate')
		exec 'call ' . a:project.name . '#onDeactivate()'
	endif
	for kvp in items(a:project)
		if kvp[0] =~ 'ext_'
			let extName = substitute(kvp[0], 'ext_', '', '')
			call projecting#debug('deactiating extension: ' . extName)
			if exists('*projecting_' . extName . '#deactivated')
				exec 'call projecting_' . extName . '#deactivated()'
			endif
		endif
	endfor

endfunction

if !exists('s:debug')
	let s:debug = 0
endif
fun! projecting#debug(message)
	if s:debug == 1
		echom a:message
	endif
endf
command! -n=0 ProjectingSetDebug let s:debug = 1

