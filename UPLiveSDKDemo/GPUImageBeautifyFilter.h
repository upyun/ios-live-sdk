//
//  GPUImageBeautifyFilter.h
//  BeautifyFaceDemo
//
//  Created by guikz on 16/4/28.
//  Copyright © 2016年 guikz. All rights reserved.



// ref: [基于GPUImage的实时美颜滤镜](http://www.jianshu.com/users/131423baa3c6/latest_articles)

#import "GPUImage.h"


@class GPUImageCombinationFilter;

@interface GPUImageBeautifyFilter : GPUImageFilterGroup {
    GPUImageBilateralFilter *bilateralFilter;
    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;
    GPUImageCombinationFilter *combinationFilter;
    GPUImageHSBFilter *hsbFilter;
}
- (instancetype)initWithLevel:(int)level;
@end
