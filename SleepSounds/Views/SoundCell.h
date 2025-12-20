#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SoundCell : UICollectionViewCell

@property(nonatomic, strong) UIImageView *iconImageView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UIImageView *lockIconView;
@property(nonatomic, assign) BOOL isLocked;
@property(nonatomic, assign) BOOL isPlaying;

- (void)configureWithIcon:(NSString *)iconName
                     name:(NSString *)name
                 isLocked:(BOOL)isLocked;

@end

NS_ASSUME_NONNULL_END
