//
//  AppDelegate.m
//  UPAVPlayerDemo
//
//  Created by DING FENG on 2/16/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "AppDelegate.h"
#import "UPLiveViewController.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UPLiveViewController *vc = [[UPLiveViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = navController;
    
    return YES;
}

- (NSString *)getVHostFromURL:(NSString *)url {
    NSString *vhost = nil;
    NSURL *testURL = [NSURL URLWithString:url];
    NSString *testHost = testURL.host;
    NSLog(@"host==%@", testHost);
    NSArray *patch = testURL.pathComponents;
    
    NSLog(@"aaaa==%@", url);
    url = @"llll";
    NSLog(@"aaaa==%@", url);
    return url;
    if (patch.count >= 4) {
        NSLog(@"1vhost==%@", patch[1]);
        NSLog(@"app==%@", patch[2]);
        NSLog(@"stream==%@", patch[3]);
    } else if (patch.count >= 3) {
        NSLog(@"app==%@", patch[1]);
        NSLog(@"stream==%@", patch[2]);
    }
    
    if (![self validateIP:testHost]) {
        NSLog(@"2vhost==%@", testHost);
        
        return testHost;
    }

    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:testURL resolvingAgainstBaseURL:NO];
    NSArray *queryItems = urlComponents.queryItems;
    
    NSLog(@"queryItems==%@", queryItems);
    for (NSURLQueryItem *item in queryItems) {
        NSString *key = item.name;
        NSString *value = item.value;
        if ([key isEqualToString:@"vhost"] || [key isEqualToString:@"domain"]) {
            NSLog(@"34vhost==%@", value);
            return value;
        }
    }
    return vhost;
}

- (BOOL)validateIP:(NSString *)str {
    NSArray *urlComponents = [str componentsSeparatedByString:@"."];
    for (NSString *key in urlComponents) {
        if (![self isPureInt:key]) {
            return NO;
        };
    }
    return YES;
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
