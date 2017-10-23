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
echo "using std::string;" >> ${1}.cc
echo "" >> ${1}.cc
echo "//struct TreeNode" >> ${1}.cc
echo "//{" >> ${1}.cc
echo -e "//\tint val;" >> ${1}.cc
echo -e "//\tTreeNode* left;" >> ${1}.cc
echo -e "//\tTreeNode* right;" >> ${1}.cc
echo -e "//\tTreeNode(int x) : val(x), left(NULL), right(NULL) {}" >> ${1}.cc
echo -e "//};\n" >> ${1}.cc
echo "//struct ListNode" >> ${1}.cc
echo "//{" >> ${1}.cc
echo -e "//\tint val;" >> ${1}.cc
echo -e "//\tListNode* next;" >> ${1}.cc
echo -e "//\tListNode(int x) : val(x), next(NULL) {}" >> ${1}.cc
echo -e "//};\n" >> ${1}.cc
echo "int main(int argc, char* argv[])" >> ${1}.cc
echo "{" >> ${1}.cc
echo "	(void)argc;" >> ${1}.cc
echo "	(void)argv;" >> ${1}.cc
echo "" >> ${1}.cc
echo "	return 0;" >> ${1}.cc
echo "}" >> ${1}.cc

prepareProject.sh
