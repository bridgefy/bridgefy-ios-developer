//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import "ColorPickerViewController.h"
#import "AdminViewTabBarController.h"
#import <QuartzCore/QuartzCore.h>

@interface ColorPickerViewController ()

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (weak, nonatomic) IBOutlet UIButton *sendColorButton;
@property (retain, nonatomic) UIColor *pickedColor;

@end

@implementation ColorPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateColor];
    
    self.colorView.layer.borderWidth = 3.0;
    self.colorView.layer.borderColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.7].CGColor;
}

- (IBAction)slidersValueChanged:(id)sender {
    [self updateColor];
}

- (void)updateColor {
    float redAmount = self.redSlider.value;
    float greenAmount = self.greenSlider.value;
    float blueAmount = self.blueSlider.value;
    
    self.pickedColor = [UIColor colorWithRed:redAmount / 255.0
                                       green:greenAmount / 255.0
                                        blue:blueAmount / 255.0
                                       alpha:1.0];
    
    self.colorView.backgroundColor = self.pickedColor;
}

- (int)intFromColor:(UIColor *)color {
    int rgb = 255;
    rgb = (rgb << 8) + self.redSlider.value;
    rgb = (rgb << 8) + self.greenSlider.value;
    rgb = (rgb << 8) + self.blueSlider.value;
    
    return rgb;
}

- (IBAction)sendColorButtonPressed:(id)sender {
    if (self.tabBarController) {
        AdminViewTabBarController *tabBarController = (AdminViewTabBarController *)self.tabBarController;
        [tabBarController sendObject:@([self intFromColor:self.pickedColor]) sender:self];
    }
    
}

@end
