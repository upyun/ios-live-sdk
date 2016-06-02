//
//  UPEAGLView.h
//  UPAVPlayerDemo
//
//  Created by DING FENG on 2/16/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UPVideoFrame;

@interface UPEAGLView : UIView

- (id)initWithFrame:(CGRect)frame;

- (void)render:(UPVideoFrame *)frame;

@end
