#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

/** VIP 状态变更通知 */
UIKIT_EXTERN NSString *const SSVIPStatusChangedNotification;

/** VIP功能管理类：处理所有内购逻辑 */
@interface SSStoreManager
    : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

/** 单例方法 */
+ (instancetype)sharedManager;

/** 当前用户是否是VIP */
@property(nonatomic, assign, readonly) BOOL isVIP;

/** 从App Store获取到的VIP商品 */
@property(nonatomic, strong, readonly, nullable) SKProduct *vipProduct;

/** 初始化配置 */
- (void)setup;

/** 发起购买 */
- (void)purchaseVIP;

/** 恢复购买 */
- (void)restorePurchases;

@end

NS_ASSUME_NONNULL_END
