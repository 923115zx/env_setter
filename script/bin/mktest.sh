#!/bin/bash

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
echo "#!/bin/bash" >> $buildFile
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
add_line "#include <unordered_map>"
add_line "#include <vector>"
add_line "#include <set>"
add_line "#include <unordered_set>"
add_line "#include <string>"
add_line "#include <queue>\n"
add_line "using std::vector;"
add_line "using std::map;"
add_line "using std::multimap;"
add_line "using std::unordered_map;"
add_line "using std::set;"
add_line "using std::multiset;"
add_line "using std::unordered_set;"
add_line "using std::string;"
add_line "using std::queue;"
add_line "using std::pair;\n"
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
add_line "class Solution"
add_line "{"
add_line "public:"
add_line "};\n"
add_line "int main(int argc, char* argv[])"
add_line "{"
add_line "\t(void)argc;"
add_line "\t(void)argv;\n"
add_line "\treturn 0;"
add_line "}"

prepareProject.sh
