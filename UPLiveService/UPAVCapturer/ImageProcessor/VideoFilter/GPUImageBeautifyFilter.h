//
//  GPUImageBeautifyFilter.h
//  UPLiveSDKDemo
//
//  Created by 林港 on 16/8/17.
//  Copyright © 2016年 upyun.com. All rights reserved.
//

//
//  GPUImageBeautifyFilter.h
//  BeautifyFaceDemo
//
//  Created by guikz on 16/4/28.
//  Copyright © 2016年 guikz. All rights reserved.
//

#import "GPUImage.h"

@class GPUImageCombinationFilter;

@interface GPUImageBeautifyFilter : GPUImageFilterGroup {
    GPUImageBilateralFilter *bilateralFilter;
    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;
    GPUImageCombinationFilter *combinationFilter;
    GPUImageHSBFilter *hsbFilter;
}

@property (nonatomic, assign)CGFloat level;
//- (void)setLevel:(CGFloat)level;
@end
