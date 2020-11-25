//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import "MainViewController.h"
#import "AdminViewTabBarController.h"
#import "ImagePickerViewController.h"
#import "ColorPickerViewController.h"
#import "InputTextViewController.h"
#import "FlashlightViewController.h"

#import <BFTransmitter/BFTransmitter.h>
#import <AVFoundation/AVFoundation.h>

#define kLastId @"lastId"
#define kCommandKey @"command"
#define kIdKey @"id"
#define kImageKey @"image"
#define kColorKey @"color"
#define kTextKey @"text"

typedef NS_ENUM(NSUInteger, Command) {
    CommandImage = 1,
    CommandColor,
    CommandFlashlight,
    CommandText
};

@interface MainViewController () <BFTransmitterDelegate> {
    NSArray *images;
}

@property (nonatomic, retain) BFTransmitter *transmitter;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    images = @[@"ad", @"sports", @"map", @"concert"];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    //Transmitter initialization
    [BFTransmitter setLogLevel:BFLogLevelError];
    self.transmitter = [[BFTransmitter alloc] initWithApiKey:@"YOUR API KEY"];
    self.transmitter.delegate = self;
    self.transmitter.backgroundModeEnabled = YES;
    [self.transmitter start];
    // Instruction for the user
    NSString *clientMessage = @"Client Screen\n\n Long press with one finger to go to the admin panel. This will allow you to send commands to nearby devices.";
    [self showText:clientMessage];
    
}

- (IBAction)longPressDetected:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self showAdminDialog];
    }
}

- (void)showAdminDialog {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Do you want to become an admin?"
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self performSegueWithIdentifier:@"showAdminView"
                                                                                   sender:self];
                                                     }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showAdminView"]) {
        AdminViewTabBarController *adminVC = (AdminViewTabBarController *)segue.destinationViewController;
        adminVC.mvc = self;
    }
}

- (void)sendObject:(id)object sender:(id)sender {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@(floor([[NSDate date] timeIntervalSince1970] * 1000)) forKey:kIdKey];
    
    if ([sender isKindOfClass:[ImagePickerViewController class]]) {
        [dict setObject:@(CommandImage) forKey:kCommandKey];
        [dict setObject:object forKey:kImageKey];
    } else if ([sender isKindOfClass:[ColorPickerViewController class]]) {
        [dict setObject:@(CommandColor) forKey:kCommandKey];
        [dict setObject:object forKey:kColorKey];
    } else if ([sender isKindOfClass:[FlashlightViewController class]]) {
        [dict setObject:@(CommandFlashlight) forKey:kCommandKey];
    } else if ([sender isKindOfClass:[InputTextViewController class]]) {
        [dict setObject:@(CommandText) forKey:kCommandKey];
        [dict setObject:(NSString *)object forKey:kTextKey];
    } else {
        NSLog(@"ERROR: Unknown sender");
        return;
    }
    
    BFSendingOption options = BFSendingOptionMeshTransmission|BFSendingOptionBroadcastReceiver|BFSendingOptionNotEncrypted;
    
    NSError *error;
    [self.transmitter sendDictionary:dict
                              toUser:nil
                             options:options
                               error:&error];
}

#pragma mark - BFTransmitterDelegate

- (void)transmitter:(BFTransmitter *)transmitter meshDidAddPacket:(NSString *)packetID {
    //Packet added to mesh
}

- (void)transmitter:(BFTransmitter *)transmitter didReachDestinationForPacket:( NSString *)packetID {
    //Mesh packet reached destiny (no always invoked)
}

- (void)transmitter:(BFTransmitter *)transmitter meshDidStartProcessForPacket:( NSString *)packetID {
    //A message entered in the mesh process.
}
- (void)transmitter:(BFTransmitter *)transmitter didSendDirectPacket:(NSString *)packetID{
    //A direct message was sent
}

- (void)transmitter:(BFTransmitter *)transmitter didFailForPacket:(NSString *)packetID error:(NSError * _Nullable)error {
    //A direct message transmission failed.
}
- (void)transmitter:(BFTransmitter *)transmitter meshDidDiscardPackets:(NSArray<NSString *> *)packetIDs {
    //A mesh message was discared and won't still be transmitted.
}

- (void)transmitter:(BFTransmitter *)transmitter meshDidRejectPacketBySize:(NSString *)packetID {
    NSLog(@"The packet %@ was rejected from mesh because it exceeded the limit size.", packetID);
}

- (void)transmitter:(BFTransmitter *)transmitter
didReceiveDictionary:(NSDictionary<NSString *, id> * _Nullable) dictionary
           withData:(NSData * _Nullable)data
           fromUser:(NSString *)user
           packetID:(NSString *)packetID
          broadcast:(BOOL)broadcast
               mesh:(BOOL)mesh {
    // A dictionary was received by BFTransmitter.
    
    [self processReceivedDictionary:dictionary];
    
}

- (void)transmitter:(BFTransmitter *)transmitter didDetectConnectionWithUser:(NSString *)user {
    //A connection was detected (no necessarily secure)
}

- (void)transmitter:(BFTransmitter *)transmitter didDetectDisconnectionWithUser:(NSString *)user {
    // A disconnection was detected.
}

- (void)transmitter:(BFTransmitter *)transmitter didFailAtStartWithError:(NSError *)error {
    NSLog(@"An error occurred at start: %@", error.localizedDescription);
}

- (void)transmitter:(BFTransmitter *)transmitter didOccurEvent:(BFEvent)event description:(NSString *)description {
    NSLog(@"Event reported: %@", description);
}

- (void)transmitter:(BFTransmitter *)transmitter didDetectSecureConnectionWithUser:(nonnull NSString *)user {
    // A secure connection was detected,
    // A secure connection has encryption capabilities.
}

- (void)transmitter:(nonnull BFTransmitter *)transmitter didDetectNearbyUser:(nonnull NSString *)user {
    // A nearby user was detected
}


- (void)transmitter:(nonnull BFTransmitter *)transmitter didFailConnectingToUser:(nonnull NSString *)user error:(nonnull NSError *)error {
    // An on-demand connection with a user has failed
}


- (void)transmitter:(nonnull BFTransmitter *)transmitter userIsNotAvailable:(nonnull NSString *)user {
    // A user is not nearby anymore
}


#pragma mark -

- (void)processReceivedDictionary:(NSDictionary *)dict {
    
    double receivedId = [[dict valueForKey:kIdKey] doubleValue];
    
    if (![self updateLastId:receivedId]) {
        // Command is ignored
        return;
    }
    
    Command cmd = (Command)[[dict valueForKey:kCommandKey] intValue];
    
    switch (cmd) {
        case CommandImage:
            [self showImageFromDictionary:dict];
            break;
            
        case CommandColor:
            [self showColorFromDictionary:dict];
            break;
            
        case CommandFlashlight:
            [self turnOnFlashlight:YES];
            break;
            
        case CommandText:
            [self showTextFromDictionary:dict];
            break;
    }
}

- (void)showImageFromDictionary:(NSDictionary *)dict {
    int imageIndex = [[dict valueForKey:kImageKey] intValue];
    
    if (imageIndex > images.count) {
        return;
    }
    
    [self resetView];
    self.imageView.image = [UIImage imageNamed:images[imageIndex]];
    self.imageView.hidden = NO;
    
}

- (void)showColorFromDictionary:(NSDictionary *)dict {
    int c = [[dict valueForKey:kColorKey] intValue];
    UIColor *receivedColor = [UIColor colorWithRed:((c >> 16) & 0xFF) / 255.0
                                             green:((c >> 8) & 0xFF) / 255.0
                                              blue:(c & 0xFF) / 255.0
                                             alpha:((c >> 24) & 0xFF) / 255.0];
    
    [self resetView];
    self.view.backgroundColor = receivedColor;
}

- (void)turnOnFlashlight:(BOOL)flag {
    AVCaptureDevice *flashlight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (!flashlight) {
        NSLog(@"Can't play with torch");
        return;
    }
    
    if (flashlight.isTorchAvailable &&
        flashlight.hasTorch) {
        NSError *error;
        [flashlight lockForConfiguration:&error];
        
        if (error) {
            NSLog(@"ERROR: %@", error.localizedDescription);
            return;
        }
        
        if (flag) {
            if (flashlight.torchMode == AVCaptureTorchModeOn) {
                // If flashlight is turned on, the command is ignored
                return;
            } else {
                flashlight.torchMode = AVCaptureTorchModeOn;
                [self resetView];
                self.imageView.image = [UIImage imageNamed:@"Flashlight"];
                self.imageView.hidden = NO;
                [self performSelector:@selector(turnOffFlashlight)
                           withObject:nil
                           afterDelay:15.0];
            }
        } else {
            flashlight.torchMode = AVCaptureTorchModeOff;
            [self resetView];
        }
        
        [flashlight unlockForConfiguration];
        
    }
}

- (void)turnOffFlashlight {
    [self turnOnFlashlight:NO];
}

- (void)showTextFromDictionary:(NSDictionary *)dict {
    NSString *text = [dict objectForKey:kTextKey];
    [self showText:text];
}

- (void)showText:(NSString *)text {
    self.messageLabel.text = text;
    self.messageLabel.font = [UIFont boldSystemFontOfSize:20.0];
    
    [self resetView];
    self.messageLabel.hidden = NO;
}

- (void)resetView {
    self.imageView.hidden = YES;
    self.messageLabel.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (BOOL)updateLastId:(double)receivedId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    double savedId = [[userDefaults valueForKey:kLastId] doubleValue];
    
    if (receivedId > savedId) {
        [userDefaults setObject:@(receivedId) forKey:kLastId];
        [userDefaults synchronize];
        return YES;
    }
    
    return NO;
    
}

@end
