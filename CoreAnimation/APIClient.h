//
//  APIClient.h
//  CoreAnimation
//
//  Created by 将司 小野 on 12/04/14.
//  Copyright (c) 2012年 AppBankGames Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class APIClient;
@class APIClientResponse;


typedef void (^APIClientCallback)(APIClientResponse *);


#pragma mark -


@interface APIClientResponse : NSObject

@property (nonatomic, assign, readonly) NSInteger statusCode;
@property (nonatomic, retain, readonly) NSError *error;
@property (nonatomic, retain, readonly) id responseObject;

- (id)initWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *)error;

@end


#pragma mark -


@interface APIClient : NSObject


#pragma mark - Public


- (void)cancelAllRequest;
- (void)cancelRequestWithIdentifier:(NSString *)requestIdentifier;


#pragma mark - Login


- (NSString *)api_google:(NSDictionary *)parameters callback:(APIClientCallback)callback;


@end
