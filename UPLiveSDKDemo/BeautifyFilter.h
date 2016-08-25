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


typedef void(^TextChange)(NSString *text);

@interface BeautifyFilter : NSObject <UPAVCapturerVideoFilterProtocol>
@property (nonatomic) int level;
@property (nonatomic, strong)GPUImageUIElement *UIElement;
@property (nonatomic, copy)TextChange change;

- (CGImageRef)filterImage:(CGImageRef)image;

- (CGImageRef)filterImageWithWatermark:(CGImageRef)image;

- (CGImageRef)imageWithWatermark:(CGImageRef)image;

@end
