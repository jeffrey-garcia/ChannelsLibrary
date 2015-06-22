//
//  ChannelsLibrary.m
//  ChannelsLibrary
//
//  Created by jeffrey on 16/3/15.
//  Copyright (c) 2015 jeffrey. All rights reserved.
//

#import "ZipArchive.h"

#import "ChannelsLibrary.h"
#import "ChannelsViewController.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <MobileCoreServices/MobileCoreServices.h>

@implementation ChannelsLibrary

+ (NSString *)getBundleType
{
    return BundleType;
}

-(void)testDownloadBundle:(NSObject<DownloadDelegate> *) delegate :(NSString *)urlToDownload
{
    NSLog(@"testDownloadBundle");
    
    //download file in a separate thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"download started... %@", urlToDownload);
        
        NSURL *url = [NSURL URLWithString:urlToDownload];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        
        NSLog(@"download completed");
        
        if (urlData) {
            // retrieve the application's document directory path
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            // define target file path and name
            //NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Plugin.bundle.zip"];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"ChannelsBundle.bundle.zip"];
            filePath = [filePath stringByStandardizingPath];
            
            // saving file to local is done on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [urlData writeToFile:filePath atomically:YES];
                NSLog(@"file is saved to local!");
            });
            
            // unzip file is done on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                ZipArchive *zipArchive = [[ZipArchive alloc] init];
                NSLog(@"file path: %@", filePath);
                
                if([zipArchive UnzipOpenFile:filePath])
                {
                    if ([zipArchive UnzipFileTo:documentsDirectory overWrite:YES])
                    {
                        NSLog(@"unzip file is completed");
                        
                        //unzipped successfully
                        [zipArchive UnzipCloseFile];
                        
                        //notify the delegate
                        [delegate notifyDownloadCompleted];
                    }
                } else {
                    NSLog(@"FAIL to open archive");
                }
            });
        } else {
            NSLog(@"FAIL to download");
        }
    });
}

-(BOOL)testInitBundle
{
    NSLog(@"testInitBundle");
    
    NSURL *documentsLocation = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
    NSLog(@"documentLocation %@", documentsLocation);
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsLocation includingPropertiesForKeys:@[NSFileType] options:(NSDirectoryEnumerationOptions)0 error:NULL];
    
    __block BOOL foundBundle = NO;
    __block NSURL *bundleUrl;
    
    [contents enumerateObjectsUsingBlock:^ (NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        NSLog(@"file URL %@", fileURL);
        NSString *fileType = [fileURL resourceValuesForKeys:@[NSURLTypeIdentifierKey] error:NULL][NSURLTypeIdentifierKey];
        NSLog(@"fileType %@", fileType);
        if (fileType == nil) {
            return;
        }
        
        if (UTTypeConformsTo((__bridge CFStringRef)fileType, (__bridge CFStringRef)BundleType)) {
            foundBundle = YES;
            bundleUrl = fileURL;
            return; // quit the loop if found
        }
    }];
    
    if (!foundBundle) {
        NSLog(@"Bundle is NOT found");
        NSLog(@"No bundle could be found. Make sure that you manually copy a bundle into the Documents directory.");
        
        return NO;
        
    } else {
        NSLog(@"Loading Bundle: %@", bundleUrl);
        staticLibBundle = [[NSBundle alloc] initWithURL:bundleUrl];
        
        // Debugger - verify all the files are downloaded
        NSString *filePath   = [staticLibBundle pathForResource:@"Data" ofType:@"plist"];
        NSLog(@"plist file path: %@",filePath);
        if (filePath == nil) {
            return NO;
        }
        
        NSString *imagePath = [staticLibBundle pathForResource:@"service" ofType:@"png"];
        NSLog(@"image path: %@", imagePath);
        if (imagePath == nil) {
            return NO;
        }
        
        NSString *xibPath = [staticLibBundle pathForResource:@"ChannelsViewLayout" ofType:@"nib"];
        NSLog(@"xib path: %@", xibPath);
        if (xibPath == nil) {
            return NO;
        }
        
        return YES;
    }
}

-(void)testUIAlertView
{
    NSLog(@"testUIAlertView");
    
    /* Static library cannot include resources such as Images, Plist and XIB
     * Need to package them using Bundle for retrieval and have the main project referenced to it
     * Bundle downloaded from internet
     */
    //NSBundle *staticLibBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"ChannelsBundle" ofType:@"bundle"]];
    
    NSString *filePath   = [staticLibBundle pathForResource:@"Data" ofType:@"plist"];
    NSLog(@"bundle file path: %@",filePath);
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    NSString *message = params[@"message"];
    NSLog(@"message: %@",message);
    
    UIAlertView *alertView = [[UIAlertView alloc] init];
    [alertView setTitle:@"Congratulations"];
    [alertView setMessage:message];
    [alertView addButtonWithTitle:@"OK"];
    [alertView show];
}

- (UIImage *)testUIImage
{
    /* Static library cannot include resources such as Images, Plist and XIB
     * Need to package them using Bundle for retrieval and have the main project referenced to it
     * Bundle downloaded from internet
     */
    //NSBundle *staticLibBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"ChannelsBundle" ofType:@"bundle"]];
    
    // image file name is hard-coded here
    NSString *imagePath = [staticLibBundle pathForResource:@"service" ofType:@"png"];
    NSLog(@"image path: %@", imagePath);
    UIImage* theImage = [UIImage imageWithContentsOfFile:imagePath];
    
    return theImage;
}

- (ChannelsViewController *)testXIB
{
    /* Static library cannot include resources such as Images, Plist and XIB
     * Need to package them using Bundle for retrieval and have the main project referenced to it
     * Bundle downloaded from internet
     */
    //NSBundle *staticLibBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"ChannelsBundle" ofType:@"bundle"]];
    
    // XIB file name is hard-coded here
    ChannelsViewController * theViewController = [[ChannelsViewController alloc] initWithNibName:@"ChannelsViewLayout" bundle:staticLibBundle];
    return theViewController;
}

- (void)testUIWebView
{

}

@end
