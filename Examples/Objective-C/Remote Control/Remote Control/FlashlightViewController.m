//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import "FlashlightViewController.h"
#import "AdminViewTabBarController.h"

@interface FlashlightViewController ()

@property (weak, nonatomic) IBOutlet UIButton *flashlightButton;

@end

@implementation FlashlightViewController

- (IBAction)turnOnFlashlight:(id)sender {
    self.flashlightButton.enabled = NO;
    
    [self performSelector:@selector(enableFlashlightButton)
               withObject:nil
               afterDelay:15.0];
    
    if (self.tabBarController) {
        AdminViewTabBarController *tabBarController = (AdminViewTabBarController *)self.tabBarController;
        [tabBarController sendObject:nil sender:self];
    }
}

- (void)enableFlashlightButton {
    self.flashlightButton.enabled = YES;
}

@end
