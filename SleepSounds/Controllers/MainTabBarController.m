#import "MainTabBarController.h"
#import "../Views/PlayerControlView.h"
#import "BabyViewController.h"
#import "Masonry.h"
#import "SettingsViewController.h"
#import "SleepViewController.h"
#import "ToolboxViewController.h"
#import "DigitalClockViewController.h"

@interface MainTabBarController () <PlayerControlDelegate>
@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupTabs];
    [self setupAppearance];
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(updateBattery)
               name:UIDeviceBatteryStateDidChangeNotification
             object:nil];
}

- (void)updateBattery {
    UIDevice *device = [UIDevice currentDevice];
    UIDeviceBatteryState state = device.batteryState;
    BOOL isCharging = (state == UIDeviceBatteryStateCharging ||
                       state == UIDeviceBatteryStateFull);
    BOOL isOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"ud_isChargerShowScreenSaver"];
    BOOL isCurrentVC = [[MainTabBarController currentViewController] isKindOfClass:[DigitalClockViewController class]];
    if (isCharging && isOn && [[MainTabBarController currentViewController] isKindOfClass:[DigitalClockViewController class]] == NO) {
        DigitalClockViewController *vc = [[DigitalClockViewController alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
}

- (void)setupAppearance {
    // 配置 TabBar 外观,确保所有界面保持一致的半透明效果
    if (@available(iOS 15.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];

        // 使用半透明背景
        [appearance configureWithTransparentBackground];

        // 设置背景颜色和模糊效果
        appearance.backgroundColor =
            [[UIColor blackColor] colorWithAlphaComponent:0.8];
        appearance.backgroundEffect =
            [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];

        // 设置图标颜色
        appearance.stackedLayoutAppearance.normal.iconColor =
            [UIColor lightGrayColor];
        appearance.stackedLayoutAppearance.normal.titleTextAttributes =
            @{NSForegroundColorAttributeName : [UIColor lightGrayColor]};

        appearance.stackedLayoutAppearance.selected.iconColor =
            [UIColor whiteColor];
        appearance.stackedLayoutAppearance.selected.titleTextAttributes =
            @{NSForegroundColorAttributeName : [UIColor whiteColor]};

        // 应用外观配置
        self.tabBar.standardAppearance = appearance;
        self.tabBar.scrollEdgeAppearance =
            appearance; // 关键:滚动到边缘时也使用相同外观
    } else {
        // iOS 15 以下的兼容处理
        self.tabBar.barStyle = UIBarStyleBlack;
        self.tabBar.tintColor = [UIColor whiteColor];
        self.tabBar.unselectedItemTintColor = [UIColor lightGrayColor];
        self.tabBar.backgroundColor =
            [[UIColor blackColor] colorWithAlphaComponent:0.8];
        self.tabBar.translucent = YES;
    }

    self.view.backgroundColor = [UIColor blackColor];

    // 配置 NavigationBar 外观,确保全局透明
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *navAppearance =
            [[UINavigationBarAppearance alloc] init];
        [navAppearance configureWithTransparentBackground];

        // 设置标题文字颜色为白色
        navAppearance.titleTextAttributes =
            @{NSForegroundColorAttributeName : [UIColor whiteColor]};
        navAppearance.largeTitleTextAttributes =
            @{NSForegroundColorAttributeName : [UIColor whiteColor]};

        // 应用到全局
        [UINavigationBar appearance].standardAppearance = navAppearance;
        [UINavigationBar appearance].scrollEdgeAppearance = navAppearance;
        [UINavigationBar appearance].compactAppearance = navAppearance;
    } else {
        [UINavigationBar appearance].barStyle = UIBarStyleBlack;
        [UINavigationBar appearance].translucent = YES;
        [UINavigationBar appearance].titleTextAttributes =
            @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    }
}

- (void)setupTabs {
    // 1. Sleep (Home)
    SleepViewController *sleepVC = [[SleepViewController alloc] init];
    UINavigationController *sleepNav =
        [[UINavigationController alloc] initWithRootViewController:sleepVC];
    sleepNav.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:@"睡眠"
                image:[UIImage systemImageNamed:@"moon.zzz.fill"]
                  tag:0];

    // 2. Baby
    //  BabyViewController *babyVC = [[BabyViewController alloc] init];
    //  UINavigationController *babyNav =
    //      [[UINavigationController alloc] initWithRootViewController:babyVC];
    //  babyNav.tabBarItem = [[UITabBarItem alloc]
    //      initWithTitle:@"宝宝"
    //              image:[UIImage systemImageNamed:@"face.smiling.fill"]
    //                tag:1];

    // 3. Toolbox
      ToolboxViewController *toolboxVC = [[ToolboxViewController alloc] init];
      UINavigationController *toolboxNav =
          [[UINavigationController alloc] initWithRootViewController:toolboxVC];
      toolboxNav.tabBarItem = [[UITabBarItem alloc]
          initWithTitle:@"工具箱"
                  image:[UIImage systemImageNamed:@"briefcase.fill"]
                    tag:2];

    // 4. Settings
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    UINavigationController *settingsNav =
        [[UINavigationController alloc] initWithRootViewController:settingsVC];
    settingsNav.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:@"设置"
                image:[UIImage systemImageNamed:@"gearshape.fill"]
                  tag:3];

    self.viewControllers = @[ sleepNav, toolboxNav,settingsNav ];
    //  self.viewControllers = @[ sleepNav, babyNav, toolboxNav, settingsNav ];
}



+ (UIViewController *)currentViewController {
    // Find key window in a scene-aware way (iOS 13+), fall back for older iOS
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        NSSet *scenes = [UIApplication sharedApplication].connectedScenes;
        for (UIScene *scene in scenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *w in windowScene.windows) {
                    if (w.isKeyWindow) {
                        window = w;
                        break;
                    }
                }
                if (window) break;
            }
        }
    }
    if (!window) {
        window = [UIApplication sharedApplication].keyWindow;
        if (!window) {
            NSArray<UIWindow *> *windows = [UIApplication sharedApplication].windows;
            if (windows.count > 0) window = windows.firstObject;
        }
    }

    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[UITabBarController class]]) {
        result = [(UITabBarController *)result selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result topViewController];
    }
    return result;
}

@end
