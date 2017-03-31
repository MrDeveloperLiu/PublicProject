#import "NetworkOperation.h"

typedef void (^ HTTPCompletionBlock )(NSURLSessionDataTask *task, NSURLResponse *response, NSData *responseObject);
typedef void (^ HTTPFailedBlock )(NSURLSessionDataTask *task, NSURLResponse *response, NSError *error);

@interface NetworkOperation ()

@property (nonatomic, copy) HTTPCompletionBlock successCallback;
@property (nonatomic, copy) HTTPFailedBlock failedCallback;
@property (nonatomic, strong, readwrite) NSURLSessionDataTask *task;

@end

@implementation NetworkOperation

- (void)dealloc{
    _successCallback = nil;
    _failedCallback = nil;
}

- (void)setFinishBlock:(void (^)(NSURLSessionDataTask *, NSURLResponse *, NSData *))block{
    _successCallback = block;
}

- (void)setFailedBlock:(void (^)(NSURLSessionDataTask *, NSURLResponse *, NSError *))block{
    _failedCallback = block;
}

- (instancetype)initWithBaseURL:(NSString *)baseURL{
    self = [super init];
    if (!self) return nil;
    
    NSURL *url = [NSURL URLWithString:baseURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        if (res.statusCode == 200 && _successCallback) {
            _successCallback(self.task, response, data);
        }
        if (error && _failedCallback) {
            _failedCallback(self.task, response, error);
        }
        
        self.finished = YES;
    }];
    
    return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request{
    self = [super init];
    if (!self) return nil;
    
    self.task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        if (res.statusCode == 200 && _successCallback) {
            _successCallback(self.task, response, data);
        }
        if (error && _failedCallback) {
            _failedCallback(self.task, response, error);
        }
        
        self.finished = YES;
    }];
    
    return self;
}

- (instancetype)initWithSessionTask:(NSURLSessionDataTask *)task{
    self = [super init];
    if (!self) return nil;

    _task = task;
    
    return self;
}

- (void)execute{
    [_task resume];
}

- (void)cancel{
    [super cancel];

    [_task cancel];
    self.executing = NO;
    self.finished = YES;
}

@end
