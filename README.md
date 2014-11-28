Project.vim
===========


Project.vim introduces support for projects and solutions in the
sense that the most IDE's do. This makes it easy to build only the
relevant parts of a source tree. This is done simply by adding some
small vim specific configuration files in your source tree. Those files
contain information which when combined creates a shell command which
builds the project. This means that Project.vim is not a build system
but in turn it relies on a build system that your project uses.

Consider this simple source tree where CMake is used and the build
directory is used for the build process

		projDemo
		|   main.cpp
		|   root.vim
		|   CMakeLists.txt
		|
		+---build
		\---mylibrary
						CMakeLists.txt
						mylibrary.cpp
						mylibrary.h
						libtest.cpp
						project.vim


The contents of the `root.vim` would be:

		let g:root_build_exe = "\"C:/Program Files (x86)/MSBuild/12.0/Bin/msbuild.exe\""
		let g:root_build_opts = ""
		let g:root_project_rel_path = "build"
		let g:root_project_name = "projDemo.sln"
		let g:root_exe_name = "executable.exe"

While the contents of the `mylibrary/project.vim` would be:

		let g:project_build_exe = "\"C:/Program Files (x86)/MSBuild/12.0/Bin/msbuild.exe\""
		let g:project_build_opts = ""
		let g:project_project_rel_path = "build/mylibrary"
		let g:project_project_name = "mylibrary.vcxproj"
		let g:project_exe_name = "libtest.exe"

In order the build the project that the current file belongs to push
`<Leader>bp`
and in order to build the root project push
`<Leader>br`

License
========

This plugin is distributed under the vim license see `:help license`
