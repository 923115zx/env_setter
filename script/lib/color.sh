########################################################################
#
#      FileName                    : color.sh
#      Author                      : Zhao Xin
#      CreateTime                  : 2017-09-18 03:23:46 PM
#      VIM                         : ts=4, sw=4
#      LastModified                : 2017-09-18 05:52:19 PM
#
########################################################################

#!/bin/sh

# OutPut color
Blank="\033[0m"
Red="\033[31m"
Blue="\033[34m"
White="\033[37;1m"
Green="\033[92m"

function perror ()
{
	echo -e "${Red}${1}${Blank}"
}

function pplain ()
{
	echo -e "${White}${1}${Blank}"
}

function pinfo ()
{
	echo -e "${Blue}${1}${Blank}"
}

function pmsg ()
{
	echo -e "${Green}${1}${Blank}"
}
