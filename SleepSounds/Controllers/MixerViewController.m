#import "MixerViewController.h"
#import "../Managers/AudioPlayerManager.h"

@interface MixerViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray<NSString *> *playingSounds;

@end

@implementation MixerViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Mixer";
	self.view.backgroundColor = [UIColor colorWithRed:0.1
												green:0.1
												 blue:0.1
												alpha:1.0];

	// Title Label
	UILabel *titleLabel = [[UILabel alloc]
		initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 50)];
	titleLabel.text = @"Sound Mixer";
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.font = [UIFont boldSystemFontOfSize:20];
	[self.view addSubview:titleLabel];

	// Close Button
	UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
	closeBtn.frame = CGRectMake(self.view.bounds.size.width - 60, 30, 44, 44);
	[closeBtn setImage:[UIImage systemImageNamed:@"xmark.circle.fill"]
			  forState:UIControlStateNormal];
	[closeBtn setTintColor:[UIColor whiteColor]];
	[closeBtn addTarget:self
				  action:@selector(dismissSelf)
		forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:closeBtn];

	[self loadData];
	[self setupTableView];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(handleTimerExpired)
			   name:@"AudioTimerExpired"
			 object:nil];
}

- (void)loadData {
	self.playingSounds = [[AudioPlayerManager sharedManager] activeSoundNames];
}

- (void)dismissSelf {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleTimerExpired {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self loadData];
		[self.tableView reloadData];
	});
}

- (void)setupTableView {
	self.tableView = [[UITableView alloc]
		initWithFrame:CGRectMake(0, 80, self.view.bounds.size.width,
								 self.view.bounds.size.height - 80)
				style:UITableViewStylePlain];
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.tableFooterView = [[UIView alloc] init];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
	numberOfRowsInSection:(NSInteger)section {
	return self.playingSounds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellId = @"MixerCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									  reuseIdentifier:cellId];
		cell.backgroundColor = [UIColor clearColor];
		cell.textLabel.textColor = [UIColor whiteColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		UISlider *slider =
			[[UISlider alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
		slider.minimumValue = 0.0;
		slider.maximumValue = 1.0;
		slider.tintColor = [UIColor systemTealColor];
		[slider addTarget:self
					  action:@selector(sliderChanged:)
			forControlEvents:UIControlEventValueChanged];
		cell.accessoryView = slider;
	}

	NSString *soundName = self.playingSounds[indexPath.row];
	cell.textLabel.text = soundName;
	cell.imageView.image = [UIImage
		systemImageNamed:@"waveform"]; // Placeholder, simpler than passing icons
	cell.imageView.tintColor = [UIColor whiteColor];

	UISlider *slider = (UISlider *)cell.accessoryView;
	slider.tag = indexPath.row;
	slider.value = [[AudioPlayerManager sharedManager] volumeForSound:soundName];

	return cell;
}

- (void)sliderChanged:(UISlider *)sender {
	if (sender.tag < self.playingSounds.count) {
		NSString *soundName = self.playingSounds[sender.tag];
		[[AudioPlayerManager sharedManager] setVolume:sender.value
											 forSound:soundName];
	}
}

@end
