#import "DataManager.h"

@interface DataManager ()

@property(nonatomic, strong) NSArray<NSDictionary *> *cachedJsonArray;
@property(nonatomic, strong) dispatch_queue_t dataQueue;

@end

@implementation DataManager

+ (instancetype)sharedManager {
    static DataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataQueue = dispatch_queue_create("com.sleepsounds.datamanager", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Private Methods

- (void)loadJsonDataWithCompletion:(void (^)(NSArray<NSDictionary *> *_Nullable jsonArray,
                                              NSError *_Nullable error))completion {
    // 使用缓存
    if (self.cachedJsonArray) {
        if (completion) {
            completion(self.cachedJsonArray, nil);
        }
        return;
    }

    dispatch_async(self.dataQueue, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"sounds_config"
                                                         ofType:@"json"];
        if (!path) {
            NSError *error = [NSError errorWithDomain:@"DataManager"
                                                code:404
                                            userInfo:@{NSLocalizedDescriptionKey : @"Config file not found"}];
            [self callCompletion:completion withItems:nil error:error];
            return;
        }

        NSData *data = [NSData dataWithContentsOfFile:path];
        NSError *error = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:&error];
        if (error) {
            [self callCompletion:completion withItems:nil error:error];
            return;
        }

        // 缓存结果
        self.cachedJsonArray = jsonArray;

        [self callCompletion:completion withItems:jsonArray error:nil];
    });
}

- (void)callCompletion:(void (^)(NSArray *_Nullable, NSError *_Nullable))completion
             withItems:(NSArray *)items
                 error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) {
            completion(items, error);
        }
    });
}

- (NSArray<SoundItem *> *)createSoundItemsFromJsonArray:(NSArray<NSDictionary *> *)jsonArray
                                              category:(NSString *)category {
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dict in jsonArray) {
        // 如果指定了category，则过滤；否则返回全部
        if (category && ![dict[@"category"] isEqualToString:category]) {
            continue;
        }
        SoundItem *item = [[SoundItem alloc] initWithDictionary:dict];
        if (item) {
            [items addObject:item];
        }
    }
    return [items copy];
}

#pragma mark - Public Methods

- (void)fetchSoundsForCategory:(NSString *)category
                    completion:(void (^)(NSArray<SoundItem *> *items,
                                         NSError *_Nullable error))completion {
    [self loadJsonDataWithCompletion:^(NSArray<NSDictionary *> *jsonArray, NSError *error) {
        if (error) {
            if (completion) {
                completion(@[], error);
            }
            return;
        }

        NSArray<SoundItem *> *items = [self createSoundItemsFromJsonArray:jsonArray
                                                                category:category];
        if (completion) {
            completion(items, nil);
        }
    }];
}

- (void)fetchAllSoundItems:(void (^)(NSArray<SoundItem *> *items,
                                     NSError *_Nullable error))completion {
    // 传入nil表示不过滤category，返回全部
    [self fetchSoundsForCategory:nil completion:completion];
}

@end
