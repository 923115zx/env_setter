########################################################################
#
#      FileName                    : install.sh
#      Author                      : Zhao Xin
#      CreateTime                  : 2017-09-18 01:57:24 PM
#      VIM                         : ts=4, sw=4
#      LastModified                : 2018-06-15 15:57:34
#
########################################################################

#!/bin/bash

source ./script/lib/color.sh
source ./script/lib/common.sh

SUPPORT_OS=("darwin" "centos" "redhat" "ubuntu")
SYSTEM=`uname -s`
SUPPORTED=1
CURRENT_PATH=$(cd `dirname $0`; pwd)

# Maybe could add ubuntu in supported list. Seems just rhel/centos need to
# compile llvm/clang ourselves.
case $SYSTEM in
	Darwin)
		CURRENT_OS="darwin" ;;
	Linux)
		if [ -s /etc/centos-release ]; then
			CURRENT_OS="centos"
			release_content=(`cat /etc/centos-release`)
			if [ ${release_content[3]:0:1} != 7 ]; then
				perror "For now just support centos 7 or higher."
				exit 0
			fi
		elif [ -s /etc/redhat-release ]; then
			CURRENT_OS="redhat"
			release_content=(`cat /etc/redhat-release`)
			if [ ${release_content[3]:0:1} != 7 ]; then
				perror "For now just support redhat 7 or higher."
				exit 0
			fi
		elif [ -s /etc/lsb-release ]; then
			release_content=(`cat /etc/lsb-release`)
			if [ ${release_content[0]:${#release_content[0]}-6:6} = "Ubuntu" ]; then
				CURRENT_OS="ubuntu"
				# Maybe 14.04 install ycm ok too, change here later.
				if [ ${release_content[1]:${#release_content[1]}-5:5} != "16.04" ]; then
					perror "Sorry now just support ubuntu 16.04."
					exit 0
				fi
			else
				CURRENT_OS="Unknow Linux"
				SUPPORTED=0
			fi
		else
			CURRENT_OS="Unknow Linux"
			SUPPORTED=0
		fi ;;
	*)
		CURRENT_OS="Unsupported OS"
		SUPPORTED=0 ;;
esac

# Sorry I just have used these three before.
if [ $SUPPORTED -eq 0 ]; then
	perror "Current OS ${SYSTEM} is ${CURRENT_OS}, sorry not support yet."
	exit 0
fi

# Different hint.
if [ $CURRENT_OS = "darwin" ]; then
	question="Install homebrew"
elif [ $CURRENT_OS = "centos" ] || [ $CURRENT_OS = "redhat" ]; then
	question="Set yum"
fi

# Actually yum don't need to read permission. Because we will check if
# installed or setted later.
if [ $CURRENT_OS != "ubuntu" ]; then
	for ((i=0; i<3; ++i))
	do
		pplain "$question? [y/n] "
		read line
		if [ $line != "y" ] && [ $line != "n" ]; then
			pmsg "please input 'y' or 'n'"
		else
			break
		fi
	done

	if [ $line = "y" ]; then
		if [ $CURRENT_OS != "darwin" ]; then
			# yum setting.
			set_yum $CURRENT_PATH
		else
			# install homebrew. XXX: during then installation user need to type their passwd.
			install_homebrew
		fi
	fi
fi

install_script_and_config $CURRENT_PATH
install_manager $CURRENT_PATH
install_airline $CURRENT_PATH
install_powerlinefont $CURRENT_PATH
install_vimrc $CURRENT_PATH

