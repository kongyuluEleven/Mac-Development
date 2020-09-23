//
//  ViewController.h
//  noiseReduction
//
//  Created by LJP on 2018/8/23.
//  Copyright © 2018 LJP. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NoiseTool:NSObject

- (void) testNoiseRemove;
- (void) noise_suppression:(char *)in_file and:(char *)out_file;
- (int) nsProcess:(int16_t *)buffer :(uint32_t)sampleRate;

@end

