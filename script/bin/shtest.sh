########################################################################
#
#	FileName					: shtest.sh
#	Author						: Zhao Xin
#	CreateTime					: 2016-12-05 01:43:26 PM
#	VIM							: ts=4, sw=4
#	LastModified                : 2018-01-19 13:46:08
#
#######################################################################

#!/bin/bash

if [ $# -eq 0 ]; then
	echo "No test file specified."
	exit 0
fi

testShellDir=$HOME/work/shelltest
mkdir -p $testShellDir

cd $testShellDir
touch ${1}.sh
chmod 744 ${1}.sh
echo "#!/bin/bash" > ${1}.sh
