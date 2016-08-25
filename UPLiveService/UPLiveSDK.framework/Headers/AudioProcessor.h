//
//  AudioProcessor.h
//  UPLiveSDKDemo
//
//  Created by DING FENG on 8/22/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioProcessor : NSObject

- (NSData *)noiseSuppressionFor32KPCM:(NSData *)pcmInput;

@end
