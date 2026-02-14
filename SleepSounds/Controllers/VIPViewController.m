#import "VIPViewController.h"
#import "../Managers/SSStoreManager.h"
#import "Masonry.h"

@interface VIPViewController ()

@property(nonatomic, strong) UIButton *closeButton;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subtitleLabel;
@property(nonatomic, strong) UIView *featureListView;
@property(nonatomic, strong) UIButton *purchaseButton;
@property(nonatomic, strong) UIButton *restoreButton;
@property(nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@end

@implementation VIPViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupUI];

  // Check VIP status
  if ([SSStoreManager sharedManager].isVIP) {
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
  }

  // Fetch Product Info
  [self.loadingIndicator startAnimating];
  self.purchaseButton.enabled = NO;
  [self.purchaseButton setTitle:@"Loading..." forState:UIControlStateNormal];

  __weak typeof(self) weakSelf = self;
  [[SSStoreManager sharedManager]
      fetchProductWithCompletion:^(BOOL success, NSString *price) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf.loadingIndicator stopAnimating];
          if (success && price) {
            [weakSelf.purchaseButton
                setTitle:[NSString stringWithFormat:@"Upgrade for %@", price]
                forState:UIControlStateNormal];
            weakSelf.purchaseButton.enabled = YES;
          } else {
            [weakSelf.purchaseButton setTitle:@"Upgrade VIP"
                                     forState:UIControlStateNormal];
            weakSelf.purchaseButton.enabled = YES;
          }
        });
      }];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(handleVIPStatusChanged)
             name:SSVIPStatusChangedNotification
           object:nil];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
  self.view.backgroundColor = [UIColor colorWithRed:0.05
                                              green:0.05
                                               blue:0.1
                                              alpha:1.0];

  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = self.view.bounds;
  gradient.colors = @[
    (id)[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:0.05 green:0.05 blue:0.15 alpha:1.0].CGColor
  ];
  [self.view.layer insertSublayer:gradient atIndex:0];

  // Close Button
  self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.closeButton setImage:[UIImage systemImageNamed:@"xmark.circle.fill"]
                    forState:UIControlStateNormal];
  [self.closeButton setTintColor:[UIColor lightGrayColor]];
  [self.closeButton addTarget:self
                       action:@selector(closeAction)
             forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.closeButton];
  [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
    if (@available(iOS 11.0, *)) {
      make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(10);
    } else {
      make.top.equalTo(self.view.mas_top).offset(30);
    }
    make.right.equalTo(self.view.mas_right).offset(-20);
    make.width.mas_equalTo(40);
    make.height.mas_equalTo(40);
  }];

  // Title
  self.titleLabel = [[UILabel alloc] init];
  self.titleLabel.text = @"解锁全能 VIP";
  self.titleLabel.textColor = [UIColor whiteColor];
  self.titleLabel.font = [UIFont boldSystemFontOfSize:32];
  self.titleLabel.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview:self.titleLabel];
  [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.closeButton.mas_bottom).offset(30);
    make.centerX.equalTo(self.view);
  }];

  // Subtitle
  self.subtitleLabel = [[UILabel alloc] init];
  self.subtitleLabel.text = @"无限访问所有助眠音效与功能";
  self.subtitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
  self.subtitleLabel.font = [UIFont systemFontOfSize:16];
  self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview:self.subtitleLabel];
  [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
    make.centerX.equalTo(self.view);
  }];

  // Purchase Button
  self.purchaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.purchaseButton setTitle:@"立即升级 VIP" forState:UIControlStateNormal];
  [self.purchaseButton setBackgroundColor:[UIColor colorWithRed:1.0
                                                          green:0.5
                                                           blue:0.0
                                                          alpha:1.0]];
  self.purchaseButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
  self.purchaseButton.layer.cornerRadius = 25;
  [self.purchaseButton addTarget:self
                          action:@selector(purchaseAction)
                forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.purchaseButton];
  [self.purchaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
    if (@available(iOS 11.0, *)) {
      make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-80);
    } else {
      make.bottom.equalTo(self.view.mas_bottom).offset(-80);
    }
    make.left.equalTo(self.view.mas_left).offset(40);
    make.right.equalTo(self.view.mas_right).offset(-40);
    make.height.mas_equalTo(50);
  }];

  // Restore Button
  self.restoreButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.restoreButton setTitle:@"恢复购买" forState:UIControlStateNormal];
  [self.restoreButton setTintColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
  [self.restoreButton addTarget:self
                         action:@selector(restoreAction)
               forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.restoreButton];
  [self.restoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.purchaseButton.mas_bottom).offset(20);
    make.centerX.equalTo(self.view);
  }];

  // Feature List
  [self setupFeatureList];

  // Loading Indicator
  self.loadingIndicator = [[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
  self.loadingIndicator.color = [UIColor whiteColor];
  self.loadingIndicator.hidesWhenStopped = YES;
  [self.view addSubview:self.loadingIndicator];
  [self.loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.view);
  }];
}

- (void)setupFeatureList {
  self.featureListView = [[UIView alloc] init];
  [self.view addSubview:self.featureListView];
  [self.featureListView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.subtitleLabel.mas_bottom).offset(30);
    make.left.right.equalTo(self.view);
    make.bottom.equalTo(self.purchaseButton.mas_top).offset(-20);
  }];

  NSArray *features = @[
    @{@"icon" : @"music.note.list", @"text" : @"解锁 100+ 精选音效"},
    @{@"icon" : @"timer", @"text" : @"支持自定义定时关闭"},
    @{@"icon" : @"cloud.fill", @"text" : @"高品质无损音质"},
    @{@"icon" : @"nosign", @"text" : @"去除所有广告体验"}
  ];

  UIView *lastView = nil;
  for (NSDictionary *feature in features) {
    UIView *row = [[UIView alloc] init];
    [self.featureListView addSubview:row];
    [row mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.featureListView.mas_left).offset(60);
      make.right.equalTo(self.featureListView.mas_right).offset(-60);
      make.height.mas_equalTo(50);
      if (lastView) {
        make.top.equalTo(lastView.mas_bottom).offset(10);
      } else {
        make.top.equalTo(self.featureListView.mas_top);
      }
    }];

    UIImageView *icon = [[UIImageView alloc]
        initWithImage:[UIImage systemImageNamed:feature[@"icon"]]];
    icon.tintColor = [UIColor orangeColor];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [row addSubview:icon];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.centerY.equalTo(row);
      make.width.height.mas_equalTo(24);
    }];

    UILabel *label = [[UILabel alloc] init];
    label.text = feature[@"text"];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18];
    [row addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(icon.mas_right).offset(15);
      make.centerY.equalTo(row);
    }];

    lastView = row;
  }
}

#pragma mark - Actions

- (void)closeAction {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)purchaseAction {
  [self.loadingIndicator startAnimating];
  self.purchaseButton.enabled = NO;
  self.view.userInteractionEnabled = NO;

  __weak typeof(self) weakSelf = self;
  [[SSStoreManager sharedManager]
      purchaseVIPWithCompletion:^(BOOL success, NSString *errorMsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf.loadingIndicator stopAnimating];
          weakSelf.view.userInteractionEnabled = YES;
          weakSelf.purchaseButton.enabled = YES;

          if (!success) {
            if (errorMsg) {
              [weakSelf showAlertWithTitle:@"Purchase Failed" message:errorMsg];
            }
          } else {
            // Success is usually handled by notification, but we can do simple
            // check here
            if ([SSStoreManager sharedManager].isVIP) {
              [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }
          }
        });
      }];
}

- (void)restoreAction {
  [self.loadingIndicator startAnimating];
  self.view.userInteractionEnabled = NO;

  __weak typeof(self) weakSelf = self;
  [[SSStoreManager sharedManager]
      restorePurchasesWithCompletion:^(BOOL success, NSString *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf.loadingIndicator stopAnimating];
          weakSelf.view.userInteractionEnabled = YES;

          [weakSelf showAlertWithTitle:success ? @"Success" : @"Restore Failed"
                               message:message];

          if (success && [SSStoreManager sharedManager].isVIP) {
            // Give user a moment to read success message before dismissing
            dispatch_after(
                dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                dispatch_get_main_queue(), ^{
                  [weakSelf dismissViewControllerAnimated:YES completion:nil];
                });
          }
        });
      }];
}

- (void)handleVIPStatusChanged {
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([SSStoreManager sharedManager].isVIP) {
      [self.loadingIndicator stopAnimating];
      [self dismissViewControllerAnimated:YES completion:nil];
    }
  });
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:title
                                          message:message ?: @""
                                   preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                            style:UIAlertActionStyleDefault
                                          handler:nil]];
  [self presentViewController:alert animated:YES completion:nil];
}

@end
