//
//  UPQRCodeViewController.h
//  UPAVPlayerDemo
//
//  Created by 林港 on 16/3/22.
//  Copyright © 2016年 upyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRScanView.h"

@protocol UPQRCodeDelegate <NSObject>

- (void)returnWithResult:(NSString *)result;

@end


@interface UPQRCodeViewController : UIViewController
@property (nonatomic, weak)id<UPQRCodeDelegate> upQRdelegate;
@end
