
/**
 @ 引用 https://github.com/LaiFengiOS/LFLiveKit/blob/master/LFLiveKit/filter/LFGPUImageBeautyFilter.h 的
 */

#import "GPUImageFilter.h"

@interface LFGPUImageBeautyFilter : GPUImageFilter {
}

@property (nonatomic, assign) CGFloat beautyLevel;
@property (nonatomic, assign) CGFloat brightLevel;
@property (nonatomic, assign) CGFloat toneLevel;
@end
