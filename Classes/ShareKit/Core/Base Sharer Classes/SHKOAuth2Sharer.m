//
//  SHKOAuth2Sharer.m
//  ShareKit
//
//  Created by Brett Gibson on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SHKOAuth2Sharer.h"

#import "NXOAuth2Client.h"
#import "NXOAuth2Connection.h"
#import "NXOAuth2AccessToken.h"

@interface SHKOAuth2Sharer ()
- (void)setupClient;
@end

@implementation SHKOAuth2Sharer

@synthesize oauthClient = _oauthClient;

#pragma mark - init dealloc and setup
- (void)dealloc{
  [_oauthClient release], _oauthClient = nil;
  
  [super dealloc];
}

- (id)init{
  if((self = [super init])){
    [self setupClient];
  }
  return self;
}

#pragma mark - Class config to be overriden
+ (NSURL *)tokenURL{
  [NSException raise:@"Method must be overriden" 
              format:@"tokenURL must be overrien for", self.class];
  return nil;
}
+ (NSURL *)accessURL{
  [NSException raise:@"Method must be overriden" 
              format:@"accessURL must be overrien for", self.class];
  return nil;
}
+ (NSURL *)redirectURL{
  [NSException raise:@"Method must be overriden" 
              format:@"redirectURL must be overrien for", self.class];
  return nil;
}
+ (NSString *)clientID{
  [NSException raise:@"Method must be overriden" 
              format:@"clientID must be overrien for", self.class];
  return nil;
}
+ (NSString *)clientSecret{
  [NSException raise:@"Method must be overriden" 
              format:@"clientSecret must be overrien for", self.class];
  return nil;
}

#pragma mark - SHKSharer class methods

+ (void)logout{
  NSString *provider = [[self.class tokenURL] host];
  NXOAuth2AccessToken *t = [NXOAuth2AccessToken 
                            tokenFromDefaultKeychainWithServiceProviderName:provider];
  [t removeFromDefaultKeychainWithServiceProviderName:provider];
}

#pragma mark SHKSharer instance methods

// Always no - we at least need to check our token
- (BOOL)isAuthorized{
  return NO;
}

- (void)promptAuthorization{
  [[NSUserDefaults standardUserDefaults] setObject:[self.item dictionaryRepresentation] 
                                            forKey:[self pendingItemKey]];
  [self.oauthClient requestAccess];
}

#pragma mark - public methods

- (BOOL)handleOpenURL:(NSURL *)url{
  if (![[url baseURL] isEqual:[self.class redirectURL]]) {
    return NO;
  }
  
  return [self.oauthClient openRedirectURL:url];
}

- (NSString *)pendingItemKey{
  return [NSString stringWithFormat:@"%@PendingItem", self.class];
}

#pragma mark - private methods

- (void)setupClient{
  self.oauthClient = [[[NXOAuth2Client alloc] initWithClientID:[self.class clientID]
                                                  clientSecret:[self.class clientSecret]
                                                  authorizeURL:[self.class accessURL]
                                                      tokenURL:[self.class tokenURL]
                                                      delegate:self] autorelease];
}

#pragma mark - NXOAuth2ClientDelegate
- (void)oauthClientNeedsAuthentication:(NXOAuth2Client *)client{
  NSURL *authorizationURL = [client authorizationURLWithRedirectURL:[self.class redirectURL]];
  [[UIApplication sharedApplication] openURL:authorizationURL];
}

- (void)oauthClientDidGetAccessToken:(NXOAuth2Client *)client{
  self.item = [SHKItem itemFromDictionary:[[NSUserDefaults standardUserDefaults] 
                                           objectForKey:[self pendingItemKey]]];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self pendingItemKey]];
  
  [self show];
}

- (void)oauthClientDidLoseAccessToken:(NXOAuth2Client *)client{
  // ok, I think
}
- (void)oauthClient:(NXOAuth2Client *)client didFailToGetAccessTokenWithError:(NSError *)error{
  [self sendDidFailWithError:error];
}

#pragma mark - NXOAuth2ConnectionDelegate

- (void)oauthConnection:(NXOAuth2Connection *)connection 
     didReceiveResponse:(NSURLResponse *)response{
  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
  if ([httpResponse statusCode] >= 400) {
    [self sendDidFailWithError:[NSError errorWithDomain:[self.class tokenURL].host
                                                   code:[httpResponse statusCode] 
                                               userInfo:nil]];
  }else{
    [self sendDidFinish];
  }
}

- (void)oauthConnection:(NXOAuth2Connection *)connection didFailWithError:(NSError *)error{
  [self sendDidFailWithError:error];
}

@end
