#import "ToolboxViewController.h"
#import "../Models/SoundItem.h"
#import "../Views/SoundCell.h"
#import "../Common/SSLocalization.h"
#import "BreathingViewController.h"
#import "DigitalClockViewController.h"
#import "ScreenLightViewController.h"

@interface ToolboxViewController () <UICollectionViewDelegate,
                                     UICollectionViewDataSource>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray<SoundItem *> *tools;

@end

@implementation ToolboxViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"工具箱";
  self.view.backgroundColor = [UIColor colorWithRed:0.0
                                              green:0.2
                                               blue:0.0
                                              alpha:1.0];

  [self setupData];
  [self setupCollectionView];
}

- (void)setupData {
  self.tools = [NSMutableArray array];
  NSArray *names =
      @[ SSToolBreathing, SSToolDigitalClock, @"边框修图大师", @"拍立得相框", SSToolScreenLight ];
  NSArray *icons = @[
    @"drop.fill", @"clock.fill", @"square.dashed", @"photo.on.rectangle",
    @"lightbulb.fill"
  ];

  for (int i = 0; i < names.count; i++) {
    SoundItem *item = [[SoundItem alloc] initWithName:names[i]
                                             iconName:icons[i]
                                             isLocked:NO];
    [self.tools addObject:item];
  }
}

- (void)setupCollectionView {
  UICollectionViewFlowLayout *layout =
      [[UICollectionViewFlowLayout alloc] init];

  CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
  CGFloat hPadding = 20;
  CGFloat interItemSpacing = 15;
  NSInteger itemsPerRow = 2;

  CGFloat totalSpacing =
      (2 * hPadding) + ((itemsPerRow - 1) * interItemSpacing);
  CGFloat itemWidth = (screenWidth - totalSpacing) / itemsPerRow;
  layout.itemSize = CGSizeMake(itemWidth, itemWidth * 1.2);
  layout.sectionInset = UIEdgeInsetsMake(20, hPadding, 20, hPadding);
  layout.minimumInteritemSpacing = interItemSpacing;
  layout.minimumLineSpacing = 15;

  self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                           collectionViewLayout:layout];
  self.collectionView.backgroundColor = [UIColor clearColor];
  self.collectionView.delegate = self;
  self.collectionView.dataSource = self;

  [self.collectionView registerClass:[SoundCell class]
          forCellWithReuseIdentifier:@"ToolCell"];
  [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.tools.count;
}

- (__kindof UICollectionViewCell *)collectionView:
                                       (UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  SoundCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:@"ToolCell"
                                                forIndexPath:indexPath];
  SoundItem *item = self.tools[indexPath.row];
  [cell configureWithIcon:item.iconName name:item.name isLocked:NO];

  return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  SoundItem *item = self.tools[indexPath.row];

  if ([item.name isEqualToString:SSToolScreenLight]) {
    ScreenLightViewController *vc = [[ScreenLightViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
    return;
  }

  if ([item.name isEqualToString:SSToolBreathing]) {
    BreathingViewController *vc = [[BreathingViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
    return;
  }

  if ([item.name isEqualToString:SSToolDigitalClock]) {
    DigitalClockViewController *vc = [[DigitalClockViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
    return;
  }

  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:item.name
                                          message:SSFeatureComingSoon
                                   preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:SSOKButtonTitle
                                            style:UIAlertActionStyleDefault
                                          handler:nil]];
  [self presentViewController:alert animated:YES completion:nil];
}

@end
