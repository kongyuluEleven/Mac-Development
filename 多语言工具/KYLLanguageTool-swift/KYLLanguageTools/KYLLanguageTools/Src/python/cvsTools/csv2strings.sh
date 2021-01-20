#! /bin/bash

#判断temp文件存不存在，存在的话先删除
if [ -e temp.csv ]
then
rm -f temp.csv
fi

#copy一份temp.csv文件
cp reslut.csv temp.csv
echo "copy完成"

#先将csv的" "替换成~
srcText=" "
destText="~"
sed -i "" "s/${srcText}/${destText}/g" temp.csv
echo "替换完成"

#读取csv文件key行
#tail -n +2 从第二行开始读取
#| awk -F, '{print $1}')
#wak -F, 以,间隔的第2列
keys=$(cat temp.csv | tail -n +2)
j=0
arr=()
for i in ${keys[@]}; do
#分割key和value
echo $i
key=`echo $i | cut -d "," -f 1`
value=`echo $i | cut -d "," -f 2`
#如果value为空
if [ -z $value ]
then
arr[j]="//${key}"
else
arr[j]="${key} = \"${value}\";"
fi
let "j++"
done
#输出结果到多语言文件
#如果存在Localizable.strings，删除再创建
if [ -e Localizable.strings ]
then
echo "存在多语言文件，删除再建"
rm -f Localizable.strings
touch Localizable.strings
else
echo "不存在多语言文件，创建"
touch Localizable.strings
fi
var=0
echo "文件写入中"
while (( var<j ))
do
echo ${arr[var]} >> Localizable.strings
let "var++"
done

srcText="~"
destText=" "
sed -i "" "s/${srcText}/${destText}/g" Localizable.strings

srcText="\"\""
destText="\""
sed -i "" "s/${srcText}/${destText}/g" Localizable.strings

echo "删除temp文件"
rm -f temp.csv

#for str in ${arr[*]}; do
#echo ${str}
#echo $str >> Localizable.strings
#done
