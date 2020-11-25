//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import "InputTextViewController.h"
#import "AdminViewTabBarController.h"

@interface InputTextViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *currentTextMessageLabel;

@end

@implementation InputTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField.delegate = self;
    self.currentTextMessageLabel.text = @"";
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *message = textField.text;
    self.currentTextMessageLabel.text = message;
    textField.text = @"";
    
    if (self.tabBarController) {
        AdminViewTabBarController *tabBarController = (AdminViewTabBarController *)self.tabBarController;
        [tabBarController sendObject:message sender:self];
    }
}

@end
