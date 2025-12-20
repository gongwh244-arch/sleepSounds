#import <Foundation/Foundation.h>

@class SoundItem;

NS_ASSUME_NONNULL_BEGIN

@interface AudioPlayerManager : NSObject

+ (instancetype)sharedManager;

- (void)playSound:(NSString *)soundName loop:(BOOL)loop;
- (void)playSoundItem:(SoundItem *)item loop:(BOOL)loop;
- (void)stopSound:(NSString *)soundName;
- (void)stopAllSounds;
- (BOOL)isPlaying:(NSString *)soundName;
- (NSArray<NSString *> *)activeSoundNames;

// Volume
- (void)setVolume:(float)volume forSound:(NSString *)soundName;
- (float)volumeForSound:(NSString *)soundName;

// Timer
- (void)startTimerWithDuration:(NSTimeInterval)duration;
- (void)cancelTimer;
- (NSTimeInterval)remainingTime;

@end

NS_ASSUME_NONNULL_END
