# Projecting

Projecting is an simple, fast and extendable project switcher and project configuration manager for vim.
It aims to be the glue between your projects, vim settings and various plugins.

It comes with the following features:

* Quick and simple project switching
* Sets working directory to the project root
* Easy configuration in pure vim script
* Support for nested/child projects
* A number of built in extensions for popular plugins
* Easy to extend

## Mappings

Projecting doesn't come with any mappings out of the box, believing that this is something best left to the user.
However here are some suggested mapping to put in your vimrc:

```vim
nmap <Leader>pp :ProjectLoad "note the trailing space, project load can auto complete
nmap <Leader>pd :DBSwitch "this is how you switch databases with the dbext extension
nmap <leader>pm :call projecting_make#make()<CR> "call the default make option of the make extensions
```

## Installation

If you're using pathogen:

```
git submodule add https://github.com/flukus/projecting.git bundle/dbext
```


## Configuration

Setting up a project is easy,
just tell projecting it's name, location and an optional default file to open.
Here is a project for your vimfiles:


```vim
call projecting#create({
	\'name': 'vimfiles',
	\'dir': 'c:\\Users\\username\\vimfiles\\',
	\'defaultFile': 'vimrc',
\})
```

Calling ":ProjectLoad vimfiles" will switch the working directory to the project and load the vimrc file.
Then it will set any extension settings.
Alternatively, opening any file in the project will apply the same settings.

This can be in your vimrc, although it's recommended to go in a project file like "~/vimfiles/projects/vimfiles.vim .
It's up to you to source the file in your vimrc.

Extensions are setup in the same place and configured with "ext\_" properties.
Here is the same project configuring ctrlp to ignore the bundles directory(more on extensions below):

```vim
call projecting#create({
	\'name': 'vimfiles',
	\'dir': 'c:\\Users\\username\\vimfiles\\',
	\'defaultFile': 'vimrc',
	\'ext_ctrlp': {'ignoreDir': 'bundle'},
\})
```

Because it is just a normal vim file any code can go in here.
To make reloading and configuring easier it is recommended to add auto reloading (projecting will play nice):

```vim
augroup vimfilesGroup " {
	autocmd!
	au BufWritePost *.vim source % "Autoreload vim files
augroup END " }
```

Child projects can be configured just by setting the parent name, projecting will handle the rest.
Here is how projecting itself is configured in my vimfiles:

```vim
call projecting#create({
	\'name': 'projecting',
	\'dir': 'c:\\Users\\username\\vimfiles\\projecting\\',
	\'parent': 'vimfiles',
	\'defaultFile': 'autoload\projecting.vim',
\})
```

Finally, projecting has hooks that your projects can use.
My vimfiles project for example, has a command to add new projects:

```vim
function! vimfiles#onActivate()
	"add the command
	command! -nargs=1 AddProject call vimfiles#AddProject(<f-args>)
endfunction

function! vimfiles#onDeactivate()
	"delete the command
	delc AddProject
endfunction

function! vimfiles#AddProject(name)
	"create a new file
	exec 'e projects/' . a:name . '.vim'
	call append(line('$'), "project")
	normal! G$
	"trigger snipmate
	call feedkeys("A\<Tab>")
endfunction
```

This way, the command is only available as long as the project is active.


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

This can be invoked with the commands:

```vim
"call the default target
:Make<CR>
"call a custom target/targets (supports auto complete)
:Make test
```


### Ctrlp

[Ctrlp](https://github.com/kien/ctrlp.vim) is great, but it often includes a bunch of files I don't care about.
When I'm modifying my vimfiles I don't care about the bundles dir, so I simply add it to the ignored directories:

```vim
call projecting#create({
	\'name': 'vimfiles',
	\'dir': 'c:\\Users\\username\\vimfiles\\',
	\'defaultFile': 'vimrc',
	\'ext_ctrlp': {'ignoreDir': 'bundle'},
\})
```

The other option is ignoreFile, both should be a regex of which files you'd like ctrlp to ignore.
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

[Dbext](https://github.com/vim-scripts/dbext.vim) is a great plugin for working with databases.
The extensions makes it easy to switch database connections on a per project basis:

```vim
\'ext_dbe': { 'databases': [
	\{ 'name': 'test1', 'default': 1, 'connection': 'extra= -w 50000 -s ^|:type=ASE:user=mbosa:passwd=pwd:srvname=localhost:dbname=test:port=5000' },
	\{ 'name': 'staging', 'connection': 'extra= -w 50000 -s ^|:type=ASE:user=username:passwd=pwd:srvname=localhost:dbname=test:port=5000' },
]}
```

The default connection will be loaded when the project is and can be switched with the ":DBSwitch" command.


## Custom extensions

Custom extensions are built with hooks similar to the project ones. There is an activated and deactivated hook:

```vim
function! myplugin#activated()
	"get the settings for my plugin
	let settings = b:project.ext_myplugin
	"set a project variable
	let b:project._myplugin = {}
	let b:project._myplugin.foo = 'bar'
endfunction

function! myplugin#deactivated()
endfunction
```

