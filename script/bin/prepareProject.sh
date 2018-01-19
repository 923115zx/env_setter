#!/bin/bash

# Cscope build.
absPath=`pwd`"/"
find $absPath -name "*.h" -o -name "*.c" -o -name "*.hpp" -o -name "*.cc" -o -name "*.C" -o -name "*.cpp" > cscope.files
cscope -bkq -i cscope.files
rm cscope.files

OS=`uname -s`

# Only parse c++ files. Add .c to c++ filetypes, and delete hpp out from c++ filetypes.
# The boost headers are all .hpp, so...you know it.
ctags_flags="--languages=c++ --c++-kinds=+px --langmap=c++:.c.cc.cp.cpp.cxx.h.h++.hh.hp.hxx.C.H
			-h -.hpp --fields=+aifKsSzl --extra=+q"

# For current project.
ctags -R $ctags_flags
# Add any lib in anywhere we want to build tags, specified in cmdline.
for arg in $@
do
	if [ $arg != $0 ]; then
		ctags -R --append=yes $ctags_flags $arg
	fi
done
# Build tags for system libs and std libs.
sys_include_dir=/usr/include #TODO: should get from sys env.
lib_tag_file=$HOME/.lib_tags

# Actually what we do here is also because boost....
if [ ! -f $lib_tag_file ]
then
	ctags -f $lib_tag_file $ctags_flags $sys_include_dir/*
	ctags -f $lib_tag_file --append=yes $ctags_flags $sys_include_dir/sys/*
#	if [ "$OS" != "Darwin" ]; then
#		ctags -f $lib_tag_file --append=yes $ctags_flags $sys_include_dir/linux/*
#		cpp_version=`g++ --version`
#		cppv_arr=($cpp_version)
#		ctags -f $lib_tag_file -R --append=yes $ctags_flags $sys_include_dir/c++/${cppv_arr[2]}/*
#	else
#		cppv_arr=(`ls $sys_include_dir/c++/`)
#		largeNr=$((${#cppv_arr[@]} - 1))
#		ctags -f $lib_tag_file -R --append=yes $ctags_flags $sys_include_dir/c++/${cppv_arr[$largeNr]}/*
#	fi
	cppv_arr=(`ls $sys_include_dir/c++/`)
	largeNr=$((${#cppv_arr[@]} - 1))
	ctags -f $lib_tag_file -R --append=yes $ctags_flags $sys_include_dir/c++/${cppv_arr[$largeNr]}/*

	ctags -f $lib_tag_file --append=yes $ctags_flags $sys_include_dir/arpa/*
	ctags -f $lib_tag_file --append=yes $ctags_flags $sys_include_dir/netinet/*
fi

# Copy ycm_extra_conf file to current project.
cp $HOME/.vim/.ycm_extra_conf.py ./
