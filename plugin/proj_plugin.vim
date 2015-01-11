"A Vim global plugin for project and subproject support
"Last Change: 28 Nov 2014
"Maintainer: Aris Karagiannidis <arkaragian@gmail.com>
"
"Version : 0.2
"
"The script logic is quite simple. The folder that contains the file root.vim
"is the root folder of the project. This project may contain multiple
"subprojects in separate directories, however at any given directory there
"cannot be more than one projects.vim
"

if exists("g:loaded_project")
	finish
endif
let g:loaded_project = 1

let s:save_cpo = &cpo
set cpo&vim


"Checks if the given filename is inside the given directory
function! s:IsFileDir(dir,filename)
	let isDir = 0
	if filereadable( a:dir . "/". a:filename)
		let isDir = 1
	endif
	return isDir
endfunction

"Returns the directory that contains the root.vim or project.vim. Used to find
"the root and project files. Is starts from the current directory and moves
"upwards until it finds a directory containing the given filename or when the
"escape counter is met.
function! s:GetDirOfFileInTree(filename)
	let dir = getcwd()
	"Use a counter in order to break in case there is no root.vim found
	let counter = 1
	while s:IsFileDir(dir,a:filename) == 0 && counter < 20
		let dir = fnamemodify( dir , ':h') "Get the parent directory
		let counter += 1
	endwhile

	"If no file exists, then result will be "C:\ in windows
	"and / in UNIX systems(This really depends on the filesystem
	"and the value of the counter that is set. Either way for the
	"top level directory the length of the string will be 3 or less
	if strlen(dir) <= 3
		return getcwd()
		echom a:filename . " was not found in " .getcwd()
	else
		return dir
	endif
	echom "Refreshing Solution"
endfunction

"Use the above function to find the root
"and the project directory
function! GetRootDir()
	return s:GetDirOfFileInTree("root.vim")
endfunction

function! GetProjectDir()
	return s:GetDirOfFileInTree("project.vim")
endfunction


"This function builds a project. It accepts an argument
"either "root" or "proj" depending on what we want to build
"The build is done by constructing a shell command based on
"the information of the root.vim and project.vim files. This
"command is then executed on the shell
function! BuildProject(type)

	"Prefix of the variables that are to be used
	"conf_file the configuration file that contains the
	"variables
	let prefix = ""
	let conf_file   = ""

	if(a:type == "root")
		let prefix = "root_"
		let conf_file = "root.vim"	
	elseif (a:type == "proj")
		let prefix = "proj_"
		let conf_file = "project.vim"
	else
		echo "Error: No or invalid argument in the function"
		return
	endif


	try
		if(a:type == "root")
			:exec ":source " .g:root_dir. "/root.vim"
		elseif (a:type == "proj")
			:exec ":source " .g:proj_dir. "/project.vim"
		else
			echo "Error: No or invalid argument in the function"
			return
		endif
	catch
		echo "No root.vim/project.vim file found. Aborting execution"	
		return
	endtry

	"Builds the variable name according to the prefix
	"e.g    g:root_build_exe or
	"    g:project_build_exe
	if !exists("g:".prefix."build_exe")
		echo "No g:".prefix."build_exe variable exists check your ".conf_file
		return
	endif

	if !exists("g:".prefix."build_opts")
		echo "No g:".prefix."build_opts variable exists check your ".conf_file
		return
	endif

	if !exists("g:".prefix."build_dir_rel_path")
		echo "No g:".prefix."build_dir_rel_path variable exists check your ".conf_file
		return
	endif
	if !exists("g:".prefix."recipe_file")
		echo "No g:".prefix."recipe_file variable exists check your ".conf_file
		return
	endif
	if !exists("g:".prefix."build_arguments")
		echo "No g:".prefix."build_arguments variable exists check your ".conf_file
		return
	endif

	if(a:type == "root")
		echo "All variables set! Building Root project"
	elseif (a:type == "proj")
		echo "All variables set! Building Sub-project"
	endif

	"Those are global variables that are defined inside the root.vim
	"that we previously sourced


	if(a:type == "root")
		let project_path = g:root_dir."/".g:root_build_dir_rel_path."/".g:root_recipe_file." ".g:root_build_arguments
		execute("!".g:root_build_exe." ".g:root_build_opts." ".project_path)
	elseif (a:type == "proj")
		let project_path = g:root_dir."/".g:proj_build_dir_rel_path."/".g:proj_recipe_file." ".g:proj_build_arguments
		execute("!".g:proj_build_exe." ".g:proj_build_opts." ".project_path)
	else
		echo "Error: No or invalid argument in the function"
		return
	endif
endfunction

"Excute porject, same plilosophy as the previous function
"But here we need the exetutable location
"Options and arguments
function! ExecuteProject(type)

	"Prefix of the variables that are to be used
	"conf_file the configuration file that contains the
	"variables
	let prefix = ""
	let conf_file   = ""

	if(a:type == "root")
		let prefix = "root_"
		let conf_file = "root.vim"	
	elseif (a:type == "proj")
		let prefix = "proj_"
		let conf_file = "project.vim"
	else
		echo "Error: No or invalid argument in the function"
		return
	endif


	try
		if(a:type == "root")
			:exec ":source " .g:root_dir. "/root.vim"
		elseif (a:type == "proj")
			:exec ":source " .g:proj_dir. "/project.vim"
		else
			echo "Error: No or invalid argument in the function"
			return
		endif
	catch
		echo "No root.vim/project.vim file found. Aborting execution"	
		return
	endtry

	"Builds the variable name according to the prefix
	"e.g    g:root_build_exe or
	"    g:project_build_exe

	if !exists("g:".prefix."exe_dir_rel_path")
		echo "No g:".prefix."build_dir_rel_path variable exists check your ".conf_file
		return
	endif
	if !exists("g:".prefix."exe_name")
		echo "No g:".prefix."recipe_file variable exists check your ".conf_file
		return
	endif
	if !exists("g:".prefix."exe_args")
		echo "No g:".prefix."exe_arguments variable exists check your ".conf_file
		return
	endif

	if(a:type == "root")
		echo "All variables set! Executing Root project"
	elseif (a:type == "proj")
		echo "All variables set! Executing Sub-project"
	endif

	"Those are global variables that are defined inside the root.vim
	"that we previously sourced


	if(a:type == "root")
		let project_path = g:root_dir."/".g:root_exe_dir_rel_path."/".g:root_exe_name." ".g:root_exe_args
		execute("!".project_path)
	elseif (a:type == "proj")
		let project_path = g:root_dir."/".g:proj_exe_dir_rel_path."/".g:proj_exe_name." ".g:proj_exe_args
		execute("!".project_path)
	else
		echo "Error: No or invalid argument in the function"
		return
	endif
endfunction

let g:root_dir = GetRootDir()
let g:proj_dir = GetProjectDir()

"To Use this an autocommand
function! RefreshSolution()
	let g:root_dir = GetRootDir()
	let g:proj_dir = GetProjectDir()
endfunction


try
	:exec ":source " .g:root_dir. "/root.vim"
catch
endtry

try
	:exec ":source " .g:proj_dir. "/project.vim"
catch
endtry

if !exists('g:project_auto_load_conf_files')
	let g:project_auto_load_conf_files = 1
endif

if g:project_auto_load_conf_files
	"Automatically re-source root.vim and project.vim when we make changes to them
	autocmd! BufWritePost root.vim :source root.vim
	autocmd! BufWritePost project.vim :source project.vim

	"When I go to another file refresh the variables pointing to the root and
	"project folders. Also we may need to source those files also
	autocmd! BufNewFile,BufRead,BufEnter,TabEnter * :call RefreshSolution()
endif

"If the user has defined the project_map_keys variable, do not touch
"it and let the configutation begin with the user defined variable, else
"continue with the defualt settings
if !exists('g:project_map_keys')
	let g:project_map_keys = 1
endif

if g:project_map_keys
	"Open and edit the root file
	noremap <Leader>or :exec ":tabnew ".g:root_dir. "/root.vim"<cr>
	noremap <Leader>op :exec ":tabnew ".g:proj_dir. "/project.vim"<cr>
	noremap <Leader>br :call BuildProject("root")<cr>
	noremap <Leader>bp :call BuildProject("proj")<cr>
	noremap <Leader>er :call ExecuteProject("root")<cr>
endif


let &cpo = s:save_cpo
unlet s:save_cpo

