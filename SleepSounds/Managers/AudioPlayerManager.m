#import "AudioPlayerManager.h"
#import "../Models/SoundItem.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayerManager ()

@property(nonatomic, strong)
    NSMutableDictionary<NSString *, AVAudioPlayer *> *activePlayers;
@property(nonatomic, strong) NSTimer *stopTimer;
@property(nonatomic, assign) NSTimeInterval stopTime;
@property(nonatomic, strong, readwrite)
    NSArray<NSString *> *lastPlayedSoundNames;

@end

@implementation AudioPlayerManager

+ (instancetype)sharedManager {
  static AudioPlayerManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _activePlayers = [[NSMutableDictionary alloc]
        init]; // MRC: need to release in dealloc if this were not a singleton
    [self configureAudioSession];

    // Load persisted last played sounds
    NSArray *savedSounds = [[NSUserDefaults standardUserDefaults]
        objectForKey:@"LastPlayedSoundNames"];
    if (savedSounds) {
      _lastPlayedSoundNames = savedSounds;
    }
  }
  return self;
}

- (void)configureAudioSession {
  NSError *error = nil;
  AVAudioSession *session = [AVAudioSession sharedInstance];
  [session setCategory:AVAudioSessionCategoryPlayback error:&error];
  if (error) {
    NSLog(@"[AudioPlayerManager] Error setting category: %@", error);
  }
}

- (void)activateAudioSession:(BOOL)active {
  NSError *error = nil;
  if (active) {
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
  } else {
    [[AVAudioSession sharedInstance]
          setActive:NO
        withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
              error:&error];
  }
  if (error) {
    NSLog(@"[AudioPlayerManager] Error changing session active to %d: %@",
          active, error);
  }
}

#pragma mark - Playback Methods

- (void)playSoundItem:(SoundItem *)item loop:(BOOL)loop {
  if (self.activePlayers[item.name])
    return;
  [self playSoundWithFileName:item.fileName soundName:item.name loop:loop];
}

- (void)playSound:(NSString *)soundName loop:(BOOL)loop {
  [self playSoundWithFileName:soundName soundName:soundName loop:loop];
}

- (void)playSoundWithFileName:(NSString *)fileName
                    soundName:(NSString *)soundName
                         loop:(BOOL)loop {
  if (self.activePlayers[soundName])
    return;

  NSURL *url = [[NSBundle mainBundle] URLForResource:fileName
                                       withExtension:@"mp3"];
  if (!url) {
    NSLog(@"[AudioPlayerManager] Local sound not found: %@", fileName);
    return;
  }

  [self stopSound:soundName];

  // 播放前激活 AudioSession，并中断其他 App
  if (self.activePlayers.count == 0) {
    [self activateAudioSession:YES];
  }

  NSError *error = nil;
  AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url
                                                                 error:&error];
  if (error) {
    NSLog(@"[AudioPlayerManager] Failed to init AVAudioPlayer: %@", error);
    return;
  }

  player.numberOfLoops = loop ? -1 : 0;
  [player play];
  self.activePlayers[soundName] = player;

  // 更新最后播放记录
  if (![self.lastPlayedSoundNames containsObject:soundName]) {
    NSMutableArray *temp =
        [NSMutableArray arrayWithArray:self.lastPlayedSoundNames ?: @[]];
    [temp addObject:soundName];
    self.lastPlayedSoundNames = [temp copy];
    [self persistLastPlayedSounds];
  }
}

- (void)stopSound:(NSString *)soundName {
  AVAudioPlayer *player = self.activePlayers[soundName];
  if (player) {
    [player stop];
    [self.activePlayers removeObjectForKey:soundName];
  }
}

- (void)stopAllSounds {
  if (self.activePlayers.count > 0) {
    self.lastPlayedSoundNames = self.activePlayers.allKeys;
    [self persistLastPlayedSounds];
  }
  for (NSString *name in self.activePlayers.allKeys) {
    [self stopSound:name];
  }
  [self cancelTimer];

  // 停止所有声音后，通知系统释放资源，以便其他 App 恢复播放
  [self activateAudioSession:NO];
}

- (void)persistLastPlayedSounds {
  if (self.lastPlayedSoundNames) {
    [[NSUserDefaults standardUserDefaults] setObject:self.lastPlayedSoundNames
                                              forKey:@"LastPlayedSoundNames"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}

#pragma mark - Helper Properties

- (BOOL)isPlaying:(NSString *)soundName {
  return self.activePlayers[soundName] != nil;
}

- (NSArray<NSString *> *)activeSoundNames {
  return self.activePlayers.allKeys;
}

#pragma mark - Volume Control

- (void)setVolume:(float)volume forSound:(NSString *)soundName {
  AVAudioPlayer *player = self.activePlayers[soundName];
  if (player) {
    player.volume = volume;
  }
}

- (float)volumeForSound:(NSString *)soundName {
  AVAudioPlayer *player = self.activePlayers[soundName];
  return player ? player.volume : 0.0f;
}

#pragma mark - Sleep Timer

- (void)startTimerWithDuration:(NSTimeInterval)duration {
  [self cancelTimer];
  if (duration <= 0)
    return;

  self.stopTime = [[NSDate date] timeIntervalSince1970] + duration;
  self.stopTimer = [NSTimer scheduledTimerWithTimeInterval:duration
                                                    target:self
                                                  selector:@selector(timerFired)
                                                  userInfo:nil
                                                   repeats:NO];
}

- (void)cancelTimer {
  if (self.stopTimer) {
    [self.stopTimer invalidate];
    self.stopTimer = nil;
  }
  self.stopTime = 0;
}

- (NSTimeInterval)remainingTime {
  if (!self.stopTimer)
    return 0;
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  return MAX(0, self.stopTime - now);
}

- (void)timerFired {
  NSTimeInterval fadeDuration = 1.0;
  for (AVAudioPlayer *player in self.activePlayers.allValues) {
    [player setVolume:0.0 fadeDuration:fadeDuration];
  }

  [self performSelector:@selector(stopAllSounds)
             withObject:nil
             afterDelay:fadeDuration + 0.1];
  [self cancelTimer];
  [[NSNotificationCenter defaultCenter]
      postNotificationName:@"AudioTimerExpired"
                    object:nil];
}

@end
