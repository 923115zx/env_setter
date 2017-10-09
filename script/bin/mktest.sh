#!/bin/sh

if [ $# -eq 0 ]; then
	echo "No test file specified."
	exit 0
fi

baseTestPath=~/work/cpptest
buildFile=build.sh

mkdir -p ${baseTestPath}/$1
cd ${baseTestPath}/$1
touch ${1}.cc
touch $buildFile
echo "#!/bin/sh" >> $buildFile
echo "g++ -g -std=c++11 ${1}.cc -o $1" >> $buildFile
chmod 744 $buildFile

echo "#include <stdio.h>" >> ${1}.cc
echo "#include <stdlib.h>" >> ${1}.cc
echo "#include <string.h>" >> ${1}.cc
echo "#include <map>" >> ${1}.cc
echo "#include <vector>" >> ${1}.cc
echo "#include <set>" >> ${1}.cc
echo "#include <string>" >> ${1}.cc
echo "" >> ${1}.cc
echo "using std::vector;" >> ${1}.cc
echo "using std::map;" >> ${1}.cc
echo "using std::set;" >> ${1}.cc
echo "" >> ${1}.cc
echo "int main(int argc, char* argv[])" >> ${1}.cc
echo "{" >> ${1}.cc
echo "	(void)argc;" >> ${1}.cc
echo "	(void)argv;" >> ${1}.cc
echo "" >> ${1}.cc
echo "	return 0;" >> ${1}.cc
echo "}" >> ${1}.cc

prepareProject.sh
