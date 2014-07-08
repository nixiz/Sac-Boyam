//
//  OKSettingsViewController.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 04/07/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKSettingsViewController.h"
#import "UIImage+ImageEffects.h"

@interface OKSettingsViewController ()
@property (strong, nonatomic) NSMutableDictionary *settingsMap;
- (IBAction)switchValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *savePhotosSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *editPhotosSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *takeRecordsSwitch;

@end

@implementation OKSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  UIImage *backgroundImage = [UIImage imageNamed:@"background_sacBoyasi_4"];
  UIGraphicsBeginImageContext(self.view.bounds.size);
  [backgroundImage drawInRect:self.view.bounds];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  image = [image applyBlurWithRadius:15 tintColor:[UIColor colorWithWhite:0.8 alpha:0.2] saturationDeltaFactor:1.3 maskImage:nil];
//  image = [image applyLightEffect];

  self.view.backgroundColor = [UIColor colorWithPatternImage:image];

  if (self.settingsMap == nil) {
    self.settingsMap = [NSMutableDictionary dictionaryWithObjectsAndKeys:@NO, @"SavePhotos", @YES, @"EditPhotos", @NO, @"TakeRecord", nil];
  }
  [self.savePhotosSwitch setOn:[self.settingsMap[@"SavePhotos"] boolValue] animated:YES];
  [self.editPhotosSwitch setOn:[self.settingsMap[@"EditPhotos"] boolValue] animated:YES];
  [self.takeRecordsSwitch setOn:[self.settingsMap[@"TakeRecord"] boolValue] animated:YES];
  //[NSMutableArray arrayWithObjects:@NO, @YES, @NO, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCurrentSettings:(NSDictionary *)settings
{
  self.settingsMap = [NSMutableDictionary dictionaryWithDictionary:settings];
//  for (NSString *key in settings) {
//    [self.settingsMap setObject:[settings objectForKey:key] forKey:key];
//  }
//  self.settingsArray = [NSMutableArray arrayWithArray:settings];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)switchValueChanged:(id)sender {
  UISwitch *_switch = (UISwitch *)sender;
  NSLog(@"Switch with Tag %ld value chaged to %@", (long)_switch.tag, _switch.on == YES ? @"YES" : @"NO");
  switch (_switch.tag) {
    case 0:
      [self.settingsMap setObject:[NSNumber numberWithBool:_switch.on] forKey:@"SavePhotos"];
      break;
    case 1:
      [self.settingsMap setObject:[NSNumber numberWithBool:_switch.on] forKey:@"EditPhotos"];
      break;
    case 2:
      [self.settingsMap setObject:[NSNumber numberWithBool:_switch.on] forKey:@"TakeRecord"];
      break;
    default:
      break;
  }
//  [self.settingsArray replaceObjectAtIndex:_switch.tag withObject:[NSNumber numberWithBool:_switch.on]];
  if ([self.delegate respondsToSelector:@selector(acceptChangedSetings:)]) {
    [self.delegate acceptChangedSetings:self.settingsMap];
  }
  
}
@end
