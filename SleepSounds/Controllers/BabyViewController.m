#import "BabyViewController.h"
#import "../Managers/AudioPlayerManager.h"
#import "../Managers/DataManager.h"
#import "../Models/SoundItem.h"
#import "../Views/PlayerControlView.h"
#import "../Views/SoundCell.h"
#import "MainTabBarController.h"
#import "Masonry.h"
#import "MixerViewController.h"

@interface BabyViewController () <
    UICollectionViewDelegate, UICollectionViewDataSource, PlayerControlDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSArray<NSArray<SoundItem *> *> *sections;
@property(nonatomic, strong) NSArray<NSString *> *sectionTitles;
@property(nonatomic, strong) UIView *vipBannerView;

@end

@implementation BabyViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"宝宝";

  // Gradient Background
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = self.view.bounds;
  gradient.colors = @[
    (id)[UIColor colorWithRed:0.1 green:0.0 blue:0.1 alpha:1.0].CGColor,
    (id)[UIColor colorWithRed:0.2 green:0.1 blue:0.1 alpha:1.0].CGColor
  ];
  [self.view.layer insertSublayer:gradient atIndex:0];

  [self setupData];
  [self setupVIPBanner];
  [self setupCollectionView];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(vipStatusChanged)
                                               name:@"VIPStatusChanged"
                                             object:nil];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)vipStatusChanged {
  [self setupData];
  [self.collectionView reloadData];
  // Also toggle banner visibility if needed
  BOOL isVip = [[NSUserDefaults standardUserDefaults] boolForKey:@"isVip"];
  self.vipBannerView.hidden = isVip;
}

- (void)setupData {
  __weak typeof(self) weakSelf = self;
  [[DataManager sharedManager]
      fetchSoundsForCategory:@"baby"
                  completion:^(NSArray<SoundItem *> *_Nullable items,
                               NSError *_Nullable error) {
                    if (error) {
                      NSLog(@"Failed to fetch baby sounds: %@", error);
                      return;
                    }

                    NSMutableArray *shushItems = [NSMutableArray array];
                    NSMutableArray *whiteNoiseItems = [NSMutableArray array];
                    NSMutableArray *natureItems = [NSMutableArray array];

                    for (SoundItem *item in items) {
                      if ([item.subCategory isEqualToString:@"shush"]) {
                        [shushItems addObject:item];
                      } else if ([item.subCategory
                                     isEqualToString:@"white_noise"]) {
                        [whiteNoiseItems addObject:item];
                      } else if ([item.subCategory isEqualToString:@"nature"]) {
                        [natureItems addObject:item];
                      } else {
                        // Fallback or default
                        [whiteNoiseItems addObject:item];
                      }
                    }

                    dispatch_async(dispatch_get_main_queue(), ^{
                      weakSelf.sections =
                          @[ shushItems, whiteNoiseItems, natureItems ];
                      weakSelf.sectionTitles =
                          @[ @"嘘声哄睡", @"白噪音", @"自然" ];
                      [weakSelf.collectionView reloadData];
                    });
                  }];
}

- (void)setupVIPBanner {
  self.vipBannerView = [[UIView alloc] init];
  self.vipBannerView.backgroundColor = [UIColor colorWithRed:0.6
                                                       green:0.1
                                                        blue:0.1
                                                       alpha:1.0];
  self.vipBannerView.layer.cornerRadius = 10;

  BOOL isVip = [[NSUserDefaults standardUserDefaults] boolForKey:@"isVip"];
  self.vipBannerView.hidden = isVip;

  [self.view addSubview:self.vipBannerView];

  UILabel *label = [[UILabel alloc] init];
  label.text = @"⚠️ 为了防止广告影响到宝宝的睡眠，我们强烈建议您升级到 VIP >>";
  label.textColor = [UIColor whiteColor];
  label.font = [UIFont boldSystemFontOfSize:12];
  label.numberOfLines = 0;

  [self.vipBannerView addSubview:label];

  [self.vipBannerView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(10);
    make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(15);
    make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-15);
    make.height.mas_equalTo(50);
  }];

  [label mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.vipBannerView);
    make.leading.equalTo(self.vipBannerView).offset(10);
    make.trailing.equalTo(self.vipBannerView).offset(-10);
  }];
}

- (void)setupCollectionView {
  UICollectionViewFlowLayout *layout =
      [[UICollectionViewFlowLayout alloc] init];
  layout.headerReferenceSize =
      CGSizeMake([UIScreen mainScreen].bounds.size.width, 40);

  CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
  CGFloat itemWidth = (screenWidth - 60) / 3.0; // 3 items

  layout.itemSize = CGSizeMake(itemWidth, itemWidth);
  layout.sectionInset = UIEdgeInsetsMake(10, 15, 20, 15);
  layout.minimumInteritemSpacing = 15;

  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                           collectionViewLayout:layout];
  self.collectionView.backgroundColor = [UIColor clearColor];
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;

  [self.collectionView registerClass:[SoundCell class]
          forCellWithReuseIdentifier:@"SoundCell"];
  [self.collectionView registerClass:[UICollectionReusableView class]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:@"Header"];

  [self.view addSubview:self.collectionView];

  [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.vipBannerView.mas_bottom).offset(10);
    make.leading.trailing.bottom.equalTo(self.view);
  }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:
    (UICollectionView *)collectionView {
  return self.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.sections[section].count;
}

- (__kindof UICollectionViewCell *)collectionView:
                                       (UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  SoundCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:@"SoundCell"
                                                forIndexPath:indexPath];
  SoundItem *item = self.sections[indexPath.section][indexPath.row];
  [cell configureWithIcon:item.iconName name:item.name isLocked:item.isLocked];
  [cell setIsPlaying:item.isPlaying];
  return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
  if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
    UICollectionReusableView *header =
        [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                           withReuseIdentifier:@"Header"
                                                  forIndexPath:indexPath];

    // Remove old labels if reusing
    for (UIView *view in header.subviews) {
      if ([view isKindOfClass:[UILabel class]]) {
        [view removeFromSuperview];
      }
    }

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 300, 40)];
    label.text = self.sectionTitles[indexPath.section];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:18];
    [header addSubview:label];

    return header;
  }
  return nil;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  SoundItem *item = self.sections[indexPath.section][indexPath.row];

  if (item.isLocked) {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"VIP Only"
                         message:@"Upgrade to VIP to unlock this sound."
                  preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
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
  for (NSArray *section in self.sections) {
    for (SoundItem *item in section) {
      if (item.isPlaying) {
        anyPlaying = YES;
        break;
      }
    }
  }
  [[PlayerControlView sharedInstance] setIsPlaying:anyPlaying];
}

#pragma mark - PlayerControlDelegate

- (void)didTapPlayPause {
  // Basic Pause All implementation
  [[AudioPlayerManager sharedManager] stopAllSounds];
  for (NSArray *section in self.sections) {
    for (SoundItem *item in section) {
      item.isPlaying = NO;
    }
  }
  [self.collectionView reloadData];
  [[PlayerControlView sharedInstance] setIsPlaying:NO];
}

- (void)didTapTimer {
  UIAlertController *alert = [UIAlertController
      alertControllerWithTitle:@"Set Sleep Timer"
                       message:nil
                preferredStyle:UIAlertControllerStyleActionSheet];

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
                       actionWithTitle:@"Cancel Timer"
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
