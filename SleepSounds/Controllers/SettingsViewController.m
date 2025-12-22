#import "SettingsViewController.h"
#import "AboutUsViewController.h"
#import "Masonry.h"
#import "SSStoreManager.h"
#import "VIPViewController.h"
#import <SafariServices/SafariServices.h>

#define YHYSZC @"用户隐私政策"
#define YHFWXY @"用户服务协议"
#define YJFK @"意见反馈"
#define APPSTORE_Rate @"去 AppStore 评分"
#define GYWM @"关于我们"

@interface SettingsViewController () <UITableViewDelegate,
                                      UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray *settingsItems;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"设置";

  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = self.view.bounds;
  gradient.colors = @[
    (id)[UIColor colorWithRed:0.05 green:0.0 blue:0.1 alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:0.0 green:0.1 blue:0.2 alpha:1.0].CGColor
  ];
  [self.view.layer insertSublayer:gradient atIndex:0];

  [self setupData];
  [self setupTableView];
}

- (void)setupData {
  self.settingsItems = @[
    @[
      @{@"title" : @"淡出时长", @"type" : @"click"},
      @{@"title" : @"更换背景色", @"type" : @"click"},
      @{@"title" : @"与其他 App 兼容播放", @"type" : @"switch"}
    ],
    @[
      @{@"title" : YJFK, @"type" : @"click"},
      @{@"title" : APPSTORE_Rate, @"type" : @"click"},
    ],
    @[
      @{@"title" : YHYSZC, @"type" : @"click"},
      @{@"title" : YHFWXY, @"type" : @"click"},
      @{@"title" : GYWM, @"type" : @"click"}
    ]
  ];
}

- (void)setupTableView {
  self.tableView =
      [[UITableView alloc] initWithFrame:self.view.bounds
                                   style:UITableViewStyleInsetGrouped];
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.1];
  [self.view addSubview:self.tableView];

  [self setupHeaderView];
}

- (void)setupHeaderView {
  UIView *headerView = [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 180)];
  UIView *bgView =
      [[UIView alloc] initWithFrame:CGRectInset(headerView.bounds, 15, 10)];
  bgView.layer.cornerRadius = 20;
  bgView.layer.masksToBounds = YES;
  [headerView addSubview:bgView];

  CAGradientLayer *headerGradient = [CAGradientLayer layer];
  headerGradient.frame = bgView.bounds;
  headerGradient.colors = @[
    (id)[UIColor colorWithRed:1.0 green:0.8 blue:0.4 alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0].CGColor
  ];
  headerGradient.startPoint = CGPointMake(0, 0);
  headerGradient.endPoint = CGPointMake(1, 1);
  [bgView.layer addSublayer:headerGradient];

  bgView.userInteractionEnabled = YES;
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(vipHeaderTapped)];
  [bgView addGestureRecognizer:tap];

  UIImageView *crownIcon = [[UIImageView alloc]
      initWithImage:[UIImage systemImageNamed:@"crown.fill"]];
  crownIcon.tintColor = [UIColor whiteColor];
  [bgView addSubview:crownIcon];
  [crownIcon mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(bgView).offset(20);
    make.centerY.equalTo(bgView);
    make.width.height.mas_equalTo(40);
  }];

  UILabel *titleLabel = [[UILabel alloc] init];
  titleLabel.text = @"加入 VIP 全能会员";
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.font = [UIFont boldSystemFontOfSize:22];
  [bgView addSubview:titleLabel];
  [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(crownIcon.mas_right).offset(15);
    make.top.equalTo(bgView).offset(30);
  }];

  UILabel *descLabel = [[UILabel alloc] init];
  descLabel.text = @"解锁所有音效，享受纯净体验";
  descLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.9];
  descLabel.font = [UIFont systemFontOfSize:14];
  [bgView addSubview:descLabel];
  [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(titleLabel);
    make.top.equalTo(titleLabel.mas_bottom).offset(5);
  }];

  UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  [joinBtn setTitle:@"立即开启" forState:UIControlStateNormal];
  [joinBtn setTitleColor:[UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0]
                forState:UIControlStateNormal];
  joinBtn.backgroundColor = [UIColor whiteColor];
  joinBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
  joinBtn.layer.cornerRadius = 15;
  joinBtn.userInteractionEnabled = NO;
  [bgView addSubview:joinBtn];
  [joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(titleLabel);
    make.top.equalTo(descLabel.mas_bottom).offset(15);
    make.width.mas_equalTo(80);
    make.height.mas_equalTo(30);
  }];

  self.tableView.tableHeaderView = headerView;
}

- (void)vipHeaderTapped {
  VIPViewController *vipVC = [[VIPViewController alloc] init];
  vipVC.modalPresentationStyle = UIModalPresentationFullScreen;
  [self presentViewController:vipVC animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.settingsItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [self.settingsItems[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"SettingsCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                  reuseIdentifier:cellId];
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }

  NSDictionary *item = self.settingsItems[indexPath.section][indexPath.row];
  cell.textLabel.text = item[@"title"];

  if ([item[@"type"] isEqualToString:@"switch"]) {
    UISwitch *sw = [[UISwitch alloc] init];
    sw.on = YES;
    [sw addTarget:self
                  action:@selector(switchChanged:)
        forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = sw;
  } else {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
  }
  return cell;
}

- (void)switchChanged:(UISwitch *)sender {
  NSLog(@"Switch changed: %d", sender.isOn);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  NSDictionary *item = self.settingsItems[indexPath.section][indexPath.row];
  NSString *title = item[@"title"];

  if ([title isEqualToString:YJFK]) {
    [self clickFeedback];
  } else if ([title isEqualToString:APPSTORE_Rate]) {
    [self rateApp];
  } else if ([title isEqualToString:YHYSZC]) {
    [self openPrivacyPolicy:WQPrivacyPolicyLink];
  } else if ([title isEqualToString:YHFWXY]) {
    [self openPrivacyPolicy:WQUserServerLink];
  } else if ([title isEqualToString:GYWM]) {
    [self openAboutUs];
  }
}

#pragma mark - Action

- (void)openAboutUs {
  AboutUsViewController *aboutVC = [[AboutUsViewController alloc] init];
  aboutVC.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:aboutVC animated:YES];
}

- (void)openPrivacyPolicy:(NSString *)urlString {
  NSURL *url = [NSURL URLWithString:urlString];
  if (url) {
    SFSafariViewController *safariVC =
        [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:safariVC animated:YES completion:nil];
  }
}

- (void)clickFeedback {
  UIAlertController *alert = [UIAlertController
      alertControllerWithTitle:@"意见反馈"
                       message:nil
                preferredStyle:UIAlertControllerStyleActionSheet];
  [alert addAction:[UIAlertAction
                       actionWithTitle:@"给1066802504@qq.com发邮件"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                 NSURL *url = [NSURL
                                     URLWithString:@"mailto:1066802504@qq.com"];
                                 if ([[UIApplication sharedApplication]
                                         canOpenURL:url]) {
                                   [[UIApplication sharedApplication]
                                                 openURL:url
                                                 options:@{}
                                       completionHandler:nil];
                                 }
                               }]];

  [alert addAction:[UIAlertAction
                       actionWithTitle:@"复制邮件地址"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                 [UIPasteboard generalPasteboard].string =
                                     @"1066802504@qq.com";
                                 [self showToast:@"已复制到剪贴板"];
                               }]];

  [alert addAction:[UIAlertAction actionWithTitle:@"关闭"
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)rateApp {
  NSString *appID = @"1330927814";
  NSString *urlStr = [NSString
      stringWithFormat:
          @"itms-apps://itunes.apple.com/app/id%@?action=write-review", appID];
  NSURL *url = [NSURL URLWithString:urlStr];

  if ([[UIApplication sharedApplication] canOpenURL:url]) {
    [[UIApplication sharedApplication] openURL:url
                                       options:@{}
                             completionHandler:nil];
  }
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
    make.centerX.equalTo(self.view);
    make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-100);
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
