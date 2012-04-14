//
//  APIClient.m
//  CoreAnimation
//
//  Created by 将司 小野 on 12/04/14.
//  Copyright (c) 2012年 AppBankGames Inc. All rights reserved.
//

#import "APIClient.h"
#import "APIRequest.h"


static NSString * const APIClientErrorDomain = @"APIClientErrorDomain";
static NSTimeInterval APIClientDefaultTimeout = 15.0;


#pragma mark -


@interface APIClientResponse()

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) id responseObject;

@end

@implementation APIClientResponse

@synthesize statusCode = _statusCode;
@synthesize error = _error;
@synthesize responseObject = _responseObject;

- (id)initWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *)error
{
    self = [super init];
    if (self) {
        self.statusCode = response.statusCode;
        self.error = error;
        self.responseObject = data;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: 0x%x; %d%@%@>",
            NSStringFromClass([self class]),
            [self hash],
            self.statusCode,
            (self.responseObject) ? @" (has response)" : @"",
            (self.error) ? @" (has error)" : @""];
}

@end


#pragma mark -


@interface APIClient () <APIRequestDelegate>

@property (nonatomic, retain) NSMutableDictionary *requestDictionary;
@property (nonatomic, retain) NSMutableDictionary *callbackDictionary;

- (NSString *)__encodedURLString:(NSString *)string;
- (NSData *)__URLEncodedPostBodyFromParameters:(NSDictionary *)parameters;
- (NSMutableURLRequest *)__GETRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters;
- (NSMutableURLRequest *)__POSTRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters;
- (NSString *)__startAPIRequest:(APIRequest *)apiRequest callback:(APIClientCallback)callback;

@end


@implementation APIClient


@synthesize requestDictionary = _requestDictionary;
@synthesize callbackDictionary = _callbackDictionary;


#pragma mark - Init/dealloc


- (id)init
{
    self = [super init];
    if (self) {
        self.requestDictionary = [NSMutableDictionary dictionary];
        self.callbackDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    [self cancelAllRequest];
    self.requestDictionary = nil;
    self.callbackDictionary = nil;
    [super dealloc];
}


#pragma mark - Private


- (NSString*)__encodedURLString:(NSString *)string
{
	NSString *newString = [NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))) autorelease];
	if (newString) {
		return newString;
	}
	return @"";
}

- (NSString *)__URLEncodedQueryStringFromParameters:(NSDictionary *)parameters
{
    NSMutableString *buffer = [NSMutableString string];
    __block NSUInteger i=0;
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        [buffer appendFormat:@"%@%@=%@", (i==0 ? @"?" : @"&"), [self __encodedURLString:key], [self __encodedURLString:value]]; 
        i++;
    }];
    return [NSString stringWithString:buffer];
}

- (NSData *)__URLEncodedPostBodyFromParameters:(NSDictionary *)parameters
{
    NSMutableString *buffer = [NSMutableString string];
	NSUInteger count = [parameters count]-1;
	__block NSUInteger i=0;
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        [buffer appendFormat:@"%@=%@%@", [self __encodedURLString:key], [self __encodedURLString:value],(i<count ? @"&":@"")];
        i++;
    }];
    return [buffer dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
}

- (NSMutableURLRequest *)__GETRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[url absoluteString] stringByAppendingString:[self __URLEncodedQueryStringFromParameters:parameters]]]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:APIClientDefaultTimeout];
    [request setHTTPMethod:@"GET"];
    return request;
}

- (NSMutableURLRequest *)__POSTRequestWithURL:(NSURL *)url parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:APIClientDefaultTimeout];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self __URLEncodedPostBodyFromParameters:parameters]];
    [request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    return request;
}

- (NSString *)__startAPIRequest:(APIRequest *)apiRequest callback:(APIClientCallback)callback
{
    apiRequest.delegate = self;
    @synchronized(self) {
        if ([apiRequest start]) {
            [self.requestDictionary setObject:apiRequest forKey:apiRequest.requestIdentifier];
            [self.callbackDictionary setObject:callback forKey:apiRequest.requestIdentifier];
            //[self.callbackDictionary setObject:[callback copy] forKey:apiRequest.requestIdentifier];
            return apiRequest.requestIdentifier;
        } else {
            return nil;
        }
    }
    return nil;
}


#pragma mark - APIRequest


- (void)apiRequest:(APIRequest *)apiRequest didFinishWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data
{
    @synchronized(self) {
        apiRequest.delegate = nil;
        APIClientResponse *clientResponse = [[[APIClientResponse alloc] initWithResponse:response data:data error:nil] autorelease];
        APIClientCallback callback = [self.callbackDictionary objectForKey:apiRequest.requestIdentifier];
        callback(clientResponse);
        //[callback release];
        [self.requestDictionary removeObjectForKey:apiRequest.requestIdentifier];
        [self.callbackDictionary removeObjectForKey:apiRequest.requestIdentifier];
    }
}

- (void)apiRequest:(APIRequest *)apiRequest didFailWithError:(NSError *)error
{
    @synchronized(self) {
        apiRequest.delegate = nil;
        APIClientResponse *clientResponse = [[[APIClientResponse alloc] initWithResponse:nil data:nil error:error] autorelease];
        APIClientCallback callback = [self.callbackDictionary objectForKey:apiRequest.requestIdentifier];
        callback(clientResponse);
        //[callback release];
        [self.requestDictionary removeObjectForKey:apiRequest.requestIdentifier];
        [self.callbackDictionary removeObjectForKey:apiRequest.requestIdentifier];
    }
}


#pragma mark - Public


- (void)cancelAllRequest
{
    @synchronized(self) {
        [self.requestDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
            APIRequest *apiRequest = object;
            apiRequest.delegate = nil;
            [apiRequest cancel];
        }];
        [self.requestDictionary removeAllObjects];
        [self.callbackDictionary removeAllObjects];
    }
}

- (void)cancelRequestWithIdentifier:(NSString *)requestIdentifier
{
    @synchronized(self) {
        APIRequest *apiRequest = [self.requestDictionary objectForKey:requestIdentifier];
        if (apiRequest) {
            apiRequest.delegate = nil;
            [apiRequest cancel];
            [self.requestDictionary removeObjectForKey:requestIdentifier];
            [self.callbackDictionary removeObjectForKey:requestIdentifier];
        }
    }
}

- (NSString *)api_google:(NSDictionary *)parameters callback:(APIClientCallback)callback
{
    NSURL *baseURL = [NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request = [self __GETRequestWithURL:baseURL parameters:parameters];
    APIRequest *apiRequest = [APIRequest apiRequestWithRequest:request];
    apiRequest.timeoutTimerInterval = APIClientDefaultTimeout;
    return [self __startAPIRequest:apiRequest callback:callback];
}

@end