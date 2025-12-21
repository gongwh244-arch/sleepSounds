//
//  KDGlobalDefine.h
//  ZYBScanSearch
//
//  Created by LXL on 2019/1/10.
//  Copyright © 2019年 zuoyebang. All rights reserved.
//

#ifndef KDGlobalDefine_h
#define KDGlobalDefine_h

#define ScreenWidth UIScreen.mainScreen.bounds.size.width
#define ScreenHeight UIScreen.mainScreen.bounds.size.height

// 单利---begin
#define KD_SINGLETION(...) \
	+(instancetype)sharedInstance NS_SWIFT_NAME(shared());

#define KD_DEF_SINGLETION(...)                           \
	+(instancetype)sharedInstance {                      \
		static dispatch_once_t once;                     \
		static id __singletion;                          \
		dispatch_once(&once, ^{                          \
			__singletion = [[self alloc] init];          \
		});                                              \
		return __singletion;                             \
	}                                                    \
                                                         \
	-(id)copyWithZone : (nullable NSZone *)zone {        \
		return [[self class] sharedInstance];            \
	}                                                    \
                                                         \
	-(id)mutableCopyWithZone : (nullable NSZone *)zone { \
		return [[self class] sharedInstance];            \
	}
// 单利---end



#endif /* KDGlobalDefine_h */
