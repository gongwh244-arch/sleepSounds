#import "SleepViewController.h"
#import "../Managers/AudioPlayerManager.h"
#import "../Managers/DataManager.h"
#import "../Models/SoundItem.h"
#import "../Views/PlayerControlView.h"
#import "../Views/SoundCell.h"
#import "MainTabBarController.h"
#import "Masonry.h"
#import "MixerViewController.h"

@interface SleepViewController () <
	UICollectionViewDelegate, UICollectionViewDataSource, PlayerControlDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray<SoundItem *> *soundItems;
@property(nonatomic, strong) PlayerControlView *playerControl;

@end

@implementation SleepViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"睡眠";

	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = self.view.bounds;
	gradient.colors = @[
		(id)[UIColor colorWithRed:0.05 green:0.0 blue:0.1 alpha:1.0].CGColor,
		(id)[UIColor colorWithRed:0.0 green:0.1 blue:0.2 alpha:1.0].CGColor
	];
	[self.view.layer insertSublayer:gradient atIndex:0];

	[self setupData];
	[self setupCollectionView];
	[self setupPlayerControl];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(vipStatusChanged)
												 name:@"VIPStatusChanged"
											   object:nil];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		   selector:@selector(handleTimerExpired)
			   name:@"AudioTimerExpired"
			 object:nil];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)vipStatusChanged {
	[self setupData]; // Re-create items with new VIP state
	[self.collectionView reloadData];
}

- (void)setupData {
	self.soundItems = [NSMutableArray array];

	__weak typeof(self) weakSelf = self;
	[[DataManager sharedManager]
		fetchSoundsForCategory:@"sleep"
					completion:^(NSArray<SoundItem *> *_Nullable items,
								 NSError *_Nullable error) {
						if (error) {
							NSLog(@"Failed to fetch sounds: %@", error);
							// Fallback or show error
							return;
						}

						dispatch_async(dispatch_get_main_queue(), ^{
							[weakSelf.soundItems addObjectsFromArray:items];
							[weakSelf.collectionView reloadData];
						});
					}];
}

- (void)setupCollectionView {
	UICollectionViewFlowLayout *layout =
		[[UICollectionViewFlowLayout alloc] init];

	CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat hPadding = 20;
	CGFloat interItemSpacing = 15;
	NSInteger itemsPerRow = 3;

	CGFloat totalSpacing =
		(2 * hPadding) + ((itemsPerRow - 1) * interItemSpacing);
	CGFloat itemWidth = (screenWidth - totalSpacing) / itemsPerRow;

	layout.itemSize = CGSizeMake(itemWidth, itemWidth);
	layout.sectionInset = UIEdgeInsetsMake(20, hPadding, 120, hPadding);
	layout.minimumInteritemSpacing = interItemSpacing;
	layout.minimumLineSpacing = 15;

	self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
											 collectionViewLayout:layout];
	self.collectionView.backgroundColor = [UIColor clearColor];
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	self.collectionView.contentInsetAdjustmentBehavior =
		UIScrollViewContentInsetAdjustmentAlways;

	[self.collectionView registerClass:[SoundCell class]
			forCellWithReuseIdentifier:@"SoundCell"];
	[self.view addSubview:self.collectionView];
}

- (void)setupPlayerControl {
	self.playerControl = [[PlayerControlView alloc] initWithFrame:CGRectZero];
	self.playerControl.delegate = self;
	[self.view addSubview:self.playerControl];

	[self.playerControl mas_makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view);
		make.width.mas_equalTo(160);
		make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-20);
		make.height.mas_equalTo(60);
	}];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
	 numberOfItemsInSection:(NSInteger)section {
	return self.soundItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:
									   (UICollectionView *)collectionView
						   cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	SoundCell *cell =
		[collectionView dequeueReusableCellWithReuseIdentifier:@"SoundCell"
												  forIndexPath:indexPath];
	SoundItem *item = self.soundItems[indexPath.row];
	[cell configureWithIcon:item.iconName name:item.name isLocked:item.isLocked];
	[cell setIsPlaying:item.isPlaying];
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
	didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	SoundItem *item = self.soundItems[indexPath.row];

	if (item.isLocked) {
		UIAlertController *alert = [UIAlertController
			alertControllerWithTitle:@"VIP Required"
							 message:@"This sound is locked."
					  preferredStyle:UIAlertControllerStyleAlert];
		[alert addAction:[UIAlertAction actionWithTitle:@"OK"
												  style:UIAlertActionStyleCancel
												handler:nil]];
		[self presentViewController:alert animated:YES completion:nil];
		return;
	}

	item.isPlaying = !item.isPlaying;
	[collectionView reloadItemsAtIndexPaths:@[ indexPath ]];

	if (item.isPlaying) {
		[[AudioPlayerManager sharedManager] playSoundItem:item loop:YES];
	} else {
		[[AudioPlayerManager sharedManager] stopSound:item.name];
	}

	[self updatePlayerControlState];
}

- (void)updatePlayerControlState {
	BOOL anyPlaying = NO;
	for (SoundItem *item in self.soundItems) {
		if (item.isPlaying) {
			anyPlaying = YES;
			break;
		}
	}
	self.playerControl.isPlaying = anyPlaying;
}

- (void)handleTimerExpired {
	dispatch_async(dispatch_get_main_queue(), ^{
		for (SoundItem *item in self.soundItems) {
			item.isPlaying = NO;
		}
		[self.collectionView reloadData];
		[self updatePlayerControlState];
	});
}

#pragma mark - PlayerControlDelegate

- (void)didTapPlayPause {
	BOOL anyPlaying = NO;
	for (SoundItem *item in self.soundItems) {
		if (item.isPlaying) {
			anyPlaying = YES;
			break;
		}
	}

	if (anyPlaying) {
		[[AudioPlayerManager sharedManager] stopAllSounds];
		for (SoundItem *item in self.soundItems) {
			item.isPlaying = NO;
		}
	} else {
		NSArray *lastPlayed =
			[AudioPlayerManager sharedManager].lastPlayedSoundNames;
		if (lastPlayed.count > 0) {
			// 播放上一次记录的所有声音
			for (SoundItem *item in self.soundItems) {
				if ([lastPlayed containsObject:item.name]) {
					item.isPlaying = YES;
					[[AudioPlayerManager sharedManager] playSoundItem:item loop:YES];
				}
			}
		} else {
			// 如果没有记录，播放第一个未锁定的
			for (SoundItem *item in self.soundItems) {
				if (!item.isLocked) {
					item.isPlaying = YES;
					[[AudioPlayerManager sharedManager] playSoundItem:item loop:YES];
					break;
				}
			}
		}
	}

	[self.collectionView reloadData];
	[self updatePlayerControlState];
}

- (void)didTapTimer {
	if ([[AudioPlayerManager sharedManager] activeSoundNames].count == 0) {
		[self showToast:@"请先播放声音再设置定时器"];
		return;
	}

	UIAlertController *alert =
		[UIAlertController alertControllerWithTitle:@"Set Sleep Timer"
											message:nil
									 preferredStyle:UIAlertControllerStyleAlert];

#if DEBUG
	[alert addAction:[UIAlertAction
						 actionWithTitle:@"10s"
								   style:UIAlertActionStyleDefault
								 handler:^(UIAlertAction *_Nonnull action) {
									 [[AudioPlayerManager sharedManager]
										 startTimerWithDuration:10];
								 }]];
#endif

	[alert addAction:[UIAlertAction
						 actionWithTitle:@"15 Minutes"
								   style:UIAlertActionStyleDefault
								 handler:^(UIAlertAction *_Nonnull action) {
									 [[AudioPlayerManager sharedManager]
										 startTimerWithDuration:15 * 60];
								 }]];

	[alert addAction:[UIAlertAction
						 actionWithTitle:@"30 Minutes"
								   style:UIAlertActionStyleDefault
								 handler:^(UIAlertAction *_Nonnull action) {
									 [[AudioPlayerManager sharedManager]
										 startTimerWithDuration:30 * 60];
								 }]];

	[alert addAction:[UIAlertAction
						 actionWithTitle:@"1 Hour"
								   style:UIAlertActionStyleDefault
								 handler:^(UIAlertAction *_Nonnull action) {
									 [[AudioPlayerManager sharedManager]
										 startTimerWithDuration:60 * 60];
								 }]];

	[alert addAction:[UIAlertAction
						 actionWithTitle:@"cancel Timer"
								   style:UIAlertActionStyleDestructive
								 handler:^(UIAlertAction *_Nonnull action) {
									 [[AudioPlayerManager sharedManager]
										 cancelTimer];
								 }]];

	[alert addAction:[UIAlertAction actionWithTitle:@"Close"
											  style:UIAlertActionStyleCancel
											handler:nil]];

	[self presentViewController:alert animated:YES completion:nil];
}

@end
