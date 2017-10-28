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
ccfile=${1}.cc

function add_line
{
	echo -e $1 >> $ccfile
}

add_line "#include <stdio.h>"
add_line "#include <stdlib.h>"
add_line "#include <string.h>"
add_line "#include <map>"
add_line "#include <vector>"
add_line "#include <set>"
add_line "#include <string>"
add_line "#include <queue>"
add_line ""
add_line "using std::vector;"
add_line "using std::map;"
add_line "using std::set;"
add_line "using std::string;"
add_line "using std::queue;"
add_line ""
add_line "//struct TreeNode"
add_line "//{"
add_line "//\tint val;"
add_line "//\tTreeNode* left;"
add_line "//\tTreeNode* right;"
add_line "//\tTreeNode(int x) : val(x), left(NULL), right(NULL) {}"
add_line "//};\n"
add_line "//struct ListNode"
add_line "//{"
add_line "//\tint val;"
add_line "//\tListNode* next;"
add_line "//\tListNode(int x) : val(x), next(NULL) {}"
add_line "//};\n"
add_line "class solution"
add_line "{"
add_line "public:"
add_line "};\n"
add_line "int main(int argc, char* argv[])"
add_line "{"
add_line "	(void)argc;"
add_line "	(void)argv;"
add_line ""
add_line "	return 0;"
add_line "}"

prepareProject.sh
