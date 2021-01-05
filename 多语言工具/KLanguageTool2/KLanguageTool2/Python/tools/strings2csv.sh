#! /bin/bash

#删除生成的csv文件
rm -rf reslut.csv

#temp文件
cp Localizable.strings temp.strings

#替换 = 为$
srcText=" = "
destText="$"
sed -i "" "s/${srcText}/${destText}/g" temp.strings

#去掉；
srcText=";"
destText=""
sed -i "" "s/${srcText}/${destText}/g" temp.strings

#去掉引号
srcText="\""
destText=""
sed -i "" "s/${srcText}/${destText}/g" temp.strings

#替换空格
srcText=" "
destText="~"
sed -i "" "s/${srcText}/${destText}/g" temp.strings

#替换逗号
srcText=","
destText="^"
sed -i "" "s/${srcText}/${destText}/g" temp.strings

#逐行读取
arr=()
flag=0
while read LINE
do
str=$LINE
res=""
#如果包含$
if [[ $str == *"$"* ]]
then
key=`echo $str | cut -d "$" -f 1`
value=`echo $str | cut -d "$" -f 2`
res="${key},${value}"
else
if [[ $str == *"//"* ]]
then
pre="${str#*//}"
res="${pre},"
fi
fi
echo $res
arr[flag]=$res
#arr[$flag]=$LINE
let "flag ++"
done  < temp.strings

rm -f reslut.csv
touch reslut.csv

for line in ${arr[@]}; do
echo $line >> reslut.csv
done

#恢复空格
srcText='~'
destText=' '
sed -i "" "s/${srcText}/${destText}/g" reslut.csv

#恢复逗号
srcText='^'
destText=','
sed -i "" "s/${srcText}/${destText}/g" reslut.csv

#删除文件
rm -f temp.strings
