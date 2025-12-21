//
//  ViewController.m
//  SleepSounds
//
//  Created by 龚伟强 on 2025/12/19.
//

#import "WQViewController.h"

@interface WQViewController ()

@end

@implementation WQViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (void)showToast:(NSString *)message {
  UILabel *label = [[UILabel alloc] init];
  label.text = message;
  label.textColor = [UIColor whiteColor];
  label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
  label.textAlignment = NSTextAlignmentCenter;
  label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
  label.layer.cornerRadius = 20;
  label.layer.masksToBounds = YES;

  [self.view addSubview:label];
  [label mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.view);
    make.width.mas_greaterThanOrEqualTo(200);
    make.height.mas_equalTo(40);
  }];

  label.alpha = 0.0;
  [UIView animateWithDuration:0.3
      animations:^{
        label.alpha = 1.0;
      }
      completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3
            delay:2.0
            options:0
            animations:^{
              label.alpha = 0.0;
            }
            completion:^(BOOL finished) {
              [label removeFromSuperview];
            }];
      }];
}

@end
