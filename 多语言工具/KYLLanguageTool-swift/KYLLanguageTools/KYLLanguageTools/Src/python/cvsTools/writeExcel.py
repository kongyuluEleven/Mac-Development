#!/usr/local/bin/python2.7
# encoding: utf-8
import xlwt
import os

"""
向excel写入内容
"""
path = os.getcwd()

class writeExcel(object):
    def __init__(self, name):
        self.excel_w = xlwt.Workbook(encoding='utf-8')  # 设置编码格式
        self.filename = path + "/" + name

    def writLabel(self, sheet=None, content=[]):
        if sheet:
            self.excel_w_sheet = self.excel_w.add_sheet(sheet)  # 添加sheet表
        else:
            self.excel_w_sheet = self.excel_w.add_sheet("mySheet")  # 添加sheet表

        """向excel写入内容，内容自定义"""
        style = xlwt.XFStyle()  # 初始化样式
        font = xlwt.Font()  # 为样式创建字体
        font.name = 'Times New Roman'
        # font.bold = True                                  # 黑体
        # font.underline = True                             # 下划线
        # font.italic = True                                # 斜体字
        style.font = font  # 设定样式
        for i in range(len(content)):
            for j in range(2):
                self.excel_w_sheet.write(i, j, label=content[i][j])  # 参数对应 行, 列, 值
        self.excel_w.save(self.filename)


if __name__ == '__main__':
    excel_w = writeExcel()
    excel_w.writLabel()