//
//  BeautifyFilter.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 6/21/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "BeautifyFilter.h"

@implementation BeautifyFilter

int indexAAA = 0;

- (CGImageRef)filterImage:(CGImageRef)image {

    GPUImageBeautifyFilter *filter = [[GPUImageBeautifyFilter alloc] initWithLevel:self.level];
    CGImageRef cgimage = [filter newCGImageByFilteringCGImage:image];
    return cgimage;
}

- (CGImageRef)imageWithWatermark:(CGImageRef)image {
    
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithCGImage:image];
    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    blendFilter.mix = 1.0;
    
    GPUImageFilter *bFilter = [[GPUImageFilter alloc] init];
    [pic addTarget:bFilter];
    [bFilter addTarget:blendFilter];
    [self.UIElement addTarget:blendFilter];
    
    [blendFilter useNextFrameForImageCapture];
    [pic processImage];
    
    // 动态水印 只要刷新, 修改self.UIElement 的view, 就实现动态水印
    //    indexAAA++;
    //    if (self.change) {
    //        _change([NSString stringWithFormat:@"now %d", indexAAA%100]);
    //    }
    
    [self.UIElement update];
    CGImageRef img = [blendFilter newCGImageFromCurrentlyProcessedOutput];
    
    if (!img) {
        NSLog(@"..........");
        return nil;
    }
    [self.UIElement removeAllTargets];
    
    return img;
}


- (CGImageRef)filterImageWithWatermark:(CGImageRef)image {
    
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithCGImage:image];
    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    blendFilter.mix = 1.0;
    
    GPUImageBeautifyFilter *bFilter = [[GPUImageBeautifyFilter alloc] initWithLevel:self.level];
    [pic addTarget:bFilter];
    [bFilter addTarget:blendFilter];
    [self.UIElement addTarget:blendFilter];
    
    [blendFilter useNextFrameForImageCapture];
    [pic processImage];
    
    // 动态水印 只要刷新, 修改self.UIElement 的view, 就实现动态水印
    //    indexAAA++;
    //    if (self.change) {
    //        _change([NSString stringWithFormat:@"now %d", indexAAA%100]);
    //    }
    
    [self.UIElement update];
    CGImageRef img = [blendFilter newCGImageFromCurrentlyProcessedOutput];
    
    if (!img) {
        NSLog(@"..........");
        return nil;
    }
    [self.UIElement removeAllTargets];
    
    return img;
}

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

@end
