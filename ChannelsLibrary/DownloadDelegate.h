//
//  DownloadDelegate.h
//  ChannelsLibrary
//
//  Created by jeffrey on 20/3/15.
//  Copyright (c) 2015 jeffrey. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol DownloadDelegate <NSObject>

@required

- (void)notifyDownloadCompleted;

@end