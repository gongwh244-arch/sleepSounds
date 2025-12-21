#import "PlayerControlView.h"
#import "../Managers/AudioPlayerManager.h"
#import "Masonry.h"
#import <UIKit/UIKit.h>

@interface PlayerControlView ()
@property(nonatomic, strong) UIButton *playPauseButton;
@property(nonatomic, strong) UIButton *timerButton;
@property(nonatomic, strong) NSTimer *displayTimer;
@end

@implementation PlayerControlView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
    [self startDisplayTimer];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
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
    int minutes = (int)(remaining / 60);
    int seconds = (int)(remaining - minutes * 60);
    NSString *timeStr =
        [NSString stringWithFormat:@"%02d分%02d秒", minutes, seconds];

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

  // Divider Line
  UIView *divider = [[UIView alloc] init];
  divider.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];

  // Stack View
  UIStackView *stack = [[UIStackView alloc]
      initWithArrangedSubviews:@[ _playPauseButton, divider, _timerButton ]];
  stack.axis = UILayoutConstraintAxisHorizontal;
  stack.alignment = UIStackViewAlignmentCenter;
  [self addSubview:stack];

  [stack mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self);
  }];

  [divider mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.mas_equalTo(1);
    make.height.mas_equalTo(30);
  }];

  [_playPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.height.equalTo(stack);
  }];

  [_timerButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.height.equalTo(stack);
    make.width.equalTo(_playPauseButton);
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

@end
