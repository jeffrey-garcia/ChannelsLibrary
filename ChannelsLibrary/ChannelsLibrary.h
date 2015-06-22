//
//  ChannelsLibrary.h
//  ChannelsLibrary
//
//  Created by jeffrey on 16/3/15.
//  Copyright (c) 2015 jeffrey. All rights reserved.
//

#import "DownloadDelegate.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// declare the bundle type
static NSString * const BundleType = @"com.apple.generic-bundle";

// declare the static libary
NSBundle *staticLibBundle;

@interface ChannelsLibrary : NSObject

//=== static class method ===
+ (NSString *)getBundleType;

//=== non-static class method ===
- (void)testDownloadBundle:(NSObject<DownloadDelegate> *) delegate :(NSString *)urlToDownload;

- (BOOL)testInitBundle;

- (void)testUIAlertView;

- (UIImage *)testUIImage;

- (UIViewController *)testXIB;

- (void)testUIWebView;

@end
