//
//  SSLocalization.h
//  SleepSounds
//
//  国际化字符串支持
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 本地化字符串宏
#define SSLocalizedString(key) NSLocalizedString(key, @"")

// 通用按钮标题
#define SSCloseButtonTitle SSLocalizedString(@"Close")
#define SSCancelButtonTitle SSLocalizedString(@"Cancel")
#define SSOKButtonTitle SSLocalizedString(@"OK")

// 睡眠定时器相关
#define SSTimerTitle SSLocalizedString(@"Set Sleep Timer")
#define SSTimer15Minutes SSLocalizedString(@"15 Minutes")
#define SSTimer30Minutes SSLocalizedString(@"30 Minutes")
#define SSTimer1Hour SSLocalizedString(@"1 Hour")
#define SSCancelTimer SSLocalizedString(@"Cancel Timer")

// VIP相关
#define SSVIPRequired SSLocalizedString(@"VIP Required")
#define SSVIPLockedMessage SSLocalizedString(@"This sound is locked.")
#define SSVPIMessage SSLocalizedString(@"Upgrade to VIP to unlock this sound.")

// 其他
#define SSNoSoundPlayingTip SSLocalizedString(@"Please play a sound first")
#define SSFeatureComingSoon SSLocalizedString(@"Feature coming soon")

// 宝宝页面
#define SSShushCategory SSLocalizedString(@"Shush")
#define SSWhiteNoiseCategory SSLocalizedString(@"White Noise")
#define SSNatureCategory SSLocalizedString(@"Nature")

// 工具箱页面
#define SSToolBreathing SSLocalizedString(@"Breathing")
#define SSToolDigitalClock SSLocalizedString(@"Digital Clock")
#define SSToolScreenLight SSLocalizedString(@"Screen Light")

NS_ASSUME_NONNULL_END
