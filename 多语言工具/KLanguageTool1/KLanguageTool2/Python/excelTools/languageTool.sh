#!/bin/sh
#  func.sh
#  myTest
#
#  Created by fisker on 12/03/2019.
#  Copyright © 2019 fisker. All rights reserved.

#=============Localizable
locPath="${SRCROOT}/KLanguageTool2/Python/tool2/StringToExcel"

exportToExcel="exportStringToExcel.py"
importLocalizable="importExcelToString.py"
# 0导出 1导入  2不干嘛
locFun=2

#跳转路径
cd $locPath
if [ $locFun -eq 0 ]; then
echo "Localizable--------------------------------导出"
python3 $exportToExcel
elif [ $locFun -eq 1 ]; then
echo "Localizable--------------------------------导入"
python3 $importLocalizable
else
echo "Localizable--------------------------------None"
fi
#=============Code
codePath="${SRCROOT}/KLanguageTool2/Python/tool2/PlistToExcel/"

exportCode="exportExcelToPlist.py"
importCode="importPlistToExcel.py"

# 0导出 1导入  2不干嘛
codeFun=1

#跳转路径
cd $codePath
if [ $codeFun -eq 0 ]; then
echo "Code--------------------------------导出"
python3 $exportCode
elif [ $codeFun -eq 1 ]; then
echo "Code--------------------------------导入"
python3 $importCode
else
echo "Code--------------------------------None"
fi
