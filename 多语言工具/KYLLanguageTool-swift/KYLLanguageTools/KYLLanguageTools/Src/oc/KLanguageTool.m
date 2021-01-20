//
//  KLanguageTool.m
//  KLanguageTool
//
//  Created by kongyulu on 2020/12/26.
//

#import "KLanguageTool.h"
#import "DHxlsReaderIOS.h"
#import "SSZipArchive.h"
#import <Cocoa/Cocoa.h>

@implementation KLanguageTool
- (void)createFile:(NSString *)file {
//    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test123.xls"];
    DHxlsReader *reader = [DHxlsReader xlsReaderFromFile:file];
    assert(reader);
    [self createFileWithReader:reader];
}

- (void)createDefaultFile {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"多语言例子.xls"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [self downDefaultFile:data];
}

#pragma mark - 数据操作

//把第一列当作键，按行数赋值
- (NSDictionary *)keyNmubWith:(DHxlsReader *)reader {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    int row = 2;//第一行不统计
    while(YES) {
        DHcell *cell = [reader cellInWorkSheetIndex:0 row:row col:1];
        if(cell.type == cellBlank) break;
        NSString *str = [[cell str] stringByReplacingOccurrencesOfString:@"\"" withString:@"“"];
        if (!str) {
            str = @"";
        }
        [dic setObject:str forKey:@(row)];
        row++;
    }
    return dic;
}

//获取所有语言类型，当作文件名字
- (NSDictionary*)rowNmubWith:(DHxlsReader *)reader {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    int col = 2;//第一列部统计
    while(YES) {
        DHcell *cell = [reader cellInWorkSheetIndex:0 row:1 col:col];
        if(cell.type == cellBlank) break;
        NSString *str = [[cell str] stringByReplacingOccurrencesOfString:@"\"" withString:@"“"];
        if (!str) {
            str = @"";
        }
        [dic setObject:str forKey:@(col)];
        col++;
    }
    return dic;
}


- (void)createFileWithReader:(DHxlsReader *)reader {
    NSDictionary *sdic = [self keyNmubWith:reader];
    NSDictionary *rowDic = [self rowNmubWith:reader];
    [reader startIterator:0];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    while(YES) {
        DHcell *cell = [reader nextCell];
        if(cell.type == cellBlank) break;
        
        NSString *str = [[cell str] stringByReplacingOccurrencesOfString:@"\"" withString:@"“"];
        if (!str) {
            str = @"";
        }
        //获取多种语言
        NSString *rowStr = [rowDic objectForKey:@(cell.col)];
        rowStr = [rowStr stringByReplacingOccurrencesOfString:@"/" withString:@""];
        
        if (rowStr) {
            
            //获取每种语言已有的值
            NSMutableDictionary *oldDic = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:rowStr]];
            
            NSString *sstr = [sdic objectForKey:@(cell.row)];

            if (sstr) {

                //如果为空的情况下，需要进行赋值
                if ([str isEqualToString:@"/"]) {
                    //第二列第一个就是默认数据（因为必须要取得到才是正确的格式所以不需要判断）
                    
                    NSString *defaultStr = [rowDic objectForKey:@(2)];
                    defaultStr = [defaultStr stringByReplacingOccurrencesOfString:@"/" withString:@""];
                    if (defaultStr) {
                        NSDictionary *enDic = dic[defaultStr];
                        NSString *value = enDic[sstr];
                        [oldDic setObject:value forKey:sstr];
                    }
                }else {
                    //将多语言的key对应这种语言的值
                    [oldDic setObject:str forKey:sstr];
                }
            }
            
            //创建每种语言需要添加的数据
            [dic setObject:oldDic forKey:rowStr];
        }
        
        //打印信息
        //        text = [text stringByAppendingFormat:@"\n %d %d %@\n",cell.row,cell.col,str];
        
    }
    
    //----------------------文件操作------------------------
    [self crateFileToMacWithDic:dic];
    
}

#pragma mark - 文件操作

- (void)crateFileToMacWithDic:(NSDictionary *)dic {
    
    NSString *dataFilePath = [[self filePath] stringByAppendingPathComponent:@"kyl_Language"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:dataFilePath isDirectory:&isDir];
    
    if (!(isDir && existed)) {
        // 在Document目录下创建一个archiver目录
        [fileManager createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSDictionary *newDic = obj;
//        NSString *file = [NSString stringWithFormat:@"%@/%@.txt",dataFilePath,key];
        NSString *dir = [NSString stringWithFormat:@"%@/%@",dataFilePath,key];
        BOOL isDir;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if (![fileMgr fileExistsAtPath:dir isDirectory:&isDir]) {
            [fileMgr createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        __block NSString *newStr = nil;
        NSString *file = [NSString stringWithFormat:@"%@/Localizable.strings",dir];
        [newDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key1, id  _Nonnull obj1, BOOL * _Nonnull stop) {
            
            NSString *rowString = [NSString stringWithFormat:@"\"%@\" = \"%@\"",key1,obj1];
            if (newStr.length == 0) {
                newStr = [NSString stringWithFormat:@"%@",rowString];
            }else {
                newStr = [NSString stringWithFormat:@"%@\n%@",newStr,rowString];
            }
            
        }];
        NSError *error = nil;
        [newStr writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"写入沙盒的错误信息:%@",error);
        }
    }];
    
    //文件移动拷贝
    
    NSString *zipfile = [NSString stringWithFormat:@"%@/KLanguage.zip",[self filePath]];
    
    if ([SSZipArchive createZipFileAtPath:zipfile withContentsOfDirectory:dataFilePath]) {
        //移除原来文件夹
        [fileManager removeItemAtPath:dataFilePath error:nil];
        //将压缩文件转位data拷贝到制定路径
        NSData *data = [NSData dataWithContentsOfFile:zipfile];
        [self downLoadFile:data fileName:@"KLanguage"];
        //移除原来的压缩文件
        [fileManager removeItemAtPath:zipfile error:nil];
    }else {
        
    }
}

- (NSString *)filePath {
    NSLog(@"文件路径：%@/Documents",NSHomeDirectory());
    return [NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
}

//mac下的文件操作
- (void)downLoadFile:(NSData *)file fileName:(NSString *)fileName
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.title = @"保存文件";
    [panel setMessage:@"选择文件保存地址"];//提示文字
    
    [panel setDirectoryURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]]];//设置默认打开路径
    [panel setNameFieldStringValue:fileName];
    [panel setAllowsOtherFileTypes:YES];
    [panel setAllowedFileTypes:@[@"zip"]];
    [panel setExtensionHidden:NO];
    [panel setCanCreateDirectories:YES];
    [panel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK)
        {
            NSString *path = [[panel URL] path];
            BOOL result =  [file writeToFile:path atomically:YES];
            
            NSString * downloadResult;
            if(result){
                downloadResult = @"下载成功！";
            }else{
                downloadResult = @"下载失败！请稍后再试！";
            }
        }
    }];
}

- (void)downDefaultFile:(NSData *)file
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.title = @"保存文件";
    [panel setMessage:@"选择文件保存地址"];//提示文字
    
    [panel setDirectoryURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]]];//设置默认打开路径
    [panel setNameFieldStringValue:@"多语言列子"];
    [panel setAllowsOtherFileTypes:YES];
    [panel setAllowedFileTypes:@[@"xls"]];
    [panel setExtensionHidden:NO];
    [panel setCanCreateDirectories:YES];
    [panel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK)
        {
            NSString *path = [[panel URL] path];
            BOOL result =  [file writeToFile:path atomically:YES];
            
            NSString * downloadResult;
            if(result){
                downloadResult = @"下载成功！";
            }else{
                downloadResult = @"下载失败！请稍后再试！";
            }
        }
    }];
}

@end
