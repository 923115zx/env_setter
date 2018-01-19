########################################################################
#
#      FileName                    : common.sh
#      Author                      : Zhao Xin
#      CreateTime                  : 2017-09-18 03:43:31 PM
#      VIM                         : ts=4, sw=4
#      LastModified                : 2018-01-19 13:46:23
#
########################################################################

#!/bin/bash

YumPath=/etc/yum.repos.d
YumRecFile=/var/log/.yum_setted
ScriptRecFile=~/.vim/.script_setted
Main_ver=""

function last_cmd_ok ()
{
	res=$?
	# '$?' is the result of last cmd.
	if [ ${res} -ne 0 ]; then
		perror $1
		exit ${res}
	fi
}

# Get main version number, like 6 or 7.
function get_rhel_centos_version ()
{
	release_msg=`cat /etc/${CURRENT_OS}-release`
	msg_pieces=(${release_msg})
	for part in ${msg_pieces[@]}
	do
		main_ver=${part:0:1}
		if [[ ! "$main_ver" =~ [0123456789] ]]; then
			continue
		fi
		if [ "$main_ver" != "6" ] && [ "$main_ver" != "7" ]; then
			perror "Only 6.x and 7.x be supported. Sorry."
			return 1
		fi
		pmsg "found, main_ver=${main_ver}"
		Main_ver=$main_ver
		return 0
	done
	perror "Not found main version in release msg. quit."
	return 1
}

function if_yum_setted ()
{
	if [ -e $YumRecFile ]; then
		return 0
	fi
	return 1
}

function set_yum ()
{
	if_yum_setted
	if [ $? -eq 0 ]; then
		pinfo "Yum has be setted."
		return $?
	fi

	get_rhel_centos_version
	if [ $? -eq 1 ]; then
		return $?
	fi

	ver=$Main_ver
	pinfo "Set Yum Repo"
	mkdir -p $YumPath
	echo "cp $1/config/Centos-${ver}.repo $YumPath/"
	cp $1/config/Centos-${ver}.repo $YumPath/
	cd $YumPath
	yum -y install epel-release && rpm -Uvh https://li.nux.ro/download/nux/dextop/el${ver}/x86_64/nux-dextop-release-0-1.el${ver}.nux.noarch.rpm
	yum clean all && yum makecache && yum -y update
	cd -

	touch $YumRecFile

	pinfo "Set Yum Repo Done"
}

function if_brew_installed ()
{
	brew_ver=`brew --version`
	if [ "$brew_ver" = "" ]; then
		return 1
	fi
	return 0
}

function install_homebrew ()
{
	if_brew_installed
	if [ $? -eq 0 ]; then
		pinfo "Homebrew has already installed"
		return $?
	fi

	retries=3
	while [ $retries -ne 0 ]
	do
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		# Not verified, I am not sure $? will be 0 when above success.
		if [ $? -eq 0 ]; then
			break
		fi
		retries=$(($retries - 1))
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
	done

	if [ $retries -eq 0 ]; then
		perror "Fail to install homebrew."
		return 1
	fi

	pinfo "Install homebrew success."
	return 0
}

function install_script_and_config ()
{
	cur_dir=`pwd`
	cd $CURRENT_PATH/script/bin

	profile=$HOME/.bash_profile
	if [ $CURRENT_OS = "ubuntu" ]; then
		profile=$HOME/.bashrc
	fi
	mkdir -p $HOME/bin
	mkdir -p $HOME/.vim
	scripts=(`ls`)
	for script in ${scripts[@]}
	do
		cp $script $HOME/bin/
		script_alias="alias ${script%.*}=\". ${script}\""
		if cat $profile | grep "$script_alias" > /dev/null
		then
			pinfo "alias of ${script} has been added to profile already."
		else
			echo "$script_alias" >> $profile
		fi
	done

	# NOT a good idea.
#	if [ $CURRENT_OS != "darwin" ]; then
#		touch $HOME/.gdbinit
#		echo "set disassembly-flavor inter" > $HOME/.gdbinit
#	fi
	cd $cur_dir
}

function install_manager()
{
	if [ -e $HOME/.vim/plugin/youcompleteme.vim ]; then
		pinfo "YouCompleteMe already be installed"
		return 0
	fi

	if [ $CURRENT_OS = "ubuntu" ]; then
		packageManager="apt-get -y"
	elif [ $CURRENT_OS = "darwin" ]; then
		if_brew_installed
		if [ $? -eq 1 ]; then
			perror "Homebrew not installed, please check the installation or reinstall it"
			exit -1
		fi
		packageManager="brew"
	else
		if_yum_setted
		if [ $? -eq 1 ]; then
			perror "Yum not be set, please check configuration or reset it"
			exit -1
		fi
		packageManager="yum -y"
	fi

	pinfo "Start to install YouCompleteMe"

	# Install python
	$packageManager install python
	if [ $CURRENT_OS = "ubuntu" ]; then
		$packageManager install python-dev
	else
		$packageManager install python-devel
	fi

	# Install cscope
	$packageManager install cscope
	# Install ctags
	$packageManager install ctags
	# Newest YCM need 7.4.1578+ vim, but default system vim is earlier. So we use mvim to
	# make ycm work.
	if [ $CURRENT_OS = "darwin" ]; then
		$packageManager install macvim
		echo "alias vim=\"mvim -v\"" >> $HOME/.bash_profile
	else
		# Don't know in centos/rhel the system default vim has this problem or not.
		echo ""
		if [ "`gcc --version`" == "" ]; then
			pplain "Gcc is not installed, install gcc and g++"
			$packageManager install gcc
			$packageManager install gcc-c++
			$packageManager install libstdc++-devel
			pplain "Gcc and G++ installation finished"
		fi
	fi

	$packageManager install wget
	$packageManager install git
	if [ $CURRENT_OS = "darwin" ]; then
		$packageManager install cmake
	else
		wget https://cmake.org/files/v3.9/cmake-3.9.3-Linux-x86_64.tar.gz
		tar -xzvf cmake-3.9.3-Linux-x86_64.tar.gz
		cd cmake-3.9.3-Linux-x86_64
		cp -r bin /usr/
		cp -r doc /usr/share/
		cp -r man /usr/share/
		cp -r share /usr/
		cd -
	fi

	# If not in mac os, need to download llvm and clang and build them first.
	if [ $CURRENT_OS = "ubuntu" ]; then
		wget http://releases.llvm.org/5.0.0/clang+llvm-5.0.0-linux-x86_64-ubuntu16.04.tar.xz
		tar -xJvf clang+llvm-5.0.0-linux-x86_64-ubuntu16.04.tar.xz
	elif [ $CURRENT_OS != 'darwin' ]; then
		wget http://releases.llvm.org/5.0.0/llvm-5.0.0.src.tar.xz
		wget http://releases.llvm.org/5.0.0/cfe-5.0.0.src.tar.xz

		tar -xvJf llvm-5.0.0.src.tar.xz
		tar -xvJf cfe-5.0.0.src.tar.xz

		mv cfe-5.0.0.src llvm-5.0.0.src/tools/clang
		mkdir -p llvm-5.0.0.src/build
		mkdir -p $1/llvm-binary
		cd llvm-5.0.0.src/build

		cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$1/llvm-binary -DCMAKE_BUILD_TYPE=Release ../
		make -j2 && make install
		cd $1
	fi

	git clone https://github.com/Valloric/YouCompleteMe.git
	cd ./YouCompleteMe
	git submodule update --init --recursive
	cd $1

	build_ycm $1

	pinfo "YouCompleteMe installed ok"
}

# In darwin, just run the install.sh script to download libclang automatically
# and compile ycm_core. But in rhel/centos, we need to do that ourselves.
function build_ycm ()
{
	if [ $CURRENT_OS = "ubuntu" ]; then
		mkdir -p $1/YouCompleteMe/build
		cd $1/YouCompleteMe/build
		cmake -G "Unix Makefiles" -DPATH_TO_LLVM_ROOT=$1/clang+llvm-5.0.0-linux-x86_64-ubuntu16.04 . $1/YouCompleteMe/third_party/ycmd/cpp
		cmake --build . --target ycm_core --config Release
	elif [ $CURRENT_OS != 'darwin' ]; then
		mkdir -p $1/YouCompleteMe/build
		cd $1/YouCompleteMe/build
		cmake -G "Unix Makefiles" -DPATH_TO_LLVM_ROOT=$1/llvm-binary . $1/YouCompleteMe/third_party/ycmd/cpp
		cmake --build . --target ycm_core --config Release
	else
		$1/YouCompleteMe/install.sh --all
	fi

	mkdir -p ~/.vim
	mv $1/YouCompleteMe ~/.vim/
	# Copy this folders to ~/.vim to make ycm could be found by vim.
	cp -r ~/.vim/YouCompleteMe/plugin ~/.vim/
	cp -r ~/.vim/YouCompleteMe/doc ~/.vim/
	cp -r ~/.vim/YouCompleteMe/autoload ~/.vim/
	ln -s $HOME/.vim/YouCompleteMe/third_party $HOME/.vim/third_party
	ln -s $HOME/.vim/YouCompleteMe/python $HOME/.vim/python

	cp $1/config/.ycm_extra_conf.py ~/.vim/
	cd $1
}

# The second plugin I use, besides Ycm.
function install_airline ()
{
	pinfo "Start install airline"
	git clone https://github.com/vim-airline/vim-airline.git
	cd vim-airline
	all_files=(`ls`)
	for file in ${all_files[@]}
	do
		if [ -d ${file} ]; then
			cp -r ${file} ~/.vim/
		fi
	done
	pinfo "Airline installed"
}

# If not install these fonts, the arrow will be random code.
function install_powerlinefont ()
{
	pinfo "Install powerlinefonts"
	git clone https://github.com/powerline/fonts.git
	cd fonts
	./install.sh
	cd -
	pinfo "Powerlinefonts installed"
	if [ $CURRENT_OS = 'darwin' ]; then
		pmsg "Then you might need to change fonts for you terminal for show the effect out."
	else
		pmsg "If you use a terminal to connect server, you need to install these fonts to your \
			local machine."
	fi
}

function install_vimrc ()
{
	pinfo "Install vimrc"
	git clone https://github.com/923115zx/vim-config.git
	cp vim-config/.vimrc ~/
	cp -r vim-config/colors ~/.vim
	cp vim-config/airline-themes/* ~/.vim/autoload/airline/themes/
	pinfo "Vimrc installed."
}

