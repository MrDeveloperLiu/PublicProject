#import <Foundation/Foundation.h>

@interface BaseOperation : NSOperation {
    BOOL _finished;
    BOOL _executing;
}

@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, assign, getter=isExecuting) BOOL executing;


- (void)start;//start if you call super then '- execute' will be execute
- (void)main; //ready for sth
- (void)cancel;//do that you really to cacel
/**
 *  for subclass hooks
 */
- (void)execute;

@end
