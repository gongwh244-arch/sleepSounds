//
//  SSColorConstants.h
//  SleepSounds
//
//  统一的颜色常量
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 背景渐变色
@interface SSGradientColors : NSObject

+ (NSArray<UIColor *> *)sleepGradientColors;
+ (NSArray<UIColor *> *)babyGradientColors;

@end

// 通用颜色
@interface SSColors : NSObject

+ (UIColor *)backgroundPrimary;
+ (UIColor *)backgroundSecondary;
+ (UIColor *)cellBackground;
+ (UIColor *)cellActiveBackground;
+ (UIColor *)textPrimary;
+ (UIColor *)textSecondary;
+ (UIColor *)accentColor;
+ (UIColor *)vipBannerColor;

@end

NS_ASSUME_NONNULL_END
