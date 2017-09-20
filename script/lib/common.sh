########################################################################
#
#      FileName                    : common.sh
#      Author                      : Zhao Xin
#      CreateTime                  : 2017-09-18 03:43:31 PM
#      VIM                         : ts=4, sw=4
#      LastModified                : 2017-09-20 22:34:19
#
########################################################################

#!/bin/sh

YumPath=/etc/yum.repos.d
YumRecFile=/var/log/.yum_setted
ScriptRecFile=~/.vim/.script_setted

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
			return -1
		fi
		pmsg "found, main_ver=${main_ver}"
		return $main_ver
	done
	perror "Not found main version in release msg. quit."
	return -1
}

function if_yum_setted ()
{
	if [ -e $YumRecFile ]; then
		return 0
	fi
	return -1
}

function set_yum ()
{
	if_yum_setted
	if [ $? -eq 0 ]; then
		pinfo "Yum has be setted."
		return $?
	fi

	get_rhel_centos_version
	if [ $? -eq -1 ]; then
		return $?
	fi

	ver=$?
	pinfo "Set Yum Repo"
	mkdir -p $YumPath
	cp $1/config/Centos-${ver}.repo yum.repo.d/
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
		return -1
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
		return -1
	fi

	pinfo "Install homebrew success."
	return 0
}

function install_script_and_config ()
{
	if [ -e $ScriptRecFile ]; then
		pinfo "script has been setted"
		return 0
	fi

	pinfo "Script and config installing"
	mkdir -p $HOME/bin
	cd $1/script/bin
	script_arr=(`ls`)
	for script_ in ${script_arr[@]}
	do
		cp $script_ $HOME/bin/
		echo "alias ${script_%.*}=\". ${script_}\"" >> $HOME/.bash_profile
	done
	cd -

	# Not necessary.
#	mkdir -p $HOME/.gdbinit
#	echo "set disassembly-flavor intel" > $HOME/.gdbinit

	mkdir -p ~/.vim
	touch $ScriptRecFile
	pinfo "scripts and config installed"
	return 0
}

function install_ycm ()
{
	if [ -e $HOME/.vim/plugin/youcompleteme.vim ]; then
		pinfo "YouCompleteMe already be installed"
		return 0
	fi

	if [ $CURRENT_OS = "darwin" ]; then
		if_brew_installed
		if [ $? -eq -1 ]; then
			perror "Homebrew not installed, please check the installation or reinstall it"
			exit -1
		fi
		packageManager="brew"
	else
		if_yum_setted
		if [ $? -eq -1 ]; then
			perror "Yum not be set, please check configuration or reset it"
			exit -1
		fi
		packageManager="yum -y"
	fi

	pinfo "Start to install YouCompleteMe"

	# Install python
	$packageManager install python
	$packageManager install python-devel

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
	fi

	if [ "`gcc --version`" == "" ]; then
		pplain "Gcc is not installed, install gcc and g++"
		$packageManager install gcc
		$packageManager install gcc-c++
		$packageManager install libstdc++-devel
		pplain "Gcc and G++ installation finished"
	fi

	$packageManager install cmake
	$packageManager install wget

	# If not in mac os, need to download llvm and clang and build them first.
	if [ $CURRENT_OS != 'darwin' ]; then
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
	if [ $CURRENT_OS != 'darwin' ]; then
		mkdir -p $1/YouCompleteMe/build
		cd $1/YouCompleteMe/build
		cmake -G "Unix Makefiles" -DPATH_TO_LLVM_ROOT=$1/llvm-binary . $1/YouCompleteMe/third_party/ycmd/cpp
		cmake --build . --target ycm_core --config Release
	else
		$1/YouCompleteMe/install.sh --all
	fi

	mkdir -p ~/.vim
	# Copy this folders to ~/.vim to make ycm could be found by vim.
	cp -r $1/YouCompleteMe/third_party ~/.vim/
	cp -r $1/YouCompleteMe/python ~/.vim/
	cp -r $1/YouCompleteMe/plugin ~/.vim/
	cp -r $1/YouCompleteMe/autoload ~/.vim/
	cp -r $1/YouCompleteMe/doc ~/.vim/

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

