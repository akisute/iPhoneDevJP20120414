//
//  APIRequest.m
//  iPhoneDevJP20120414
//
//  Created by 将司 小野 on 12/04/14.
//  Copyright (c) 2012年 AppBankGames Inc. All rights reserved.
//

#import "APIRequest.h"


@interface APIRequest ()

@property (nonatomic, copy) NSString *requestIdentifier;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSHTTPURLResponse *response;
@property (nonatomic, retain) NSMutableData *downloadBuffer;
@property (nonatomic, retain) NSTimer *timeoutTimer;

@end


#pragma mark -


@implementation APIRequest

@synthesize delegate = _delegate;
@synthesize requestIdentifier = _requestIdentifier;
@synthesize timeoutTimerInterval = _timeoutTimerInterval;

@synthesize connection = _connection;
@synthesize response = _response;
@synthesize downloadBuffer = _downloadBuffer;
@synthesize timeoutTimer = _timeoutTimer;


#pragma mark - Init/dealloc


+ (APIRequest *)apiRequestWithRequest:(NSURLRequest *)request
{
    return [[[self alloc] initWithRequest:request] autorelease];
}

- (id)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    if (self) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
        [uuidString autorelease];
        CFRelease(uuidRef);
        self.requestIdentifier = uuidString;
        self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO] autorelease];
        self.timeoutTimerInterval = 0;
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    [self cancel];
    [self.timeoutTimer invalidate];
    
    self.requestIdentifier = nil;
    self.timeoutTimerInterval = 0;
    self.connection = nil;
    self.response = nil;
    self.downloadBuffer = nil;
    self.timeoutTimer = nil;
    
    [super dealloc];
}


#pragma mark - Public


- (BOOL)start
{
    if (self.connection == nil) {
        // Request is already used/cancelled
        return NO;
    }
    // dispatch_asyncとか使って別runloop(thread)からscheduleしたほうがよい？大丈夫？
    // -> 多分大丈夫だとは思う、ここでscheduleするrunloop(thread)はdelegateがコールバックを受けとるrunloop(thread)なので
    // -> でもmain runloopなんかでdownloadBufferの構築とかあんまやりたくねえよね・・・
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [self.connection scheduleInRunLoop:runloop forMode:NSDefaultRunLoopMode];
    [self.connection start];
    
    // NSURLConnectionのPOST時は240秒以下のtimeoutが効かないクソ仕様なので別途timeout監視タイマーを用意せざるを得ない
    if (self.timeoutTimerInterval > 0) {
        NSError *timeoutError = [NSError errorWithDomain:NSURLErrorDomain
                                                    code:NSURLErrorTimedOut
                                                userInfo:[NSDictionary dictionaryWithObject:@"The request timed out." forKey:NSLocalizedDescriptionKey]];
        self.timeoutTimer = [NSTimer timerWithTimeInterval:self.timeoutTimerInterval
                                                    target:self
                                                  selector:@selector(timerFireMethod:)
                                                  userInfo:timeoutError
                                                   repeats:NO];
        [self.timeoutTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.timeoutTimerInterval]];
        [runloop addTimer:self.timeoutTimer forMode:NSDefaultRunLoopMode];
    }
    
    return YES;
}

- (void)cancel
{
    [self.connection cancel];
    self.connection = nil;
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}


#pragma mark - NSURLConnectionDelegate


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSAssert([response isKindOfClass:[NSHTTPURLResponse class]], @"");
    self.response = (NSHTTPURLResponse *)response;
    self.downloadBuffer = (response.expectedContentLength == NSURLResponseUnknownLength) ? [NSMutableData data] : [NSMutableData dataWithCapacity:response.expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.downloadBuffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([self.delegate respondsToSelector:@selector(apiRequest:didFinishWithResponse:data:)]) {
        [self.delegate apiRequest:self didFinishWithResponse:self.response data:[NSData dataWithData:self.downloadBuffer]];
    }
    self.connection = nil;
    self.response = nil;
    self.downloadBuffer = nil;
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(apiRequest:didFailWithError:)]) {
        [self.delegate apiRequest:self didFailWithError:error];
    }
    self.connection = nil;
    self.response = nil;
    self.downloadBuffer = nil;
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}


#pragma mark - NSTimer


- (void)timerFireMethod:(NSTimer*)theTimer
{
    [self connection:self.connection didFailWithError:theTimer.userInfo];
}

@end
