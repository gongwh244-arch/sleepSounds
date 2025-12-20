#import "PlayerControlView.h"
#import "../Managers/AudioPlayerManager.h"
#import "Masonry.h"
#import <UIKit/UIKit.h>

@interface PlayerControlView ()
@property(nonatomic, strong) UIButton *playPauseButton;
@property(nonatomic, strong) UIButton *timerButton;
@property(nonatomic, strong) NSTimer *displayTimer;
@end

static UIWindow *g_playerControlWindow = nil;

@implementation PlayerControlView

+ (instancetype)sharedInstance {
  static PlayerControlView *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] initWithFrame:CGRectZero];
  });
  return sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
    [self startDisplayTimer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTimerExpired)
                                                 name:@"AudioTimerExpired"
                                               object:nil];
  }
  return self;
}

- (void)startDisplayTimer {
  if (self.displayTimer) {
    [self.displayTimer invalidate];
    self.displayTimer = nil;
  }
  self.displayTimer =
      [NSTimer scheduledTimerWithTimeInterval:1.0
                                       target:self
                                     selector:@selector(updateTimerDisplay)
                                     userInfo:nil
                                      repeats:YES];
}

- (void)updateTimerDisplay {
  NSTimeInterval remaining = [[AudioPlayerManager sharedManager] remainingTime];

  if (remaining > 0) {
    int hours = (int)(remaining / 3600);
    int minutes = (int)((remaining - hours * 3600) / 60);
    int seconds = (int)(remaining - hours * 3600 - minutes * 60);
    NSString *timeStr = [NSString
        stringWithFormat:@"%02d时%02d分%02d秒", hours, minutes, seconds];

    // 优化：仅在内容变化时更新，并禁用默认动画，防止闪烁
    if (![[self.timerButton titleForState:UIControlStateNormal]
            isEqualToString:timeStr]) {
      [UIView performWithoutAnimation:^{
        [self.timerButton setTitle:timeStr forState:UIControlStateNormal];
        if ([self.timerButton imageForState:UIControlStateNormal]) {
          [self.timerButton setImage:nil forState:UIControlStateNormal];
        }
        self.timerButton.titleLabel.font =
            [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        [self.timerButton layoutIfNeeded];
      }];
    }
  } else {
    // 恢复初始状态
    if ([self.timerButton titleForState:UIControlStateNormal] != nil) {
      [UIView performWithoutAnimation:^{
        [self.timerButton setTitle:nil forState:UIControlStateNormal];
        [self.timerButton setImage:[UIImage systemImageNamed:@"timer"]
                          forState:UIControlStateNormal];
        [self.timerButton layoutIfNeeded];
      }];
    }
  }
}

- (void)setupUI {
  self.backgroundColor = [UIColor colorWithRed:0.2
                                         green:0.8
                                          blue:0.2
                                         alpha:0.9]; // Bright Green
  self.layer.cornerRadius = 30;
  self.layer.masksToBounds = YES;

  // Play/Pause Button
  _playPauseButton = [self createButtonWithImage:@"play.fill"
                                          action:@selector(playPauseTapped)];

  // Timer Button
  _timerButton = [self createButtonWithImage:@"timer"
                                      action:@selector(timerTapped)];

  // Stack View
  UIStackView *stack = [[UIStackView alloc]
      initWithArrangedSubviews:@[ _playPauseButton, _timerButton ]];
  stack.axis = UILayoutConstraintAxisHorizontal;
  stack.distribution = UIStackViewDistributionFillEqually;
  [self addSubview:stack];
  [stack mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self);
  }];
}

- (UIButton *)createButtonWithImage:(NSString *)imageName action:(SEL)action {
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
  [btn setImage:[UIImage systemImageNamed:imageName]
       forState:UIControlStateNormal];
  [btn setTintColor:[UIColor whiteColor]];
  [btn addTarget:self
                action:action
      forControlEvents:UIControlEventTouchUpInside];
  return btn;
}

#pragma mark - Actions

- (void)playPauseTapped {
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(didTapPlayPause)]) {
    [self.delegate didTapPlayPause];
  }
}

- (void)timerTapped {
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(didTapTimer)]) {
    [self.delegate didTapTimer];
  }
}

- (void)setIsPlaying:(BOOL)isPlaying {
  _isPlaying = isPlaying;
  NSString *imgName = isPlaying ? @"pause.fill" : @"play.fill";
  [_playPauseButton setImage:[UIImage systemImageNamed:imgName]
                    forState:UIControlStateNormal];
}

- (void)handleTimerExpired {
  dispatch_async(dispatch_get_main_queue(), ^{
    self.isPlaying = NO;
    [self updateTimerDisplay]; // Ensure timer button resets as well
  });
}

#pragma mark - Global Control

+ (void)showGlobalControlBar {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    g_playerControlWindow =
        [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    g_playerControlWindow.windowLevel = UIWindowLevelAlert + 100;
    g_playerControlWindow.backgroundColor = [UIColor clearColor];

    // 创建一个简单的根视图控制器来承载控制条
    UIViewController *rootVC = [[UIViewController alloc] init];
    rootVC.view.backgroundColor = [UIColor clearColor];
    g_playerControlWindow.rootViewController = rootVC;

    PlayerControlView *playerControl = [PlayerControlView sharedInstance];
    [rootVC.view addSubview:playerControl];

    [playerControl mas_makeConstraints:^(MASConstraintMaker *make) {
      make.centerX.equalTo(rootVC.view);
      make.width.mas_equalTo(220); // 稍微加宽一点看上去更和谐
      make.bottom.equalTo(rootVC.view.mas_bottom)
          .offset(-20 - [UIDevice kd_tabBarFullHeight]);
      make.height.mas_equalTo(60);
    }];

    g_playerControlWindow.hidden = NO;
  });
}

// 触摸穿透处理：如果点击不在控制条内，则允许事件传递给底层的 window
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  UIView *view = [super hitTest:point withEvent:event];
  if (view == self) {
    // 如果是点击了控制条内部的空隙, 也要拦截
    return view;
  }
  // 子视图(按钮等)已经由 super 处理了
  return view;
}

@end

@implementation UIWindow (PlayerControlTouchThrough)
// 扩展 UIWindow 处理，确保全局 Window 只拦截它想要拦截的区域
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  if (self == g_playerControlWindow) {
    PlayerControlView *playerControl = [PlayerControlView sharedInstance];
    CGPoint pointInView = [playerControl convertPoint:point fromView:self];
    if ([playerControl pointInside:pointInView withEvent:event]) {
      return [super hitTest:point withEvent:event];
    }
    return nil; // 穿透
  }
  return [super hitTest:point withEvent:event];
}
@end
