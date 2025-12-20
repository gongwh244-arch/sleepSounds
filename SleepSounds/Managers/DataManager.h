#import "../Models/SoundItem.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject

+ (instancetype)sharedManager;

- (void)fetchSoundsForCategory:(NSString *)category
                    completion:(void (^)(NSArray<SoundItem *> *items,
                                         NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
