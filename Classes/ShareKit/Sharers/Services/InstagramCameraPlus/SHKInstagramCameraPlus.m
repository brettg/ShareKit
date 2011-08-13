//
//  SHKInstagramCameraPlus.m
//  ShareKit
//
//  Created by Brett Gibson on 8/11/12.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "SHKInstagramCameraPlus.h"

#import "SHK.h"

@interface SHKInstagramCameraPlus () 
+ (void)cleanupImageFile;
@end

NSString *const kInstagramAppURL = @"instagram://app";
NSString *const kCameraPlusAppURL = @"cameraplus://app";

@implementation SHKInstagramCameraPlus

// we need to save the image to disk to pass it on
static NSString *imageFilePath;

static BOOL instagramAvailable, cameraPlusAvailable;

#pragma mark - init
+ (void)initialize{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                       NSUserDomainMask, 
                                                       YES);
  NSString *docPath = [paths objectAtIndex:0];
  imageFilePath = [[docPath stringByAppendingPathComponent:@"SHKInstagram-Temp-Image.ig"] retain];
  
  [self cleanupImageFile];
  
  instagramAvailable = [[UIApplication sharedApplication] 
                        canOpenURL:[NSURL URLWithString:kInstagramAppURL]];
  cameraPlusAvailable = [[UIApplication sharedApplication] 
                        canOpenURL:[NSURL URLWithString:kCameraPlusAppURL]];
}

#pragma mark private class methods
+ (void)cleanupImageFile{
  NSFileManager *fileMgr = [NSFileManager defaultManager];
  if([fileMgr fileExistsAtPath:imageFilePath]){
    [fileMgr removeItemAtPath:imageFilePath error:nil];
  }
}

#pragma mark - Configuration : Service Defination

+ (NSString *)sharerTitle{
  NSMutableArray *parts = [NSMutableArray array];
  if(instagramAvailable){
    [parts addObject:@"Instagram"];
  }
  if(cameraPlusAvailable){
    [parts addObject:@"Camera+"];
  }
	return [parts componentsJoinedByString:@" / "];
}

+ (BOOL)canShareImage{
	return instagramAvailable || cameraPlusAvailable;
}

+ (BOOL)shareRequiresInternetConnection{
	return NO;
}

+ (BOOL)requiresAuthentication{
	return NO;
}



#pragma mark - Configuration : Dynamic Enable

- (BOOL)shouldAutoShare{
	return YES;
}


#pragma mark - Share API Methods

- (BOOL)send{	
  [self.class cleanupImageFile];
  
  NSData *jpg = UIImageJPEGRepresentation(item.image,  1.0f); 
  if(![jpg writeToFile:imageFilePath atomically:NO]){
    return NO;
  }
  
  NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", imageFilePath]];
  
  UIDocumentInteractionController *interactionController = [UIDocumentInteractionController 
                                                            interactionControllerWithURL:fileURL];
  [interactionController retain];
  
  CGRect r = CGRectMake(0, 0, 0, 0);
  [[SHK currentHelper] findRootViewController];
  UIView *v = [SHK currentHelper].rootViewController.view;
  [interactionController presentOpenInMenuFromRect:r inView:v animated:NO];
	
	return YES;
}

@end
