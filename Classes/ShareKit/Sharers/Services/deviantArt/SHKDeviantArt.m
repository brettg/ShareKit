//
//  SHKDeviantArt.m
//  ShareKit
//
//  Created by Brett Gibson on 8/11/11.
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

#import "SHKDeviantArt.h"

#import "SHKSharer+MultipartPost.h"

#import "NXOAuth2Connection.h"

NSString *const kDAAuthorizeURL = @"https://www.deviantart.com/oauth2/draft10/authorize";
NSString *const kDATokenURL = @"https://www.deviantart.com/oauth2/draft10/token";
NSString *const kDAStashURL = @"https://www.deviantart.com/api/draft10/submit";

@implementation SHKDeviantArt


#pragma mark - SHKSharer class methods
+ (NSString *)sharerTitle{
	return @"deviantART";
}

+ (BOOL)canShare{
  return [SHKDeviantArtClientID length] > 0;
}

+ (BOOL)canShareImage{
	return YES;
}

#pragma mark - SHKOAuth2Sharer class methods
+ (NSURL *)tokenURL{
  return [NSURL URLWithString:kDATokenURL];
}
+ (NSURL *)accessURL{
  return [NSURL URLWithString:kDAAuthorizeURL];
}
+ (NSURL *)redirectURL{
  return [NSURL URLWithString:SHKDeviantArtRedirectURL];
}
+ (NSString *)clientID{
  return SHKDeviantArtClientID;
}
+ (NSString *)clientSecret{
  return SHKDeviantArtClientSecret;
}

#pragma mark SHKSharer instance methods

- (NSArray *)shareFormFieldsForType:(SHKShareType)type{
	if (type == SHKShareTypeImage)
		return [NSArray arrayWithObject:[SHKFormFieldSettings label:SHKLocalizedString(@"Title") 
                                                            key:@"title" 
                                                           type:SHKFormFieldTypeText 
                                                          start:self.item.title]];
	
	return nil;
}

- (BOOL)send{
  NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] 
                               initWithURL:[NSURL URLWithString:kDAStashURL] 
                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData 
                               timeoutInterval:90] autorelease];
  
  [self addMultipartContentHeader:req];
  
  NSMutableData *body = [NSMutableData data];
  [self addParameter:@"title" withValue:self.item.title toBody:body];
  [self addImageMimePart:self.item.image toBody:body];
  [self addFinalMimeBoundary:body];
  
  [req setHTTPBody:body];
  
  [[[NXOAuth2Connection alloc] initWithRequest:req 
                             requestParameters:nil
                                   oauthClient:self.oauthClient 
                                      delegate:self] autorelease];
  
  [self sendDidStart];
  
  return YES;
}


@end
