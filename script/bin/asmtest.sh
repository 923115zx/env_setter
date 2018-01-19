########################################################################
#
#      FileName                    : asmtest.sh
#      Author                      : Zhao Xin
#      CreateTime                  : 2017-06-20 11:02:31 PM
#      VIM                         : ts=4, sw=4
#      LastModified                : 2018-01-18 20:29:03
#
########################################################################

#!/bin/bash

asmTestPath=$HOME/work/asmtest
mkfile=Makefile
mkdir -p ${asmTestPath}

if [ $# -eq 0 ]
then
	echo "Must specify asm name."
	exit 0
fi

if [ -d ${asmTestPath}/$1 ]
then
	echo "$1 is already exists."
	exit 0
fi

mkdir ${asmTestPath}/$1
cd ${asmTestPath}/$1
touch ${1}.asm

touch $mkfile
echo "$1: ${1}.o" >> $mkfile
echo -e "\tld -m elf_i386 -o $1 ${1}.o" >> $mkfile
echo "${1}.o: ${1}.asm" >> $mkfile
echo -e "\tnasm -f elf -g -F stabs ${1}.asm -l ${1}.lst" >> $mkfile
