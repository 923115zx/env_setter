########################################################################
#
#      FileName                    : git_info.sh
#      Author                      : Zhao Xin
#      CreateTime                  : 2017-04-11 09:52:58 AM
#      VIM                         : ts=4, sw=4
#      LastModified                : 2018-01-18 20:29:11
#
########################################################################

#!/bin/bash

cur_path=`pwd`

while [ ! -d .git ] && [ ! `pwd` = "/" ]
do
	cd ..
done

if [ -d .git ]
then
	echo "----Remote URL:"
	git remote -v
	echo ""
	echo "----Remote Branches:"
	git branch -r
	echo ""
	echo "----Local Branches:"
	git branch
	echo ""
	echo "----Configuration (.git/config):"
	cat .git/config
	echo ""
	echo "----Most Recent Commit:"
	git --no-pager log --max-count=1
else
	echo "No Git Project found."
fi
