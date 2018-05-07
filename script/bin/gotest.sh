#
# File            : gotest.sh
# Author          : ZhaoXin
# CreateTime      : 2018-05-07 13:56:46
# LastModified    : 2018-05-07 14:09:32
# Vim             : ts=4, sw=4
#

#!/usr/bin/env bash

if [ $# -eq 0 ]; then
	echo "No test file specified."
	exit 0
fi

baseTestPath=~/work/gotest
buildFile=build.sh

mkdir -p ${baseTestPath}/$1
cd ${baseTestPath}/$1
gofile=${1}.go
touch ${gofile}
touch $buildFile
echo "#!/bin/env bash" >> $buildFile
echo "go build ${1}.go" >> $buildFile
chmod 744 $buildFile

function add_line
{
	echo -e $1 >> $gofile
}

add_line "package main\n"
add_line "import \"fmt\"\n"
add_line "func main() {\n"
add_line "}"
