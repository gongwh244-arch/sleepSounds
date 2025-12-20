//
//  AppDelegate.m
//  SleepSounds
//
//  Created by 龚伟强 on 2025/12/19.
//

#import "AppDelegate.h"
#import "Controllers/MainTabBarController.h"
//@import FirebaseCore;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//  [FIRApp configure];
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.window.backgroundColor = [UIColor whiteColor];

  MainTabBarController *tabVC = [[MainTabBarController alloc] init];
  self.window.rootViewController = tabVC;

  [self.window makeKeyAndVisible];
  return YES;
}

@end
