#import "BreathingViewController.h"

@interface BreathingViewController ()

@property(nonatomic, strong) UIView *circleView;
@property(nonatomic, strong) UILabel *instructionLabel;
@property(nonatomic, assign) BOOL isBreathing;

@end

@implementation BreathingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor colorWithRed:0.05
                                              green:0.1
                                               blue:0.15
                                              alpha:1.0];

  // Title
  UILabel *titleLabel = [[UILabel alloc]
      initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 30)];
  titleLabel.text = @"Deep Breathing";
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.textAlignment = NSTextAlignmentCenter;
  titleLabel.font = [UIFont boldSystemFontOfSize:24];
  [self.view addSubview:titleLabel];

  // Circle View
  CGFloat size = 150;
  self.circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
  self.circleView.center = self.view.center;
  self.circleView.backgroundColor = [UIColor colorWithRed:0.4
                                                    green:0.8
                                                     blue:0.9
                                                    alpha:0.3];
  self.circleView.layer.cornerRadius = size / 2;
  self.circleView.layer.borderWidth = 4;
  self.circleView.layer.borderColor =
      [UIColor colorWithRed:0.4 green:0.8 blue:0.9 alpha:0.8].CGColor;
  [self.view addSubview:self.circleView];

  // Instruction Label
  self.instructionLabel = [[UILabel alloc]
      initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
  self.instructionLabel.center =
      CGPointMake(self.view.center.x, self.view.center.y + 150);
  self.instructionLabel.text = @"Ready?";
  self.instructionLabel.textColor = [UIColor whiteColor];
  self.instructionLabel.textAlignment = NSTextAlignmentCenter;
  self.instructionLabel.font = [UIFont systemFontOfSize:20
                                                 weight:UIFontWeightMedium];
  [self.view addSubview:self.instructionLabel];

  // Close Button
  UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
  closeBtn.frame = CGRectMake(self.view.bounds.size.width - 60, 40, 44, 44);
  [closeBtn setImage:[UIImage systemImageNamed:@"xmark.circle.fill"]
            forState:UIControlStateNormal];
  [closeBtn setTintColor:[UIColor whiteColor]];
  [closeBtn addTarget:self
                action:@selector(dismissSelf)
      forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:closeBtn];

  [self startBreathingAnimation];
}

- (void)startBreathingAnimation {
  self.isBreathing = YES;
  [self animateInhale];
}

- (void)animateInhale {
  if (!self.isBreathing)
    return;

  self.instructionLabel.text = @"Inhale...";
  [UIView animateWithDuration:4.0
      delay:0
      options:UIViewAnimationOptionCurveEaseInOut
      animations:^{
        self.circleView.transform = CGAffineTransformMakeScale(2.0, 2.0);
        self.circleView.backgroundColor = [UIColor colorWithRed:0.4
                                                          green:0.8
                                                           blue:0.9
                                                          alpha:0.6];
      }
      completion:^(BOOL finished) {
        if (finished) {
          [self animateHold];
        }
      }];
}

- (void)animateHold {
  if (!self.isBreathing)
    return;

  self.instructionLabel.text = @"Hold...";
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        [self animateExhale];
      });
}

- (void)animateExhale {
  if (!self.isBreathing)
    return;

  self.instructionLabel.text = @"Exhale...";
  [UIView animateWithDuration:4.0
      delay:0
      options:UIViewAnimationOptionCurveEaseInOut
      animations:^{
        self.circleView.transform = CGAffineTransformIdentity;
        self.circleView.backgroundColor = [UIColor colorWithRed:0.4
                                                          green:0.8
                                                           blue:0.9
                                                          alpha:0.3];
      }
      completion:^(BOOL finished) {
        if (finished) {
          [self animateInhale]; // Loop
        }
      }];
}

- (void)dismissSelf {
  self.isBreathing = NO;
  [self.circleView.layer removeAllAnimations];
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
