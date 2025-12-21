#import "ToolboxViewController.h"
#import "../Models/SoundItem.h" // Reusing SoundItem for simplicity as data model
#import "../Views/SoundCell.h"	// Reusing SoundCell
#import "BreathingViewController.h"
#import "ScreenLightViewController.h"
#import "ToolboxViewController.h"

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
		@[ @"减压", @"数字时钟", @"边框修图大师", @"拍立得相框", @"屏幕常亮灯" ];
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

	// 2 Columns
	CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat hPadding = 20;
	CGFloat interItemSpacing = 15;
	NSInteger itemsPerRow = 2;

	CGFloat totalSpacing =
		(2 * hPadding) + ((itemsPerRow - 1) * interItemSpacing);
	CGFloat itemWidth = (screenWidth - totalSpacing) / itemsPerRow;
	// Taller cells
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
	// Reusing configure, ignoring 'locked' and 'playing' visual states usage for
	// now
	[cell configureWithIcon:item.iconName name:item.name isLocked:NO];

	// Customization for Toolbox look if needed
	// cell.iconImageView.transform = CGAffineTransformMakeScale(1.5, 1.5); //
	// Make icons bigger

	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
	didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	SoundItem *item = self.tools[indexPath.row];

	if ([item.name isEqualToString:@"屏幕常亮灯"]) {
		ScreenLightViewController *vc = [[ScreenLightViewController alloc] init];
		vc.modalPresentationStyle = UIModalPresentationFullScreen;
		[self presentViewController:vc animated:YES completion:nil];
		return;
	}

	if ([item.name isEqualToString:@"减压"]) {
		BreathingViewController *vc = [[BreathingViewController alloc] init];
		vc.modalPresentationStyle = UIModalPresentationFullScreen;
		[self presentViewController:vc animated:YES completion:nil];
		return;
	}

	UIAlertController *alert =
		[UIAlertController alertControllerWithTitle:item.name
											message:@"Tool feature coming soon."
									 preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"OK"
											  style:UIAlertActionStyleDefault
											handler:nil]];
	[self presentViewController:alert animated:YES completion:nil];
}

@end
