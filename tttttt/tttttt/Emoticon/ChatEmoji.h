#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ChatEmoji : NSObject

+ (NSArray *)loadEmojiPlist;

/**
 Emoji

 @param key key
 @param type @"png" or @"gif"
 @return UIImage *
 */

//+ (UIImage *)iconWithKey:(NSString *)key type:(NSString *)type;

@end
