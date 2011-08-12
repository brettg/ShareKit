//
//  SHKOAuth2Sharer.m
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

#import "SHKOAuth2Sharer.h"

#import "NXOAuth2Client.h"
#import "NXOAuth2Connection.h"
#import "NXOAuth2AccessToken.h"

@interface SHKOAuth2Sharer ()
+ (void)registerSubclass:(Class)subclass;
- (void)setupClient;
@end

@implementation SHKOAuth2Sharer

// we keep track of these for handleOpenURL 
static NSMutableSet *oauth2Subclasses;

@synthesize oauthClient = _oauthClient;

+ (void)initialize{
  if(self == [SHKOAuth2Sharer class]){
    oauth2Subclasses = [[NSMutableSet alloc] init];
  }else{
    // if the subclass doesn't call initialize
    // then take this opportunity to register them automatically
    [self registerSubclass:self];
  }
}

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

#pragma mark - other class methods
+ (void)registerSubclass:(Class)subclass{
  [oauth2Subclasses addObject:subclass];
}

+ (BOOL)handleOpenURL:(NSURL *)url{
  for(Class c in oauth2Subclasses){
    SHKOAuth2Sharer *inst = [[[c alloc] init] autorelease];
    if([inst handleOpenURL:url]){
      return YES;
    }
  }
  return NO;
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
  if (![[url absoluteString] hasPrefix:[[self.class redirectURL] absoluteString]]) {
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
