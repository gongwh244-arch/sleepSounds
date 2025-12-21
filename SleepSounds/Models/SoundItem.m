#import "SoundItem.h"

@implementation SoundItem

- (instancetype)initWithName:(NSString *)name
					iconName:(NSString *)iconName
					isLocked:(BOOL)isLocked {
	self = [super init];
	if (self) {
		_name = name;
		_iconName = iconName;
		_isLocked = isLocked;
		_isPlaying = NO;
	}
	return self;
	return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
	self = [super init];
	if (self) {
		_name = dict[@"name"];
		_iconName = dict[@"iconName"];
		_category = dict[@"category"];
		_subCategory = dict[@"subCategory"];
		_isLocked = [dict[@"isLocked"] boolValue];
		_fileName = dict[@"fileName"];
		_isPlaying = NO;
	}
	return self;
}

@end
