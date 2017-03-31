#import <UIKit/UIKit.h>
#import "XMAttributeLabel.h"

@class ChatModel; @protocol ChatTableViewCellDelegate;
@interface ChatTableViewCell : UITableViewCell

@property (nonatomic, weak) id<ChatTableViewCellDelegate> delegate;
@property (nonatomic, strong) ChatModel *model;

@end


@protocol ChatTableViewCellDelegate <NSObject>
- (void)chatCell:(ChatTableViewCell *)cell itemDidClicked:(XMAttributeItem *)item;
@end


typedef enum {
    ChatTypeText = 1,
    ChatTypeEmoji,
    ChatTypeVoice,
    ChatTypeVideo,
    ChatTypeLink
}ChatType;

typedef enum {
    ChatObjectMe,
    ChatObjectOthers,
    ChatObjectGroup
}ChatObject;

@interface ChatModel : NSObject

@property (nonatomic, assign) NSUInteger messageID;
@property (nonatomic, copy) NSString *dest;

//it can be anything likes content, image, or voice, video, etc..
@property (nonatomic, strong) id content;

@property (nonatomic, assign) ChatType type;
@property (nonatomic, assign) ChatObject object;

@property (nonatomic, assign) CGFloat rowHeight;
@end


#define key "\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"

@interface ChatAutoMojiParser : NSObject

+ (NSArray <XMAttributeItem *> *)parserEmoji:(NSString *)text;

@end
