//
//  VideoFilter.h
//  UPLiveSDKDemo
//
//  Created by DING FENG on 7/12/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageBeautifyFilter.h"
#import <UPLiveSDK/UPAVCapturer.h>

typedef void(^WatermarkWillRenderBlock)(UIView *watermarkView, CGSize backGroudSize);

@interface VideoFilter : NSObject <UPAVCapturerVideoFilterProtocol>

@property (nonatomic) int beautifylevel;
@property (nonatomic, strong) UIView *watermarkView;
@property (nonatomic, strong) WatermarkWillRenderBlock watermarkWillRenderBlock;


- (CGImageRef)filterImage:(CGImageRef)image;

@end
