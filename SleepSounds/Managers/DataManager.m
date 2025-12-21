#import "DataManager.h"
//@import FirebaseFirestore;

@implementation DataManager

+ (instancetype)sharedManager {
	static DataManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (void)fetchSoundsForCategory:(NSString *)category
					completion:(void (^)(NSArray<SoundItem *> *items,
										 NSError *_Nullable error))completion {
	dispatch_async(
		dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSString *path = [[NSBundle mainBundle] pathForResource:@"sounds_config"
															 ofType:@"json"];
			if (!path) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (completion)
						completion(@[], [NSError errorWithDomain:@"DataManager"
															code:404
														userInfo:@{
															NSLocalizedDescriptionKey :
																@"Config file not found"
														}]);
				});
				return;
			}

			NSData *data = [NSData dataWithContentsOfFile:path];
			NSError *error = nil;
			NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data
																 options:0
																   error:&error];

			if (error) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (completion)
						completion(@[], error);
				});
				return;
			}

			NSMutableArray *items = [NSMutableArray array];
			for (NSDictionary *dict in jsonArray) {
				if ([dict[@"category"] isEqualToString:category]) {
					SoundItem *item = [[SoundItem alloc] initWithDictionary:dict];
					[items addObject:item];
				}
			}

			dispatch_async(dispatch_get_main_queue(), ^{
				if (completion) {
					completion([items copy], nil);
				}
			});
		});
}

@end
