#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PlayerControlDelegate <NSObject>
- (void)didTapPlayPause;
- (void)didTapTimer;
@end

@interface PlayerControlView : UIView

+ (instancetype)sharedInstance;
+ (void)showGlobalControlBar;

@property(nonatomic, weak) id<PlayerControlDelegate> delegate;
@property(nonatomic, assign) BOOL isPlaying;

@end

NS_ASSUME_NONNULL_END
