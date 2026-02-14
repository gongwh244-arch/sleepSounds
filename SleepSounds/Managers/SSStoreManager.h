#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

/** VIP 状态变更通知 */
extern NSString *const SSVIPStatusChangedNotification;

/** VIP功能管理类：处理所有内购逻辑 */
@interface SSStoreManager
    : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

/** 单例方法 */
+ (instancetype)sharedManager;

/** 当前用户是否是VIP */
@property(nonatomic, assign, readonly) BOOL isVIP;

/** VIP商品价格字符串 */
@property(nonatomic, strong, readonly) NSString *priceString;

/** 从App Store获取到的VIP商品 */
@property(nonatomic, strong, readonly, nullable) SKProduct *vipProduct;

/** 初始化配置 */
- (void)setup;

/**
 *  获取商品信息
 *  @param completion 回调，success表示是否成功，price为商品价格字符串
 */
- (void)fetchProductWithCompletion:(void (^)(BOOL success,
                                             NSString *price))completion;

/**
 *  发起购买
 *  @param completion 回调，success表示是否成功，errorMsg为错误信息
 */
- (void)purchaseVIPWithCompletion:(void (^)(BOOL success,
                                            NSString *errorMsg))completion;

/**
 *  恢复购买
 *  @param completion 回调，success表示是否成功，message为提示信息
 */
- (void)restorePurchasesWithCompletion:(void (^)(BOOL success,
                                                 NSString *message))completion;

// Deprecated old methods
// - (void)purchaseVIP;
// - (void)restorePurchases;

@end

NS_ASSUME_NONNULL_END
