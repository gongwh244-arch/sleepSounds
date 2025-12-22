#import "SSStoreManager.h"

// VIP 状态变更的通知名称
NSString *const SSVIPStatusChangedNotification =
    @"SSVIPStatusChangedNotification";
// 在 App Store Connect 中配置的内购产品 ID
NSString *const kSSVIPProductID = @"com.sleepsounds.vip.permanent";
// 用于本地持久化存储 VIP 状态的 Key
NSString *const kSSVIPStatusKey = @"isVIP";

@interface SSStoreManager ()

/**
 *  重新定义属性为可读写（Internal），方便在 .m 内部赋值。
 *  对外在 .h 中仍保持 readonly。
 */
@property(nonatomic, strong, readwrite, nullable) SKProduct *vipProduct;
@property(nonatomic, assign, readwrite) BOOL isVIP;

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
  [self fetchProducts];
}

- (void)fetchProducts {
  NSSet *productIdentifiers = [NSSet setWithObject:kSSVIPProductID];
  SKProductsRequest *request =
      [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
  request.delegate = self;
  [request start];
}

- (void)purchaseVIP {
  if (!self.vipProduct) {
    [self fetchProducts];
    return;
  }

  if ([SKPaymentQueue canMakePayments]) {
    SKPayment *payment = [SKPayment paymentWithProduct:self.vipProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
  }
}

- (void)restorePurchases {
  [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response {
  for (SKProduct *product in response.products) {
    if ([product.productIdentifier isEqualToString:kSSVIPProductID]) {
      self.vipProduct = product;
      break;
    }
  }
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue
    updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
  for (SKPaymentTransaction *transaction in transactions) {
    switch (transaction.transactionState) {
    case SKPaymentTransactionStatePurchased:
    case SKPaymentTransactionStateRestored:
      [self completeTransaction:transaction];
      break;
    case SKPaymentTransactionStateFailed:
      [self failedTransaction:transaction];
      break;
    default:
      break;
    }
  }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
  [self unlockVIP];
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
  if (transaction.error.code != SKErrorPaymentCancelled) {
    // 记录错误或提示
  }
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)unlockVIP {
  self.isVIP = YES;
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSSVIPStatusKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [[NSNotificationCenter defaultCenter]
      postNotificationName:SSVIPStatusChangedNotification
                    object:nil];
}

@end
