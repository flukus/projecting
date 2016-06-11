# projecting

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

## Mappings

Projecting doesn't come with any mappings out of the box, believing that this is something best left to the user.
However here are some suggested mapping to put in your vimrc:

```vim
nmap <Leader>pp :ProjectLoad "not the trailing space, project load can auto complete
nmap <Leader>pd :DBSwitch "this is how you switch databases with the dbext extension
nmap <leader>pm :call projecting_make#make()<CR> "call the default make option of the make extensions
```

