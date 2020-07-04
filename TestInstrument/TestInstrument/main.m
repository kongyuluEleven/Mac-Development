//
//  main.m
//  TestInstrument
//
//  Created by kongyulu on 2020/6/20.
//  Copyright © 2020 wondershare. All rights reserved.
//

#import <Foundation/Foundation.h>

NSNumber * increment(NSNumber *value) {
    return @([value intValue] + 1);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        int i,k;
        @autoreleasepool {
            NSNumber* sum = nil;
            for (k=0; k< 100000; k++) {
                sum = @(0);
                for (i=1; i<=1000; i++) {
                    sum = @([sum intValue] + i);
                    sum = increment(sum);
                }
            }
            NSLog(@"%@",sum);
        }
    }
    return 0;
}
