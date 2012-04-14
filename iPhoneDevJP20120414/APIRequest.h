//
//  APIRequest.h
//  iPhoneDevJP20120414
//
//  Created by 将司 小野 on 12/04/14.
//  Copyright (c) 2012年 AppBankGames Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class APIRequest;


@protocol APIRequestDelegate <NSObject>
@optional
- (void)apiRequest:(APIRequest *)apiRequest didFinishWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data;
- (void)apiRequest:(APIRequest *)apiRequest didFailWithError:(NSError *)error;
@end


#pragma mark -


@interface APIRequest : NSObject

@property (nonatomic, assign) id<APIRequestDelegate> delegate;
@property (nonatomic, copy, readonly) NSString *requestIdentifier;
@property (nonatomic, assign) NSTimeInterval timeoutTimerInterval;

+ (APIRequest *)apiRequestWithRequest:(NSURLRequest *)request;
- (id)initWithRequest:(NSURLRequest *)request;

- (BOOL)start;
- (void)cancel;

@end
