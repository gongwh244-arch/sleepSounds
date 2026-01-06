#import "DigitalClockViewController.h"
#import "Masonry.h"
#import <CoreText/CoreText.h>

@interface DigitalClockViewController ()

@property(nonatomic, strong) UIView *containerView; // Rotated container
@property(nonatomic, strong) UILabel *hourLabel;
@property(nonatomic, strong) UILabel *minuteLabel;
@property(nonatomic, strong) UILabel *secondLabel;
@property(nonatomic, strong) UILabel *amPmLabel;
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) UILabel *dayLabel;
@property(nonatomic, strong) UIView *batteryView;
@property(nonatomic, strong) UILabel *batteryLevelLabel;
@property(nonatomic, strong) NSTimer *timer;

@property(nonatomic, strong) UIView *hourBox;
@property(nonatomic, strong) UIView *minuteBox;
@property(nonatomic, strong) UIView *secondBox;
@property(nonatomic, strong) UIButton *closeBtn;
@property(nonatomic, strong) UILabel *colonLabel1;
@property(nonatomic, strong) UILabel *colonLabel2;
@property(nonatomic, strong) UIImageView *chargingIcon;
@property(nonatomic, strong) UIView *batteryNub;

@end

@implementation DigitalClockViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 禁用休眠计时器，使屏幕保持常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 页面离开时务必恢复原状，否则会导致 App 全局常亮，极其耗电
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];
  [self setupUI];
  [self startTimer];
  [self updateTime];

  [UIDevice currentDevice].batteryMonitoringEnabled = YES;
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(updateBattery)
             name:UIDeviceBatteryLevelDidChangeNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(updateBattery)
             name:UIDeviceBatteryStateDidChangeNotification
           object:nil];
  [self updateBattery];

  UITapGestureRecognizer *tap =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(handleTap)];
  [self.view addGestureRecognizer:tap];
  [self resetHideTimer];
}

- (void)dealloc {
  [_timer invalidate];
  _timer = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Keep it Portrait to match Info.plist and avoid crash
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
  return YES;
}

- (void)setupUI {
  // Create a container that we will rotate to simulate landscape
  self.containerView = [[UIView alloc] init];
  [self.view addSubview:self.containerView];

  // Rotate 90 degrees and match the screen bounds (swapping width/height)
  CGFloat width = [UIScreen mainScreen].bounds.size.width;
  CGFloat height = [UIScreen mainScreen].bounds.size.height;

  [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.view);
    make.width.mas_equalTo(height);
    make.height.mas_equalTo(width);
  }];

  self.containerView.transform = CGAffineTransformMakeRotation(M_PI_2);

  // All subviews added to containerView from now on

  // Close Button (Top Left in landscape view)
  UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  [closeBtn setImage:[UIImage systemImageNamed:@"xmark"]
            forState:UIControlStateNormal];
  [closeBtn setTintColor:[UIColor whiteColor]];
  [closeBtn addTarget:self
                action:@selector(closeAction)
      forControlEvents:UIControlEventTouchUpInside];
  [self.containerView addSubview:closeBtn];
  self.closeBtn = closeBtn;
  [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.containerView).offset(20);
    make.left.equalTo(self.containerView).offset(40);
    make.width.height.mas_equalTo(44);
  }];

  // Battery Indicator (Top Center)
  self.batteryView = [[UIView alloc] init];
  self.batteryView.layer.borderColor = [UIColor grayColor].CGColor;
  self.batteryView.layer.borderWidth = 1;
  self.batteryView.layer.cornerRadius = 2;
  [self.containerView addSubview:self.batteryView];
  [self.batteryView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.containerView).offset(25);
    make.centerX.equalTo(self.containerView);
    make.width.mas_equalTo(50);
    make.height.mas_equalTo(22);
  }];

  self.batteryNub = [[UIView alloc] init];
  self.batteryNub.backgroundColor = [UIColor grayColor];
  [self.containerView addSubview:self.batteryNub];
  [self.batteryNub mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.batteryView);
    make.left.equalTo(self.batteryView.mas_right);
    make.width.mas_equalTo(3);
    make.height.mas_equalTo(8);
  }];

  self.batteryLevelLabel = [[UILabel alloc] init];
  self.batteryLevelLabel.textColor = [UIColor whiteColor];
  self.batteryLevelLabel.font = [UIFont systemFontOfSize:10
                                                  weight:UIFontWeightBold];
  self.batteryLevelLabel.textAlignment = NSTextAlignmentCenter;
  [self.batteryView addSubview:self.batteryLevelLabel];
  [self.batteryLevelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.batteryView);
  }];

  self.chargingIcon = [[UIImageView alloc]
      initWithImage:[UIImage systemImageNamed:@"bolt.fill"]];
  self.chargingIcon.tintColor = [UIColor colorWithRed:0.2
                                                green:0.9
                                                 blue:0.2
                                                alpha:1.0]; // Greenish
  self.chargingIcon.contentMode = UIViewContentModeScaleAspectFit;
  self.chargingIcon.hidden = YES;
  [self.containerView addSubview:self.chargingIcon];
  [self.chargingIcon mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.batteryView);
    make.right.equalTo(self.batteryView.mas_left).offset(-5);
    make.width.height.mas_equalTo(16);
  }];

  // Clock Container
  UIStackView *clockStack = [[UIStackView alloc] init];
  clockStack.axis = UILayoutConstraintAxisHorizontal;
  clockStack.spacing = 10;
  clockStack.distribution = UIStackViewDistributionFill;
  clockStack.alignment = UIStackViewAlignmentFill;
  [self.containerView addSubview:clockStack];
  [clockStack mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.containerView).centerOffset(CGPointMake(0, -20));
    make.width.equalTo(self.containerView).multipliedBy(0.75);
    make.height.equalTo(self.containerView).multipliedBy(0.45);
  }];

  self.hourBox = [self createTimeBox];
  self.minuteBox = [self createTimeBox];
  self.secondBox = [self createTimeBox];

  self.colonLabel1 = [self createColonLabel];
  self.colonLabel2 = [self createColonLabel];

  [clockStack addArrangedSubview:self.hourBox];
  [clockStack addArrangedSubview:self.colonLabel1];
  [clockStack addArrangedSubview:self.minuteBox];
  [clockStack addArrangedSubview:self.colonLabel2];
  [clockStack addArrangedSubview:self.secondBox];

  // Weights for boxes (1:0:1:0:1 ratio essentially)
  [self.hourBox mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.equalTo(self.minuteBox);
  }];
  [self.secondBox mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.equalTo(self.minuteBox);
  }];
  [self.colonLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.mas_equalTo(20);
  }];
  [self.colonLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.mas_equalTo(20);
  }];

  // AM/PM Label inside hour box
  self.amPmLabel = [[UILabel alloc] init];
  self.amPmLabel.textColor = [UIColor darkGrayColor];
  self.amPmLabel.font = [UIFont boldSystemFontOfSize:14];
  [self.hourBox addSubview:self.amPmLabel];
  [self.amPmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.hourBox).offset(10);
    make.left.equalTo(self.hourBox).offset(10);
  }];

  self.hourLabel = [self createLargeTimeLabelInView:self.hourBox];
  self.minuteLabel = [self createLargeTimeLabelInView:self.minuteBox];
  self.secondLabel = [self createLargeTimeLabelInView:self.secondBox];

  // Bottom bar (Date and Day)
  UIView *bottomBarContainer = [[UIView alloc] init];
  [self.containerView addSubview:bottomBarContainer];
  [bottomBarContainer mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(clockStack.mas_bottom).offset(30);
    make.left.right.equalTo(clockStack);
    make.height.mas_equalTo(60);
  }];

  UIView *line = [[UIView alloc] init];
  line.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
  [bottomBarContainer addSubview:line];
  [line mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(bottomBarContainer);
    make.left.right.equalTo(bottomBarContainer);
    make.height.mas_equalTo(1);
  }];

  self.dayLabel = [[UILabel alloc] init];
  self.dayLabel.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
  self.dayLabel.textColor = [UIColor blackColor];
  self.dayLabel.font = [UIFont boldSystemFontOfSize:22];
  self.dayLabel.textAlignment = NSTextAlignmentCenter;
  self.dayLabel.layer.cornerRadius = 4;
  self.dayLabel.layer.masksToBounds = YES;
  [bottomBarContainer addSubview:self.dayLabel];
  [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(line.mas_bottom).offset(12);
    make.left.equalTo(bottomBarContainer);
    make.width.mas_equalTo(100);
    make.height.mas_equalTo(34);
  }];

  self.dateLabel = [[UILabel alloc] init];
  self.dateLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
  self.dateLabel.font = [UIFont boldSystemFontOfSize:22];
  self.dateLabel.textAlignment = NSTextAlignmentRight;
  [bottomBarContainer addSubview:self.dateLabel];
  [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.dayLabel);
    make.right.equalTo(bottomBarContainer);
  }];
}

- (UIView *)createTimeBox {
  UIView *box = [[UIView alloc] init];
  box.backgroundColor = [UIColor colorWithRed:0.08
                                        green:0.08
                                         blue:0.08
                                        alpha:1.0];
  box.layer.cornerRadius = 15;
  box.layer.masksToBounds = YES;

  UIView *splitLine = [[UIView alloc] init];
  splitLine.backgroundColor = [UIColor blackColor];
  [box addSubview:splitLine];
  [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(box);
    make.left.right.equalTo(box);
    make.height.mas_equalTo(2);
  }];

  return box;
}

- (UILabel *)createLargeTimeLabelInView:(UIView *)parent {
  UILabel *label = [[UILabel alloc] init];
  label.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
  // 使用等宽数字字体，防止数字跳动，设置足够大的字体以充满 Box
//  label.font = [UIFont monospacedDigitSystemFontOfSize:150
//                                                weight:UIFontWeightRegular];
    //-------
//    UIFontDescriptor *systemDescriptor = [UIFont systemFontOfSize:150
//                                                           weight:UIFontWeightBold].fontDescriptor;
//    UIFontDescriptor *roundedDescriptor = [systemDescriptor fontDescriptorWithDesign:UIFontDescriptorSystemDesignRounded];
//    // 2. 为了防止数字跳动，添加等宽数字特性 (Monospaced Numbers)
//    UIFontDescriptor *monospacedDescriptor = [roundedDescriptor fontDescriptorByAddingAttributes:@{
//        UIFontDescriptorFeatureSettingsAttribute: @[@{
//            UIFontFeatureTypeIdentifierKey: @(kNumberSpacingType),
//            UIFontFeatureSelectorIdentifierKey: @(kMonospacedNumbersSelector)
//        }]
//    }];
//    // 3. 应用字体
//    label.font = [UIFont fontWithDescriptor:monospacedDescriptor size:150];
//    label.textColor = [UIColor systemGreenColor]; // 经典的荧光
    //------
    // 1. 使用自定义字体名称（注意：名称是字体文件内部的 PostScript 名称，不一定是文件名）
    UIFont *digitalFont = [UIFont fontWithName:@"digital-7 mono" size:150];
    // 2. 如果该字体支持 OpenType 等宽特性，可以这样设置
    UIFontDescriptor *descriptor = [digitalFont.fontDescriptor fontDescriptorByAddingAttributes:@{
        UIFontDescriptorFeatureSettingsAttribute: @[@{
            UIFontFeatureTypeIdentifierKey: @(kNumberSpacingType),
            UIFontFeatureSelectorIdentifierKey: @(kMonospacedNumbersSelector)
        }]
    }];
    label.font = [UIFont fontWithDescriptor:descriptor size:150];
    
  label.textAlignment = NSTextAlignmentCenter;
  label.adjustsFontSizeToFitWidth = YES;
  label.minimumScaleFactor = 0.5;
  [parent addSubview:label];
  [label mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(parent);
    make.width.equalTo(parent).multipliedBy(0.95);
    make.centerY.equalTo(parent).offset(10);
  }];
  return label;
}

- (UILabel *)createColonLabel {
  UILabel *label = [[UILabel alloc] init];
  label.text = @":";
  label.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
  label.font = [UIFont systemFontOfSize:60 weight:UIFontWeightBold];
  label.textAlignment = NSTextAlignmentCenter;
  return label;
}

- (void)startTimer {
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                target:self
                                              selector:@selector(updateTime)
                                              userInfo:nil
                                               repeats:YES];
}

- (void)updateTime {
  NSDate *now = [NSDate date];
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [calendar
      components:NSCalendarUnitHour | NSCalendarUnitMinute |
                 NSCalendarUnitSecond | NSCalendarUnitWeekday |
                 NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
        fromDate:now];

  NSInteger hour = components.hour;
  NSString *amPm = @"AM";
  if (hour >= 12) {
    amPm = @"PM";
    if (hour > 12)
      hour -= 12;
  } else if (hour == 0) {
    hour = 12;
  }

  self.hourLabel.text = [NSString stringWithFormat:@"%02ld", (long)hour];
  self.minuteLabel.text =
      [NSString stringWithFormat:@"%02ld", (long)components.minute];
  self.secondLabel.text =
      [NSString stringWithFormat:@"%02ld", (long)components.second];
  self.amPmLabel.text = amPm;

  NSArray *weekdays =
      @[ @"", @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六" ];
  self.dayLabel.text = weekdays[components.weekday];

  self.dateLabel.text =
      [NSString stringWithFormat:@"%ld年 %ld月%ld日", (long)components.year, (long)components.month,(long)components.day];

  // Blinking effect for ":"
  CGFloat alpha = (self.colonLabel1.alpha > 0) ? 0.0 : 1.0;
  [UIView animateWithDuration:0.2
                   animations:^{
                     self.colonLabel1.alpha = alpha;
                     self.colonLabel2.alpha = alpha;
                   }];
}

- (void)updateBattery {
  UIDevice *device = [UIDevice currentDevice];
  float level = device.batteryLevel;
  UIDeviceBatteryState state = device.batteryState;

  BOOL isCharging = (state == UIDeviceBatteryStateCharging ||
                     state == UIDeviceBatteryStateFull);
  self.chargingIcon.hidden = !isCharging;

  if (isCharging) {
    UIColor *chargeColor = [UIColor colorWithRed:0.2
                                           green:0.9
                                            blue:0.2
                                           alpha:1.0];
    self.batteryLevelLabel.textColor = chargeColor;
    self.batteryView.layer.borderColor = chargeColor.CGColor;
    self.batteryNub.backgroundColor = chargeColor;
  } else {
    self.batteryLevelLabel.textColor = [UIColor whiteColor];
    self.batteryView.layer.borderColor = [UIColor grayColor].CGColor;
    self.batteryNub.backgroundColor = [UIColor grayColor];
  }

  if (level < 0) {
    self.batteryLevelLabel.text = @"100%";
  } else {
    self.batteryLevelLabel.text =
        [NSString stringWithFormat:@"%d%%", (int)(level * 100)];
  }
}

- (void)handleTap {
  [NSObject cancelPreviousPerformRequestsWithTarget:self
                                           selector:@selector(hideControls)
                                             object:nil];

  if (self.closeBtn.alpha < 1.0) {
    [UIView animateWithDuration:0.3
                     animations:^{
                       self.closeBtn.alpha = 1.0;
                     }];
  }
  [self resetHideTimer];
}

- (void)resetHideTimer {
  [NSObject cancelPreviousPerformRequestsWithTarget:self
                                           selector:@selector(hideControls)
                                             object:nil];
  [self performSelector:@selector(hideControls) withObject:nil afterDelay:2.0];
}

- (void)hideControls {
  [UIView animateWithDuration:0.3
                   animations:^{
                     self.closeBtn.alpha = 0.0;
                   }];
}

- (void)closeAction {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
