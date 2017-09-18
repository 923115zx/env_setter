########################################################################
#
#      FileName                    : common.sh
#      Author                      : Zhao Xin
#      CreateTime                  : 2017-09-18 03:43:31 PM
#      VIM                         : ts=4, sw=4
#      LastModified                : 2017-09-18 22:51:53
#
########################################################################

#!/bin/sh

YumPath=/etc/yum.repos.d

function last_cmd_ok ()
{
	# '$?' is the result of last cmd.
	if [ $? -ne 0 ]; then
		echo -e "${Red}Last cmd failed! Quit${Blank}"
		exit $?
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
			exit -1
		fi
		pmsg "found, main_ver=${main_ver}"
		return $main_ver
	done
	perror "Not found main version in release msg. quit."
	exit -1
}

function set_yum ()
{
	pinfo "Set Yum Repo"
	mkdir -p $YumPath
	cp $2/config/Centos-${1}.repo yum.repo.d/
	cd $YumPath
	yum -y install epel-release && rpm -Uvh https://li.nux.ro/download/nux/dextop/el${1}/x86_64/nux-dextop-release-0-1.el${1}.nux.noarch.rpm
	yum clean all && yum makecache && yum -y update
	cd -
	pinfo "Set Yum Repo Done"
}
