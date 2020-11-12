//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "Constants.h"

#import <AudioToolbox/AudioServices.h>

@interface SettingsTableViewController () <UITextFieldDelegate> {
    NSUserDefaults *usrDefaults;
}

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *vibrationSwitch;
@property (retain, nonatomic) UIAlertController *alertController;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    usrDefaults = [NSUserDefaults standardUserDefaults];
    
    [self updateValues];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateValues {
    self.usernameLabel.text = [usrDefaults stringForKey:USERNAME];
    self.vibrationSwitch.on = [usrDefaults boolForKey:VIBRATION_ENABLED];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.textLabel.textColor = [UIColor darkGrayColor];
    header.textLabel.font = [UIFont systemFontOfSize:14.0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self showTextAlert];
    } else if (indexPath.row == 2) {
        [self showResetSentCounterAlert];
    } else if (indexPath.row == 3) {
        [self showDeleteReceivedAlerts];
    } else if (indexPath.row == 4) {
        [self openBridgefyPage];
    }
}

- (void)showTextAlert {
    self.alertController = [UIAlertController alertControllerWithTitle:@"Set the new username"
                                                               message:@""
                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    __weak SettingsTableViewController *weakSelf = self;
    [self.alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"New username";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        textField.delegate = weakSelf;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self clearTableSelection];
                                                         }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self updateUsername:[self.alertController.textFields[0] text]];
                                                         [self clearTableSelection];
                                                     }];
    
    okAction.enabled = NO;
    
    [self.alertController addAction:cancelAction];
    [self.alertController addAction:okAction];
    
    [self presentViewController:self.alertController
                       animated:YES
                     completion:nil];
}

- (void)showResetSentCounterAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reset sent alerts counter?"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RESET_SENT_ALERTS_NOTIFICATION
                                                            object:nil];
        [self clearTableSelection];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self clearTableSelection];
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}


- (void)showDeleteReceivedAlerts {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete all received notifications?"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DELETE_RECEIVED_ALERTS_NOTIFICATION
                                                            object:nil];
        [self clearTableSelection];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self clearTableSelection];
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)updateUsername:(NSString *)newUsername {
    [usrDefaults setObject:newUsername forKey:USERNAME];
    [usrDefaults synchronize];
    
    self.usernameLabel.text = newUsername;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:USERNAME_NOTIFICATION
                                                        object:nil];
}

- (IBAction)vibrationSettingChanged:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:((UISwitch *)sender).on forKey:VIBRATION_ENABLED];
    [defaults synchronize];
    
    if ([sender isOn]) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VIBRATION_NOTIFICATION
                                                        object:nil];
}

- (void)clearTableSelection {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - TextField delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *originalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *cleanText = [self cleanText:originalString];
    
    self.alertController.actions[1].enabled = cleanText.length > 0;
    
    return YES;
}

- (NSString *)cleanText:(NSString *)string {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)openBridgefyPage {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://bridgefy.me"]
                                     options:@{}
                           completionHandler:^(BOOL success) {
        NSLog(@"Success");
    }];
}

@end
