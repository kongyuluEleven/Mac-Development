# !/usr/local/bin/python2.7
# encoding: utf-8
import xlrd
import os

"""
读取excel内容
"""
path = os.getcwd() + "/result"


class readExcel(object):
    def __init__(self, name):
        """获取当前路径"""
        curpath = os.path.dirname(__file__)
        """获取excel文件【与当前脚本在同一级目录下】"""
        self.filename = os.path.join(curpath, name)

        self.excel_handle = xlrd.open_workbook(self.filename)  # 路径不包含中文
        self.row_num = 0
        # sheet1 = self.excel_handle.sheet_names()[1]           # 获取第1个sheet的名字,可与获取name函数一起使用
        # print self.excel_handle.sheet_names()
        # sheet = self.excel_handle.sheet_by_name('Sheet1')     # 根据名字获取
        # self.sheet = self.excel_handle.sheet_by_index(0)  # 根据索引获取第一个sheet
        # print sheet.name,sheet.nrows,sheet.ncols         # 获取sheet的表格名称、总行数、总列数
        # self.row_num = self.sheet.nrows  # 行
        #  col_num = sheet.ncols       # 列

    def read(self):
        for sheetName in self.excel_handle.sheet_names():
            file = open(path + "/" + sheetName, 'w')
            file.writelines('<?xml version="1.0" encoding="utf-8"?>')
            file.writelines('\n')
            file.writelines('<resources>')
            self.sheet = self.excel_handle.sheet_by_name(sheetName)
            self.row_num = self.sheet.nrows
            contents = self.readSheet()
            for content in contents:
                line = '\t<string name="' + content[0] + '">' + content[1] + '</string>'
                file.writelines('\n')
                file.writelines(line)
            # file.writelines(content)
            file.writelines('\n')
            file.writelines('</resources>')
            file.close()

    def readSheet(self):
        arr = []
        # row1 = self.sheet.row_values(0)
        # 因为是Unicode编码格式，因此需要转成utf-8
        for i in range(self.row_num - 1):
            item = []
            item.append(self.sheet.row_values(i)[0].encode('utf-8'))
            item.append(self.sheet.row_values(i)[1].encode('utf-8'))
            # dic[row1[2].encode('utf-8')] = self.sheet.row_values(i)[2].encode('utf-8')
            arr.append(item)
        return arr



