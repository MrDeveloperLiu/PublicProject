#import "BaseOperation.h"

@interface BaseOperation()

@end

@implementation BaseOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (void)execute{}

- (instancetype)init{
    if (self = [super init]) {
        _finished = NO;
        _executing = NO;
    }
    return self;
}

- (void)start{
    if (self.isCancelled) {
        self.finished = YES;
        return;
    }
    [super start];
    
    self.executing = YES;
    
    // never forget the system memory
    @autoreleasepool {  [self execute];  }
}

- (void)main{
    [super main];
    
}

- (void)cancel{
    if (!self.isFinished) {
        return;
    }
    
    [super cancel];
}


- (void)setExecuting:(BOOL)executing{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isAsynchronous{
    return YES;
}
@end
