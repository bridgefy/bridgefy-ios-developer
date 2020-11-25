//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "AdminViewTabBarController.h"

@interface ImagePickerViewController ()

@property (nonatomic, retain) UIButton *currentButton;

@end

@implementation ImagePickerViewController

- (IBAction)imageButtonPressed:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    
    [self.currentButton setImage:[UIImage imageNamed:@"radioButtonOff"]
                        forState:UIControlStateNormal];
    
    [selectedButton setImage:[UIImage imageNamed:@"radioButtonOn"]
                    forState:UIControlStateNormal];
    
    self.currentButton = selectedButton;
    
    if (self.tabBarController) {
        AdminViewTabBarController *tabBarController = (AdminViewTabBarController *)self.tabBarController;
        [tabBarController sendObject:@(selectedButton.tag) sender:self];
    }
}


@end
