//
//  DemoViewController2.m
//  UPAVPlayerDemo
//
//  Created by DING FENG on 3/2/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "DemoViewControllerPlayer2.h"
#import <UPLiveSDK/UPAVPlayer.h>

@interface UITableViewPlayerCell : UITableViewCell
{
    CGRect _frame;
}
@property (nonatomic, strong ) UPAVPlayer *player;
@property (nonatomic, strong ) UIButton *playButton;
@property (nonatomic, strong ) UIButton *muteButton;


@end

@implementation UITableViewPlayerCell

- (id)initWithFrame:(CGRect)frame url:(NSString *)url {
    self = [super initWithFrame:frame];
    if (self) {
        _frame = frame;
        _player = [[UPAVPlayer alloc] initWithURL:url];
        [_player setFrame:CGRectMake(0, 0, _frame.size.width, _frame.size.height)];
        __weak UITableViewPlayerCell *weakself = self;
        _player.playerStadusBlock = ^(UPAVPlayerStatus playerStatus, NSError *error){
            switch (playerStatus) {
                case UPAVPlayerStatusIdle:{
                    [weakself.playButton setTitle:@"play" forState:UIControlStateNormal];
                    weakself.playButton.tag = 0;
                    NSLog(@"UPAVPlayerStatusIdle");
                }
                    break;
                case UPAVPlayerStatusPlaying_buffering:{
                    [weakself.playButton setTitle:@"buffering" forState:UIControlStateNormal];
                    weakself.playButton.tag = 2;
                    NSLog(@"UPAVPlayerStatusPlaying_buffering");
                }
                    break;
                case UPAVPlayerStatusPlaying:{
                    [weakself.playButton setTitle:@"stop" forState:UIControlStateNormal];
                    weakself.playButton.tag = 1;
                }
                    break;
                case UPAVPlayerStatusFailed:{
                    [weakself.playButton setTitle:@"play" forState:UIControlStateNormal];
                    weakself.playButton.tag = 0;
                    NSString *msg = @"请重新尝试播放.";
                    if (error) {
                        msg = error.description;
                    }
                    NSLog(@"msg");
                }
                    break;
                default:
                    break;
            }
        };
        [self.contentView insertSubview:_player.playView atIndex:0];
        
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_playButton setTitle:@"play" forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        
        _muteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_muteButton setTitle:@"mute" forState:UIControlStateNormal];
        [_muteButton addTarget:self action:@selector(mute:) forControlEvents:UIControlEventTouchUpInside];

        [self.contentView  addSubview:_playButton];
        [self.contentView  addSubview:_muteButton];

        _playButton.center = CGPointMake(frame.size.width/2. - 50, frame.size.height/2.);
        _muteButton.center = CGPointMake(frame.size.width/2. + 50, frame.size.height/2.);
    }
    return self;
}

- (void)layoutSubviews {
    [_player setFrame:CGRectMake(0, 0, _frame.size.width, _frame.size.height)];
}

- (void)play:(UIButton *)sender {
    if (sender.tag == 0) {
        [_player play];
    } else if(sender.tag == 1) {
        [_player stop];
    }
}

- (void)mute:(UIButton *)sender {
    if (sender.tag == 0) {
        _player.mute = YES;
        sender.tag = 1;
        [sender setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
    } else {
        _player.mute = NO;
        sender.tag = 0;
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)dealloc {
    [_player stop];
    NSLog(@"dealloc %@", self);
}

@end

@interface DemoViewControllerPlayer2 ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    NSArray *_dataArray;
}
@end

@implementation DemoViewControllerPlayer2


- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [UPAVPlayer setLogLevel:UPAVPlayerLogger_level_debug];

    _dataArray = @[@"rtmp://live.hkstv.hk.lxdns.com/live/hks",
                   @"http://vevoplaylist-live.hls.adaptive.level3.net/vevo/ch1/02/prog_index.m3u8",
                   @"http://vevoplaylist-live.hls.adaptive.level3.net/vevo/ch1/02/prog_index.m3u8",
                   @"rtmp://live.hkstv.hk.lxdns.com/live/hks"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
}
#pragma mark tableView Delegate & DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.width;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect frame = CGRectMake(0, 0, 180, 180.);
    if (indexPath.row < 4) {
        UITableViewPlayerCell *cell= [[UITableViewPlayerCell alloc] initWithFrame:frame
                                                                              url:[_dataArray objectAtIndex:indexPath.row]];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        return cell;
    }
}

- (void)dealloc {
    NSLog(@"dealloc  %@", self);
}

@end
