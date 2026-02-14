#import "SSStoreManager.h"

NSString *const SSVIPStatusChangedNotification =
    @"SSVIPStatusChangedNotification";
NSString *const kSSVIPProductID = @"com.sleepsounds.vip.permanent";
NSString *const kSSVIPStatusKey = @"isVIP";

@interface SSStoreManager ()

@property(nonatomic, strong, readwrite, nullable) SKProduct *vipProduct;
@property(nonatomic, assign, readwrite) BOOL isVIP;

// Completion blocks
@property(nonatomic, copy) void (^fetchCompletion)
    (BOOL success, NSString *price);
@property(nonatomic, copy) void (^purchaseCompletion)
    (BOOL success, NSString *errorMsg);
@property(nonatomic, copy) void (^restoreCompletion)
    (BOOL success, NSString *message);

@end

@implementation SSStoreManager

+ (instancetype)sharedManager {
  static SSStoreManager *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[SSStoreManager alloc] init];
  });
  return shared;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _isVIP = [[NSUserDefaults standardUserDefaults] boolForKey:kSSVIPStatusKey];
  }
  return self;
}

- (void)setup {
  [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  // Auto-fetch if not VIP
  if (!self.isVIP) {
    [self fetchProductWithCompletion:nil];
  }
}

- (NSString *)priceString {
  if (self.vipProduct) {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.locale = self.vipProduct.priceLocale;
    return [formatter stringFromNumber:self.vipProduct.price];
  }
  return nil;
}

#pragma mark - Public Methods

- (void)fetchProductWithCompletion:(void (^)(BOOL success,
                                             NSString *price))completion {
  self.fetchCompletion = completion;

  if (self.vipProduct) {
    if (completion) {
      completion(YES, self.priceString);
    }
    self.fetchCompletion = nil;
    return;
  }

  if ([SKPaymentQueue canMakePayments]) {
    NSSet *productIdentifiers = [NSSet setWithObject:kSSVIPProductID];
    SKProductsRequest *request = [[SKProductsRequest alloc]
        initWithProductIdentifiers:productIdentifiers];
    request.delegate = self;
    [request start];
  } else {
    if (completion) {
      completion(NO, nil);
    }
    self.fetchCompletion = nil;
  }
}

- (void)purchaseVIPWithCompletion:(void (^)(BOOL success,
                                            NSString *errorMsg))completion {
  self.purchaseCompletion = completion;

  if (!self.vipProduct) {
    [self fetchProductWithCompletion:^(BOOL success, NSString *price) {
      if (success) {
        [self purchaseVIPWithCompletion:completion];
      } else {
        if (completion) {
          completion(NO, @"无法获取商品信息，请稍后重试");
        }
        self.purchaseCompletion = nil;
      }
    }];
    return;
  }

  if ([SKPaymentQueue canMakePayments]) {
    SKPayment *payment = [SKPayment paymentWithProduct:self.vipProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
  } else {
    if (completion) {
      completion(NO, @"您的设备禁止应用内购买");
    }
    self.purchaseCompletion = nil;
  }
}

- (void)restorePurchasesWithCompletion:(void (^)(BOOL success,
                                                 NSString *message))completion {
  self.restoreCompletion = completion;
  [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response {
  if (response.products.count > 0) {
    self.vipProduct = response.products.firstObject;
    if (self.fetchCompletion) {
      self.fetchCompletion(YES, self.priceString);
    }
  } else {
    if (self.fetchCompletion) {
      self.fetchCompletion(NO, nil);
    }
  }
  self.fetchCompletion = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
  if ([request isKindOfClass:[SKProductsRequest class]]) {
    if (self.fetchCompletion) {
      self.fetchCompletion(NO, nil);
    }
    self.fetchCompletion = nil;
  }
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue
    updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
  for (SKPaymentTransaction *transaction in transactions) {
    switch (transaction.transactionState) {
    case SKPaymentTransactionStatePurchased:
      [self completeTransaction:transaction];
      break;
    case SKPaymentTransactionStateFailed:
      [self failedTransaction:transaction];
      break;
    case SKPaymentTransactionStateRestored:
      [self restoreTransaction:transaction];
      break;
    case SKPaymentTransactionStateDeferred:
    case SKPaymentTransactionStatePurchasing:
      break;
    }
  }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:
    (SKPaymentQueue *)queue {
  // Check if we actually restored VIP
  // Since restoreTransaction calls unlockVIP which sets isVIP, we check that.
  // However, restoreTransaction might happens BEFORE this finish callback.
  // If user has no transactions, this is called without restoreTransaction
  // being called.

  if (self.restoreCompletion) {
    if (self.isVIP) {
      self.restoreCompletion(YES, @"恢复购买成功");
    } else {
      self.restoreCompletion(NO, @"未找到可恢复的购买记录");
    }
  }
  self.restoreCompletion = nil;
}

- (void)paymentQueue:(SKPaymentQueue *)queue
    restoreCompletedTransactionsFailedWithError:(NSError *)error {
  if (self.restoreCompletion) {
    if (error.code == SKErrorPaymentCancelled) {
      self.restoreCompletion(NO, @"用户取消恢复");
    } else {
      self.restoreCompletion(NO, error.localizedDescription ?: @"恢复购买失败");
    }
  }
  self.restoreCompletion = nil;
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
  [self unlockVIP];
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

  if (self.purchaseCompletion) {
    self.purchaseCompletion(YES, nil);
    self.purchaseCompletion = nil;
  }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
  if ([transaction.payment.productIdentifier isEqualToString:kSSVIPProductID]) {
    [self unlockVIP];
  }
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
  NSString *errorMsg = nil;
  if (transaction.error.code == SKErrorPaymentCancelled) {
    errorMsg = @"用户取消购买";
  } else {
    errorMsg = transaction.error.localizedDescription ?: @"购买失败";
  }

  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

  if (self.purchaseCompletion) {
    self.purchaseCompletion(NO, errorMsg);
    self.purchaseCompletion = nil;
  }
}

- (void)unlockVIP {
  // Only update if not already VIP to avoid loop triggers or redundant saves
  if (!self.isVIP) {
    self.isVIP = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSSVIPStatusKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:SSVIPStatusChangedNotification
                      object:nil];
  }
}

@end
