#import "AboutUsViewController.h"
#import "Masonry.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"关于我们";
  [self setupUI];
}

- (void)setupUI {
  self.view.backgroundColor = [UIColor colorWithRed:0.05
                                              green:0.0
                                               blue:0.1
                                              alpha:1.0];

  // 背景渐变
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = self.view.bounds;
  gradient.colors = @[
    (id)[UIColor colorWithRed:0.05 green:0.0 blue:0.1 alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:0.0 green:0.1 blue:0.2 alpha:1.0].CGColor
  ];
  [self.view.layer insertSublayer:gradient atIndex:0];

  // App 图标容器
  UIImageView *iconView = [[UIImageView alloc] init];

  // 从 Info.plist 动态获取图标
  NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
  NSDictionary *iconsDict = [infoPlist objectForKey:@"CFBundleIcons"];
  NSDictionary *primaryIconDict =
      [iconsDict objectForKey:@"CFBundlePrimaryIcon"];
  NSArray *iconFiles = [primaryIconDict objectForKey:@"CFBundleIconFiles"];
  NSString *lastIcon = [iconFiles lastObject];

  UIImage *appIcon = [UIImage imageNamed:lastIcon];
  if (!appIcon) {
    appIcon = [UIImage imageNamed:@"AppIcon"];
  }

  if (appIcon) {
    iconView.image = appIcon;
  } else {
    iconView.image = [UIImage systemImageNamed:@"moon.stars.fill"];
    iconView.tintColor = [UIColor orangeColor];
  }

  iconView.contentMode = UIViewContentModeScaleAspectFit;
  iconView.layer.cornerRadius = 20;
  iconView.layer.masksToBounds = YES;
  [self.view addSubview:iconView];

  [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(80);
    make.centerX.equalTo(self.view);
    make.width.height.mas_equalTo(100);
  }];

  // App 名称展示
  UILabel *nameLabel = [[UILabel alloc] init];
  NSString *appName = [infoPlist objectForKey:@"CFBundleDisplayName"]
                          ?: [infoPlist objectForKey:@"CFBundleName"];
  nameLabel.text = appName ?: @"睡眠森林";
  nameLabel.textColor = [UIColor whiteColor];
  nameLabel.font = [UIFont boldSystemFontOfSize:24];
  nameLabel.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview:nameLabel];

  [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(iconView.mas_bottom).offset(20);
    make.centerX.equalTo(self.view);
  }];

  // 版本号信息展示
  UILabel *versionLabel = [[UILabel alloc] init];
  NSString *version = [infoPlist objectForKey:@"CFBundleShortVersionString"];
  NSString *build = [infoPlist objectForKey:@"CFBundleVersion"];
  versionLabel.text =
      [NSString stringWithFormat:@"版本 %@ (%@)", version, build];
  versionLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
  versionLabel.font = [UIFont systemFontOfSize:16];
  versionLabel.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview:versionLabel];

  [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(nameLabel.mas_bottom).offset(10);
    make.centerX.equalTo(self.view);
  }];

  // 版权信息信息
  UILabel *copyrightLabel = [[UILabel alloc] init];
  copyrightLabel.text = @"© 2024 Sleep Sounds Inc.\nAll Rights Reserved.";
  copyrightLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.3];
  copyrightLabel.font = [UIFont systemFontOfSize:12];
  copyrightLabel.textAlignment = NSTextAlignmentCenter;
  copyrightLabel.numberOfLines = 0;
  [self.view addSubview:copyrightLabel];

  [copyrightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-30);
    make.centerX.equalTo(self.view);
  }];
}

@end
