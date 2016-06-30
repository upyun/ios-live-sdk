//
//  UPEAGLView.h
//  UPAVPlayerDemo
//
//  Created by DING FENG on 2/16/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPAVFrame.h"

@interface UPEAGLView: UIView
@property (nonatomic) UPVideoFrameFormat pixFormat;

- (id)initWithFrame:(CGRect)frame;
- (void)render:(UPVideoFrame *)frame;

@end
