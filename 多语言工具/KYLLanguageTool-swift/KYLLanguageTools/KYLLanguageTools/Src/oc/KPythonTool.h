//
//  KPythonTool.h
//  KLanguageTool2
//
//  Created by kongyulu on 2020/12/28.
//

/*
 安装python脚本执行需要的库
 
 1. $ python --version
 Python 2.7.10
 
 2. $ pip --version
 pip 19.0 from /Library/Python/2.7/site-packages/pip (python 2.7)
 
 3. curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
 sudo python get-pip.py
 
 4. sudo pip install pyExcelerator
 
 5. sudo pip install xlrd
 
 6. Convert iOS strings files to excel files.
 
 $ python python/Strings2Xls.py -f examples/ios/ -t examples/output
 Start converting
 
 7. Convert excel files to iOS strings files
 
 $ python python/Xls2Strings.py -f examples/output/strings-files-to-xls_20190129_165830/ -t examples/ou
 tput/

 options: {'fileDir': 'examples/output/strings-files-to-xls_20190129_165830/', 'targetDir': 'examples/output/', 'excelStorageForm': 'multiple', 'additional': None
 }, args: []

 Start converting
 
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KPythonTool : NSObject

- (BOOL) excutePython:(NSString *)pythonFilePath recursion:(NSString *)isRecursion;

@end

NS_ASSUME_NONNULL_END
