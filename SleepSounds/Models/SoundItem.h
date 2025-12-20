#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SoundItem : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *iconName;
@property(nonatomic, copy) NSString *category; // "sleep", "baby"
@property(nonatomic, copy)
    NSString *subCategory; // "shush", "white_noise", "nature"
@property(nonatomic, copy) NSString *fileName; // Bundle Resource Name
@property(nonatomic, assign) BOOL isLocked;    // VIP Feature
@property(nonatomic, assign) BOOL isPlaying;   // State

- (instancetype)initWithName:(NSString *)name
                    iconName:(NSString *)iconName
                    isLocked:(BOOL)isLocked;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
