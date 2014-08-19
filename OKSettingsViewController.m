//
//  OKSettingsViewController.m
//  Sac Boyam
//
//  Created by Oguzhan Katli on 04/07/14.
//  Copyright (c) 2014 Oguzhan Katli. All rights reserved.
//

#import "OKSettingsViewController.h"
#import "UIImage+ImageEffects.h"
#import "OKUtils.h"

@interface OKSettingsViewController ()
@property (strong, nonatomic) NSDictionary *settingsMap;
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

  self.settingsMap = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
//  if (self.settingsMap == nil) {
//    self.settingsMap = [NSMutableDictionary dictionaryWithObjectsAndKeys:@NO, @"SavePhotos", @YES, @"EditPhotos", @NO, @"TakeRecord", nil];
//  }
  [self.savePhotosSwitch setOn:[self.settingsMap[savePhotosKey] boolValue] animated:YES];
  [self.editPhotosSwitch setOn:[self.settingsMap[editPhotosKey] boolValue] animated:YES];
  [self.takeRecordsSwitch setOn:[self.settingsMap[takeRecordKey] boolValue] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)setCurrentSettings:(NSDictionary *)settings
//{
//   self.settingsMap = [NSMutableDictionary dictionaryWithDictionary:settings];
//}

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
  NSString *keyString;
  switch (_switch.tag) {
    case 0:
      keyString = savePhotosKey;
//      [self.settingsMap setObject:[NSNumber numberWithBool:_switch.on] forKey:@"SavePhotos"];
      break;
    case 1:
      keyString = editPhotosKey;
//      [self.settingsMap setObject:[NSNumber numberWithBool:_switch.on] forKey:@"EditPhotos"];
      break;
    case 2:
      keyString = takeRecordKey;
//      [self.settingsMap setObject:[NSNumber numberWithBool:_switch.on] forKey:@"TakeRecord"];
      break;
    default: //default'ta zaten degisen olmayacagi icin asagidaki if dongusunde sikinti olmamasi icin herhangi biri olabilir
      keyString = editPhotosKey;
      break;
  }
  // ayarlar degistiginde buraya girilecegi icin degistimi diye kontrol etmeye gerek yok.
  [[NSUserDefaults standardUserDefaults] setObject:@(_switch.on) forKey:keyString];
//  [[NSUserDefaults standardUserDefaults] synchronize];
//  if ([[self.settingsMap objectForKey:keyString] boolValue] != _switch.on) {
//    [[NSUserDefaults standardUserDefaults] setObject:@(_switch.on) forKey:keyString];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//  }
  if ([self.delegate respondsToSelector:@selector(acceptChangedSetings:)]) {
    [self.delegate acceptChangedSetings];
  }
}
@end
