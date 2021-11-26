//
//  DeviceInfo.m
//  KylStoreKit
//
//  Created by kongyulu on 2021/11/26.
//

#import "DeviceInfo.h"

#include <sys/sysctl.h>


/// 检查是否在调试
bool fetchKernProc(){
    //控制码
    int name[4];//放字节码-查询信息
    name[0] = CTL_KERN;//内核查看
    name[1] = KERN_PROC;//查询进程
    name[2] = KERN_PROC_PID; //通过进程id查进程
    name[3] = getpid();//拿到自己进程的id
    //查询结果
    struct kinfo_proc info;//进程查询信息结果
    size_t info_size = sizeof(info);//结构体大小
    int error = sysctl(name, sizeof(name)/sizeof(*name), &info, &info_size, 0, 0);
    assert(error == 0);//0就是没有错误
    
    //结果解析 p_flag的第12位为1就是有调试
    //p_flag 与 P_TRACED =0 就是有调试
    return ((info.kp_proc.p_flag & P_TRACED) !=0);
}

/// 退出程序
void noExit() {
    //检测异常时退出
    if (fetchKernProc()) {
//        asm("mov X0,#0\n"
//            "mov w16,#1\n"
//            "svc #0x80"
//            );
    }
}
