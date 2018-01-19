########################################################################
#
#      FileName                    : svn_diff.sh
#      Author                      : Zhao Xin
#      CreateTime                  : 2017-06-30 10:24:05 AM
#      VIM                         : ts=4, sw=4
#      LastModified                : 2018-01-18 20:29:38
#
########################################################################

#!/bin/bash

svn diff --diff-cmd "diff" -x "-q" . | grep Index | cut -d " " -f 2
