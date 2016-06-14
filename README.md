# Projecting

Projecting is an simple, fast and extensible project switcher for vim with the following features:


* Easy configuration in pure vim script
* Sets working directory for the current file
* Support for nested/child projects
* A number of built in extensions for popular plugins
* Easy to extend


## Configuration

Setting up a project is easy,
just tell projecting it's name, location and an optional default file to open.
Here is a project for your vimfiels


```vim
call projecting#create({
	\'name': 'vimfiles',
	\'dir': 'c:\\Users\\username\\vimfiles\\',
	\'defaultFile': 'vimrc',
\})
```

Calling ":ProjectLoad vimfiles" will switch the working directory to the project]and load the vimrc file.
Then it will set any extension settings.

Additionally, the project and settings will be set be opening a file in a configured project.

Generally it's a good idea to put each project in it's own source file, ie projects/vimfiles.vim

Extensions are setup in the same place.
Here is the same project configure ctrlp to ignore the bundles directory:

```vim
call projecting#create({
	\'name': 'vimfiles',
	\'dir': 'c:\\Users\\username\\vimfiles\\',
	\'defaultFile': 'vimrc',
	\'ext_ctrlp': {'ignoreDir': 'bundle'},
\})
```
More on the specific extensions below.

Child projects can be configured just by setting the parent name, projecting will handle the rest.
Here is how this project is configures in my vimfiles:

```vim
call projecting#create({
	\'name': 'projecting',
	\'dir': 'c:\\Users\\username\\vimfiles\\projecting\\',
	\'parent': 'vimfiles',
	\'defaultFile': 'autoload\projecting.vim',
\})
```

Additionally, projecting has hooks that your projects can use.
My vimfiles project for example, has a command to add new projects:

```vim
function! vimfiles#onActivate()
	command! -nargs=1 AddProject call VimfilesAddProject(<f-args>)
endfunction

function! vimfiles#onDeactivate()
	delc AddProject
endfunction
```

This way, the command is only available as long as the project is active.



## Mappings

Projecting doesn't come with any mappings out of the box, believing that this is something best left to the user.
However here are some suggested mapping to put in your vimrc:

```vim
nmap <Leader>pp :ProjectLoad "note the trailing space, project load can auto complete
nmap <Leader>pd :DBSwitch "this is how you switch databases with the dbext extension
nmap <leader>pm :call projecting_make#make()<CR> "call the default make option of the make extensions
```

## Plugins

The following lists the configuration options for plugins so far.

### Make

Make is a plugin to simplify using vims built in make command.
It takes a number of configuration options:

```vim
\'ext_make': {
		\'prg': 'nant.bat',
		\'default': 'test',
		\'options': ['build', 'test'],
		\'efm': g:efmNant,
\}
```

* prg is the program you want to invoke to build the project.
* options are the targets that can be called.
* default is the default target
* efm is the error format to parse the results with

This can be invoked with the command:

```vim
:Make
:Make test
```


### Ctrlp

Ctrlp is great, but it often includes a bunch of files I don't care about.
When I'm modifying my vimfiles I don't care about the bundles dir, so I simply add it to the ignored directories:

```vim
call projecting#create({
	\'name': 'vimfiles',
	\'dir': 'c:\\Users\\username\\vimfiles\\',
	\'defaultFile': 'vimrc',
	\'ext_ctrlp': {'ignoreDir': 'bundle'},
\})
```

The other options is ignoreFile, both should be a regex of which files you'd like ctrlp to ignore.
Some common ones are node modules, nuget packages and build output.


### Tab Names

This is an extension for those working with multiple projects in separate tabs.
Some additional setup is required, you will need to add this to your vimrc:

```vim
"let projecting manage the tab names
set guitablabel=%{projecting_tab_name#getName()}
```

This plugin will use the project name as the tab name.
If you'd like a different name you can set it with:

```vim
\'ext_tab_name': {'name': '~~~My Project~~~'},
```

Additionally you can override it manually:

```vim
:RenameTab new name
```


### DBext

The dbext plugin is for setting and selecting database configurations on a per project basis.
It is configured like this:

```vim
let s:databases = [
	\{ 'name': 'test1', 'default': 1, 'connection': 'extra= -w 50000 -s ^|:type=ASE:user=mbosa:passwd=pwd:srvname=localhost:dbname=test:port=5000' },
	\{ 'name': 'staging', 'connection': 'extra= -w 50000 -s ^|:type=ASE:user=mbosa:passwd=pwd:srvname=localhost:dbname=test:port=5000' },
]
```

The default connection will be loaded when the project first is and can be switched with the ":DBSwitch" command.


## Custom extensions

More to follow

