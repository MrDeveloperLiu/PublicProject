#import "BaseOperation.h"

@interface NetworkOperation : BaseOperation

@property (nonatomic, strong, readonly) NSURLSessionDataTask *task;

- (instancetype)initWithBaseURL:(NSString *)baseURL;
- (instancetype)initWithRequest:(NSURLRequest *)request;
- (instancetype)initWithSessionTask:(NSURLSessionDataTask *)task;

- (void)setFinishBlock:( void (^)(NSURLSessionDataTask *task, NSURLResponse *response, NSData *responseObject) )block;
- (void)setFailedBlock:( void (^)(NSURLSessionDataTask *task, NSURLResponse *response, NSError *error) )block;

@end
