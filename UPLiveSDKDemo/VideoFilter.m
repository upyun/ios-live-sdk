//
//  VideoFilter.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 7/12/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "VideoFilter.h"

@interface VideoFilter()
@property (nonatomic, strong) GPUImageUIElement *uiElement;
@property (nonatomic, strong) UIView *backgroudView;
@property (nonatomic) CGSize backgroudSize;
@end

@implementation VideoFilter

//实现 UPAVCapturerVideoFilterProtocol 协议
- (CGImageRef)filterImage:(CGImageRef)image {
    if (self.watermarkView) {
        return [self filterOringinImage:image beautify:self.beautifylevel withWatermark:self.watermarkView];
    } else {
        return [self filterOringinImage:image beautify:self.beautifylevel];
    }
}

//美颜滤镜 ＋ 水印
- (CGImageRef)filterOringinImage:(CGImageRef)image beautify:(int)level withWatermark:(UIView *)view {
    if (!self.uiElement) {
        float w = CGImageGetWidth(image);
        float h = CGImageGetHeight(image);
        self.backgroudSize = CGSizeMake(w, h);
        
        self.backgroudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        [self.backgroudView addSubview:view];
        self.uiElement = [[GPUImageUIElement alloc] initWithView:self.backgroudView];
    }
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithCGImage:image];
    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    blendFilter.mix = 1.0;
    GPUImageBeautifyFilter *bFilter = [[GPUImageBeautifyFilter alloc] initWithLevel:level];
    [pic addTarget:bFilter];
    [bFilter addTarget:blendFilter];
    [self.uiElement addTarget:blendFilter];
    
    [blendFilter useNextFrameForImageCapture];
    [pic processImage];
    if (self.watermarkWillRenderBlock) {
        self.watermarkWillRenderBlock(self.watermarkView, self.backgroudSize);
    }
    [self.uiElement update];
    CGImageRef img = [blendFilter newCGImageFromCurrentlyProcessedOutput];
    
    if (!img) {
        NSLog(@"VideoFilter error");
        return nil;
    }
    [self.uiElement removeAllTargets];
    return img;
}

//加水印
- (CGImageRef)filterOringinImage:(CGImageRef)image withWatermark:(UIView *)view {
    if (!self.uiElement) {
        float w = CGImageGetWidth(image);
        float h = CGImageGetHeight(image);
        self.backgroudSize = CGSizeMake(w, h);
        
        self.backgroudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        [self.backgroudView addSubview:view];
        self.uiElement = [[GPUImageUIElement alloc] initWithView:self.backgroudView];
    }
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithCGImage:image];
    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    blendFilter.mix = 1.0;

    [pic addTarget:blendFilter];
    [self.uiElement addTarget:blendFilter];
    
    [blendFilter useNextFrameForImageCapture];
    [pic processImage];
    if (self.watermarkWillRenderBlock) {
        self.watermarkWillRenderBlock(self.watermarkView, self.backgroudSize);
    }
    [self.uiElement update];
    CGImageRef img = [blendFilter newCGImageFromCurrentlyProcessedOutput];
    
    if (!img) {
        NSLog(@"VideoFilter error");
        return nil;
    }
    [self.uiElement removeAllTargets];
    return img;
}

//美颜滤镜
- (CGImageRef)filterOringinImage:(CGImageRef)image beautify:(int)level{
    GPUImageBeautifyFilter *filter = [[GPUImageBeautifyFilter alloc] initWithLevel:level];
    CGImageRef cgimage = [filter newCGImageByFilteringCGImage:image];
    return cgimage;
}

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}


@end
