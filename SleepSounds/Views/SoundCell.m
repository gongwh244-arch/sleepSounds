#import "SoundCell.h"
#import "Masonry.h"

@implementation SoundCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  // 1. Container/Background
  self.contentView.backgroundColor =
      [UIColor colorWithWhite:1.0 alpha:0.1]; // Glassy effect
  self.contentView.layer.cornerRadius = 20;
  self.contentView.layer.masksToBounds = YES;

  // 2. Icon
  _iconImageView = [[UIImageView alloc] init];
  _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
  _iconImageView.tintColor = [UIColor whiteColor];
  // _iconImageView.translatesAutoresizingMaskIntoConstraints = NO; // Not
  // needed with Masonry
  [self.contentView addSubview:_iconImageView];

  // 3. Label
  _nameLabel = [[UILabel alloc] init];
  _nameLabel.textColor = [UIColor whiteColor];
  _nameLabel.font = [UIFont systemFontOfSize:12];
  _nameLabel.textAlignment = NSTextAlignmentCenter;
  // _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [self.contentView addSubview:_nameLabel];

  // 4. Lock Icon
  _lockIconView = [[UIImageView alloc]
      initWithImage:[UIImage systemImageNamed:@"lock.fill"]];
  _lockIconView.tintColor = [UIColor whiteColor];
  _lockIconView.hidden = YES;
  // _lockIconView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.contentView addSubview:_lockIconView];

  // 5. Layout
  // 5. Layout
  [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self.contentView);
    make.centerY.equalTo(self.contentView).offset(-10);
    make.width.height.mas_equalTo(40);
  }];

  [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.iconImageView.mas_bottom).offset(8);
    make.leading.equalTo(self.contentView).offset(5);
    make.trailing.equalTo(self.contentView).offset(-5);
  }];

  [self.lockIconView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.contentView).offset(8);
    make.trailing.equalTo(self.contentView).offset(-8);
    make.width.height.mas_equalTo(12);
  }];
}

- (void)configureWithIcon:(NSString *)iconName
                     name:(NSString *)name
                 isLocked:(BOOL)isLocked {
  self.iconImageView.image =
      [UIImage systemImageNamed:iconName]; // Fallback to SF Symbols for now
  self.nameLabel.text = name;
  self.isLocked = isLocked;
  self.lockIconView.hidden = !isLocked;
}

- (void)setIsPlaying:(BOOL)isPlaying {
  _isPlaying = isPlaying;
  if (isPlaying) {
    self.contentView.backgroundColor =
        [UIColor colorWithWhite:1.0 alpha:0.3]; // Lighter when active
    self.iconImageView.tintColor =
        [UIColor greenColor]; // Tint green when active? Or keep white.
  } else {
    self.contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    self.iconImageView.tintColor = [UIColor whiteColor];
  }
}

@end
