//
//  SHKSharer+MultipartPost.m
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

#import "SHKSharer+MultipartPost.h"

NSString *const kSHKMimeBoundary = @"sendingmimeisreallyfun";

@implementation SHKSharer (MultipartPost)

- (void)addMultipartContentHeader:(NSMutableURLRequest *)req{
  [req setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",
                 kSHKMimeBoundary] forHTTPHeaderField:@"Content-Type"];
  [req setHTTPMethod:@"POST"];
}

- (void)addMimeBoundary:(NSMutableData *)body{
  NSString *boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n", kSHKMimeBoundary];
  [body appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)addFinalMimeBoundary:(NSMutableData *)body{
  NSString *finalBoundary = [NSString stringWithFormat:@"\r\n--%@--\r\n", kSHKMimeBoundary]; 
  [body appendData:[finalBoundary dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)addParameter:(NSString *)param withValue:(NSString *)val toBody:(NSMutableData *)body{
  
  [self addMimeBoundary:body];
  NSString *partHeader = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",
                          param];
  [body appendData:[partHeader dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[val dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)addImageMimePart:(UIImage *)image toBody:(NSMutableData *)body{
  [self addMimeBoundary:body];
  NSString *header = @"Content-Disposition: form-data; name=\"media\"; filename=\"upload.jpg\"\r\n";
  NSString *enc = @"Content-Transfer-Encoding: image/jpg\r\n\r\n";
  [body appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[enc dataUsingEncoding:NSUTF8StringEncoding]];
  
  [body appendData:UIImageJPEGRepresentation(image, 0.9)];
}

@end
