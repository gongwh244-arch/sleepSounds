#import "SettingsViewController.h"
#import "Masonry.h"

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
			@{@"title" : @"意见反馈", @"type" : @"click"},
			@{@"title" : @"去 AppStore 评分", @"type" : @"click"},
			@{@"title" : @"隐私协议", @"type" : @"click"}
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
		initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];

	// Gradient or Image Background
	UIImageView *bgImageView = [[UIImageView alloc]
		initWithFrame:CGRectInset(headerView.bounds, 20, 10)];
	bgImageView.backgroundColor = [UIColor orangeColor];		  // Placeholder
	bgImageView.image = [UIImage systemImageNamed:@"flame.fill"]; // Placeholder
	bgImageView.contentMode = UIViewContentModeScaleAspectFill;
	bgImageView.layer.cornerRadius = 15;
	bgImageView.layer.masksToBounds = YES;
	bgImageView.userInteractionEnabled = YES; // Enable tap
	[headerView addSubview:bgImageView];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
		initWithTarget:self
				action:@selector(vipHeaderTapped)];
	[bgImageView addGestureRecognizer:tap];

	UILabel *vipLabel = [[UILabel alloc] init];
	vipLabel.text = @"升级到 VIP\nUnlock all sounds & features";
	vipLabel.textColor = [UIColor whiteColor];
	vipLabel.font = [UIFont boldSystemFontOfSize:20];
	vipLabel.numberOfLines = 0;
	[headerView addSubview:vipLabel];
	[vipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
		make.center.equalTo(headerView);
	}];

	self.tableView.tableHeaderView = headerView;
}

- (void)vipHeaderTapped {
	BOOL isVip = [[NSUserDefaults standardUserDefaults] boolForKey:@"isVip"];
	[[NSUserDefaults standardUserDefaults] setBool:!isVip forKey:@"isVip"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	NSString *msg =
		!isVip ? @"VIP Activated! All sounds unlocked." : @"VIP Deactivated.";
	UIAlertController *alert =
		[UIAlertController alertControllerWithTitle:@"VIP (Debug)"
											message:msg
									 preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction
						 actionWithTitle:@"OK"
								   style:UIAlertActionStyleDefault
								 handler:^(UIAlertAction *_Nonnull action) {
									 // Post notification to update other
									 // controllers
									 [[NSNotificationCenter defaultCenter]
										 postNotificationName:@"VIPStatusChanged"
													   object:nil];
								 }]];
	[self presentViewController:alert animated:YES completion:nil];
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
		sw.on = YES; // Default
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
	// TODO: Persist setting
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
	didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	NSDictionary *item = self.settingsItems[indexPath.section][indexPath.row];
	NSString *title = item[@"title"];

	if ([title isEqualToString:@"意见反馈"]) {
		[self clickFeedback];
	} else if ([title isEqualToString:@"去 AppStore 评分"]) {
		[self rateApp];
	}
}

#pragma mark - Action
- (void)clickFeedback {
	UIAlertController *alert = [UIAlertController
		alertControllerWithTitle:@"意见反馈"
						 message:nil
				  preferredStyle:UIAlertControllerStyleActionSheet];
	[alert
		addAction:[UIAlertAction
					  actionWithTitle:@"给1066802504@qq.com发邮件"
								style:UIAlertActionStyleDefault
							  handler:^(UIAlertAction *_Nonnull action) {
								  NSURL *url =
									  [NSURL URLWithString:@"mailto:1066802504@qq."
														   @"com?subject=Feedback"];
								  if ([[UIApplication sharedApplication]
										  canOpenURL:url]) {
									  [[UIApplication sharedApplication] openURL:url
																		 options:@{}
															   completionHandler:nil];
								  }
							  }]];
	[alert addAction:[UIAlertAction
						 actionWithTitle:@"复制1066802504@qq.com"
								   style:UIAlertActionStyleDefault
								 handler:^(UIAlertAction *_Nonnull action) {
									 [UIPasteboard generalPasteboard].string =
										 @"1066802504@qq.com";
									 [self showToast:@"已复制到剪贴板"];
								 }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Close"
											  style:UIAlertActionStyleCancel
											handler:nil]];
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)rateApp {
	// 替换为你的 App ID
	NSString *appID = @"1330927814";
	NSString *urlStr = [NSString
		stringWithFormat:
			@"itms-apps://itunes.apple.com/app/id%@?action=write-review", appID];
	NSURL *url = [NSURL URLWithString:urlStr];

	if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url
										   options:@{}
								 completionHandler:nil];
	} else {
		[self showToast:@"无法打开 App Store"];
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
