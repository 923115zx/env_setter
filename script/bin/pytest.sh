########################################################################
#
#      FileName                    : pytest.sh
#      Author                      : Zhao Xin
#      CreateTime                  : 2017-11-07 17:08:30
#      VIM                         : ts=4, sw=4
#      LastModified                : 2017-11-10 10:52:17
#
########################################################################

#!/bin/sh

if [ $# -eq 0 ]; then
	echo "No test file specified."
	exit 0
fi

workdir=$HOME/work/pytest/${1}

mkdir -p ${workdir}
cd ${workdir}
pyfile=${1}.py
touch $pyfile
chmod 744 $pyfile

function add_line
{
	echo -e $1 >> $pyfile
}

add_line "#!/usr/bin/env python3\n"

