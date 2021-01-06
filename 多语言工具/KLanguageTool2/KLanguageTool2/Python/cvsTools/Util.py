#!/usr/bin/python
# -*- coding: UTF-8 -*-

import os
import xml.etree.cElementTree as ET
from writeExcel import *
from readExcel import *

root_dir = os.getcwd() + "/values"
file_list = []
excel = writeExcel(name='test.xls')

def xmlToExcel():
    if os.path.isdir(root_dir):
        for root, dirs, files in os.walk(root_dir):  # 文件目录遍历
            # print root, dirs, files
            for file in files:
                file_list.append(file)  # 将文件追加到file_list列表中，方便在其他函数中使用
        readFile()


def readFile():
    for file in file_list:
        tree = ET.ElementTree(file=root_dir + "/" + file)
        content = []
        for elem in tree.iter(tag="string"):
            item = []
            item.append(elem.attrib.values()[0])
            item.append(elem.text)
            content.append(item)
        excel.writLabel(sheet=file, content=content)


def excelToXml():
    readExcel(name='test.xls').read()


if __name__ == "__main__":
    #xmlToExcel()
    excelToXml()
