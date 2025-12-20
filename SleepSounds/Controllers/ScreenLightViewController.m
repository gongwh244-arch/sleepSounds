#import "ScreenLightViewController.h"

@interface ScreenLightViewController ()

@property(nonatomic, strong) UIView *lightView;
@property(nonatomic, strong) UISlider *brightnessSlider;
@property(nonatomic, assign) CGFloat originalBrightness;

@end

@implementation ScreenLightViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];

  // Light View (Overlay)
  self.lightView = [[UIView alloc] initWithFrame:self.view.bounds];
  self.lightView.backgroundColor = [UIColor whiteColor];
  self.lightView.alpha = 1.0;
  [self.view addSubview:self.lightView];

  // Slider Container (Semi-transparent)
  UIView *controlContainer = [[UIView alloc]
      initWithFrame:CGRectMake(20, self.view.bounds.size.height - 100,
                               self.view.bounds.size.width - 40, 60)];
  controlContainer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
  controlContainer.layer.cornerRadius = 30;
  [self.view addSubview:controlContainer];

  // Brightness Slider
  self.brightnessSlider = [[UISlider alloc]
      initWithFrame:CGRectInset(controlContainer.bounds, 20, 0)];
  self.brightnessSlider.minimumValue = 0.1;
  self.brightnessSlider.maximumValue = 1.0;
  self.brightnessSlider.value = 1.0;
  self.brightnessSlider.tintColor = [UIColor whiteColor];
  [self.brightnessSlider addTarget:self
                            action:@selector(brightnessChanged:)
                  forControlEvents:UIControlEventValueChanged];
  [controlContainer addSubview:self.brightnessSlider];

  // Tap to Dismiss
  UITapGestureRecognizer *tap =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(dismissSelf)];
  [self.view addGestureRecognizer:tap];

  // Save original screen brightness
  self.originalBrightness = [UIScreen mainScreen].brightness;
  [[UIScreen mainScreen] setBrightness:1.0]; // Max brightness
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  // Restore brightness
  [[UIScreen mainScreen] setBrightness:self.originalBrightness];
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

- (void)brightnessChanged:(UISlider *)sender {
  self.lightView.alpha = sender.value;
  // Optionally also adjust system brightness again if needed
  // [[UIScreen mainScreen] setBrightness:sender.value];
}

- (void)dismissSelf {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
