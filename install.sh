########################################################################
#
#      FileName                    : install.sh
#      Author                      : Zhao Xin
#      CreateTime                  : 2017-09-18 01:57:24 PM
#      VIM                         : ts=4, sw=4
#      LastModified                : 2017-09-19 17:09:55
#
########################################################################

#!/bin/sh

source ./script/lib/color.sh
source ./script/lib/common.sh

SUPPORT_OS=("darwin" "centos" "redhat")
SYSTEM=`uname -s`
SUPPORTED=1
CURRENT_PATH=$(cd `dirname $0`; pwd)

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

if [ $CURRENT_OS = "darwin" ]; then
	question="Install homebrew"
else
	question="Set yum"
fi

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
#		get_rhel_centos_version
		set_yum $CURRENT_PATH
	else
		# install homebrew. XXX: during then installation user need to type their passwd.
		install_homebrew
	fi
fi

install_script_and_config $CURRENT_PATH
#last_cmd_ok "$question failed! quit."
install_ycm $CURRENT_PATH

#function pmenu ()
#{
#	while
#	do
#		pplain "========================================="
#		pplain "1. Prepare package manager(rhel/centos is yum, darwin is homebrew)."
#		pplain "2. Install script and set personal profile."
#		pplain "3. Install YouComplete plugin for vim."
#		pplain "4. Do 1, 2, 3 in order."
#		pplain "5. exit."
#		echo ""
#		pplain "enter you choose:"
#		read line
#		case $line in
#			1)
#				if [ $CURRENT_OS != "darwin" ]; then
#					set_yum $CURRENT_PATH
#				else
#					install_homebrew
#				fi ;;
#			2)
#				install_script_and_config $CURRENT_PATH ;;
#			3)
#				if [ $CURRENT_OS != "darwin" ]; then
#					if_yum_setted
#					if [ $? -eq -1 ]; then
#						pplain "Yum is not setted, please set yum first"
#					else
#						install_ycm
#					fi
#				else
#					if_brew_installed
#					if [ $? -eq -1 ]; then
#						pplain "Homebrew is not installed, please install homebrew first"
#					else
#						install_ycm
#					fi
#				fi ;;
#			4)
#				;;
#			5)
#				pinfo "Goodbye."
#				exit 0 ;;
#			*)
#				pinfo "Unknow option." ;;
#		esac
#	done
#}
