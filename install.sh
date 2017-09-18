########################################################################
#
#      FileName                    : install.sh
#      Author                      : Zhao Xin
#      CreateTime                  : 2017-09-18 01:57:24 PM
#      VIM                         : ts=4, sw=4
#      LastModified                : 2017-09-18 22:53:57
#
########################################################################

#!/bin/sh

source ./script/lib/color.sh
source ./script/lib/common.sh

SUPPORT_OS=("darwin" "centos" "redhat")
SYSTEM=`uname -s`
SUPPORTED=1

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

if [ $SYSTEM != "darwin" ]; then
	# yum setting.
	get_rhel_centos_version
	set_yum $? `pwd`
else
	# install homebrew. XXX: during then installation user need to type their passwd.
	retries=3
	while [ retries -ne 0 ]
	do
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		# Not verified, I am not sure $? will be 0 when above success.
		if [ $? -eq 0 ]; then
			break
		fi
		retries=$(($retries - 1))
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
	done
fi
