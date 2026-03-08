//
//  SSColorConstants.m
//  SleepSounds
//

#import "SSColorConstants.h"

@implementation SSGradientColors

+ (NSArray<UIColor *> *)sleepGradientColors {
    return @[
        [UIColor colorWithRed:0.05 green:0.0 blue:0.1 alpha:1.0],
        [UIColor colorWithRed:0.0 green:0.1 blue:0.2 alpha:1.0]
    ];
}

+ (NSArray<UIColor *> *)babyGradientColors {
    return @[
        [UIColor colorWithRed:0.1 green:0.0 blue:0.1 alpha:1.0],
        [UIColor colorWithRed:0.2 green:0.1 blue:0.1 alpha:1.0]
    ];
}

@end

@implementation SSColors

+ (UIColor *)backgroundPrimary {
    return [UIColor colorWithRed:0.0 green:0.2 blue:0.0 alpha:1.0];
}

+ (UIColor *)backgroundSecondary {
    return [UIColor colorWithWhite:0.0 alpha:0.3];
}

+ (UIColor *)cellBackground {
    return [UIColor colorWithWhite:1.0 alpha:0.1];
}

+ (UIColor *)cellActiveBackground {
    return [UIColor colorWithWhite:1.0 alpha:0.3];
}

+ (UIColor *)textPrimary {
    return [UIColor whiteColor];
}

+ (UIColor *)textSecondary {
    return [UIColor colorWithWhite:0.7 alpha:1.0];
}

+ (UIColor *)accentColor {
    return [UIColor colorWithRed:0.0 green:0.8 blue:0.5 alpha:1.0];
}

+ (UIColor *)vipBannerColor {
    return [UIColor colorWithRed:0.6 green:0.1 blue:0.1 alpha:1.0];
}

@end
