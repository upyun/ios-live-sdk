//
//  BeautifyFilter.h
//  UPLiveSDKDemo
//
//  Created by DING FENG on 6/21/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageBeautifyFilter.h"
#import <UPLiveSDK/UPAVCapturer.h>


@interface BeautifyFilter : NSObject <UPAVCapturerVideoFilterProtocol>
@property (nonatomic) int level;


- (CGImageRef)filterImage:(CGImageRef)image;

@end
