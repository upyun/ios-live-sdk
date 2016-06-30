//
//  BeautifyFilter.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 6/21/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "BeautifyFilter.h"

@implementation BeautifyFilter
- (CGImageRef)filterImage:(CGImageRef)image {
    
    GPUImageBeautifyFilter *filter = [[GPUImageBeautifyFilter alloc] initWithLevel:self.level];

    CGImageRef cgimage = [filter newCGImageByFilteringCGImage:image];
    return cgimage;
}

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

@end
