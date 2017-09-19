########################################################################
#
#      FileName                    : common.sh
#      Author                      : Zhao Xin
#      CreateTime                  : 2017-09-18 03:43:31 PM
#      VIM                         : ts=4, sw=4
#      LastModified                : 2017-09-19 18:38:35
#
########################################################################

#!/bin/sh

YumPath=/etc/yum.repos.d
YumRecFile=/var/log/.yum_setted
ScriptRecFile=/var/log/.script_setted

function last_cmd_ok ()
{
	res=$?
	# '$?' is the result of last cmd.
	if [ ${res} -ne 0 ]; then
		perror $1
		exit ${res}
	fi
}

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
	if [ -e $YumRecFile ]
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
	findbrew=`which brew`
	echo $findbrew | grep -q "no brew"
	if [ $? -ne 0 ]; then
		return 0
	fi
	return -1
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
	cp $(`ls`) $HOME/bin
	cd -

	echo "alias mktest=\". mktest.sh\"" >> $HOME/.bash_profile
	echo "alias shtest=\". shtest.sh\"" >> $HOME/.bash_profile
	echo "alias asmtest=\". asmtest.sh\"" >> $HOME/.bash_profile
	echo "alias git_info=\". git_info.sh\"" >> $HOME/.bash_profile
	echo "alias svn_diff=\". svn_diff.sh\"" >> $HOME/.bash_profile

	# Not necessary.
#	mkdir -p $HOME/.gdbinit
#	echo "set disassembly-flavor intel" > $HOME/.gdbinit

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
		packageManager=brew
	else
		if_yum_setted
		if [ $? -eq -1 ]; then
			perror "Yum not be set, please check configuration or reset it"
			exit -1
		fi
		packageManager="yum -y"
	fi

	$packageManager python
	$packageManager python-devel

	$packageManager cscope

	if [ "`gcc --version`" == "" ]; then
		pplain "Gcc is not installed, install gcc and g++"
		$packageManager install gcc
		$packageManager install gcc-c++
		$packageManager install libstdc++-devel
		pplain "Gcc and G++ installation finished"
	fi

	$packageManager install cmake

	git clone https://github.com/Valloric/YouCompleteMe.git
	cd ./YouCompleteMe
	git submodule update --init --recursive

	# TODO

}

