//
//  SHKOAuth2Sharer.h
//  ShareKit
//
//  Created by Brett Gibson on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SHKSharer.h"

#import "NXOAuth2ClientDelegate.h"
#import "NXOAuth2ConnectionDelegate.h"

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


// subclass specific string for storing pending SHKItem in user defaults while the 
// user gets sent to an outside app or mobile safari
- (NSString *)pendingItemKey;

@end
