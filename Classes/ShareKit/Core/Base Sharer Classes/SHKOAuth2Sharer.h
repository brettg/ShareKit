//
//  SHKOAuth2Sharer.h
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

#import "SHKSharer.h"

#import "NXOAuth2ClientDelegate.h"
#import "NXOAuth2ConnectionDelegate.h"

// Base class for Sharers that use OAuth2
// Subclasses need to override the configuration class methods below
//
// Note that if a subclass overrides +initialize it needs to call +registerSubclass explicitly 
// for +handleOpenURL: to work correctly
@interface SHKOAuth2Sharer : SHKSharer<
  NXOAuth2ConnectionDelegate,
  NXOAuth2ClientDelegate> {
}

@property (nonatomic, retain) NXOAuth2Client *oauthClient;

#pragma mark - configuration
// override these in subclasses!
// first couple should be constant
+ (NSURL *)tokenURL;
+ (NSURL *)accessURL;
// last few should likely just return macro set in SHKConfig.h
+ (NSURL *)redirectURL;
+ (NSString *)clientID;
+ (NSString *)clientSecret;

// both a class and instance version
// the class version will loop through all the subclasses of this class
// and call handleOpenURL: on them until one of the subclasses returns YES
+ (BOOL)handleOpenURL:(NSURL *)url; 
- (BOOL)handleOpenURL:(NSURL *)url;

// subclass specific string for storing pending SHKItem in user defaults while the 
// user gets sent to an outside app or mobile safari
- (NSString *)pendingItemKey;

@end
