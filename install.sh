########################################################################
#
#      FileName                    : install.sh
#      Author                      : Zhao Xin
#      CreateTime                  : 2017-09-18 01:57:24 PM
#      VIM                         : ts=4, sw=4
#      LastModified                : 2017-09-20 22:34:21
#
########################################################################

#!/bin/sh

source ./script/lib/color.sh
source ./script/lib/common.sh

SUPPORT_OS=("darwin" "centos" "redhat")
SYSTEM=`uname -s`
SUPPORTED=1
CURRENT_PATH=$(cd `dirname $0`; pwd)

# Maybe could add ubuntu in supported list. Seems just rhel/centos need to
# compile llvm/clang ourselves.
case $SYSTEM in
	Darwin)
		CURRENT_OS="darwin" ;;
	Linux)
		if [ -s /etc/redhat-release ]; then
			CURRENT_OS="readhat"
		elif [ -s /etc/centos-release ]; then
			CURRENT_OS="centos"
		else
			CURRENT_OS="Unknow Linux"
			SUPPORTED=0
		fi ;;
	*)
		CURRENT_OS="Unknow Unix/Linux"
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
else
	question="Set yum"
fi

# Actually yum don't need to read permission. Because we will check if
# installed or setted later.
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

install_script_and_config $CURRENT_PATH
install_ycm $CURRENT_PATH
install_airline $CURRENT_PATH
install_powerlinefont $CURRENT_PATH
install_vimrc $CURRENT_PATH

