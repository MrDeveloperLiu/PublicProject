#import "ChatEmoji.h"

@implementation ChatEmoji

+ (NSArray *)loadEmojiPlist{
    NSString *bp = [[NSBundle mainBundle] pathForResource:@"EmoticonQQ" ofType:@"bundle"];
    NSBundle *b = [NSBundle bundleWithPath:bp];
    NSString *pp = [b pathForResource:@"info" ofType:@"plist"];
    NSArray *retVal = [NSArray arrayWithContentsOfFile:pp];
    return retVal;
}

+ (UIImage *)iconWithKey:(NSString *)key type:(NSString *)type{
    NSString *bp = [[NSBundle mainBundle] pathForResource:@"EmoticonQQ" ofType:@"bundle"];
    NSBundle *b = [NSBundle bundleWithPath:bp];
    NSString *ip = [b pathForResource:key ofType:type];
    UIImage *retVal = [UIImage imageWithContentsOfFile:ip];
    return retVal;
}

@end
