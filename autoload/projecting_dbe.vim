
function! projecting_dbe#activated()
	if !exists('b:project.ext_dbe')
		return
	endif

	if !exists('b:project.ext_dbe.databases')
		let b:project.ext_dbe.databases = [ ]
	endif

	if !exists('b:project._dbe')
		let b:project._dbe = { }
	endif

	command! -nargs=1 -complete=customlist,projecting_dbe#switchComplete DBSwitch call projecting_dbe#switch(<f-args>)

	if exists('b:project._dbe.lastConnection')
		call projecting_dbe#setConnection(b:project._dbe.lastConnection)
		return
	endif

	for db in b:project.ext_dbe.databases
		if get(db, 'default') == 1
			call projecting_dbe#setConnection(db.connection)
			return
		endif
	endfor
	"otherwise disconnect
	call projecting_dbe#deActivate()
endfunction

function! projecting_dbe#deactivated()
	exec 'DBDisconnect'
	if exists(':DBSwitch')
		delc DBSwitch
	endif
endfunction

function! projecting_dbe#setConnection(connection)
	let b:project._dbe.lastConnection = a:connection
	exec 'DBSetOption ""'
	exec 'DBSetOption ' . a:connection
endfunction

function! projecting_dbe#switch(name)
	for db in b:project.ext_dbe.databases
		if a:name == db.name
			call projecting_dbe#setConnection(db.connection)
			return
		endif
	endfor
endfunction

function! projecting_dbe#switchComplete(ArgLead, CmdLine, CursorPos)
	let results = []
	for x in b:project.ext_dbe.databases
		let isMatch = x.name =~? a:ArgLead
		if isMatch
			let results += [x.name]
		endif
	endfor
	call sort(results)
	return results

endfunction


