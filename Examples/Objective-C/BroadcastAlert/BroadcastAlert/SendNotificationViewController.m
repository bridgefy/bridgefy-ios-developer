//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import "SendNotificationViewController.h"
#import "ReceivedNotificationsViewController.h"
#import <BFTransmitter/BFTransmitter.h>
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import <AudioToolbox/AudioServices.h>

#ifndef SEND_NOTIF
#define SEND_NOTIF
#define kSentKey @"sent_n"
#define kReceivedKey @"recev_n"
#endif


@interface SendNotificationViewController ()<BFTransmitterDelegate>
{
    NSInteger sentNumber;
    NSInteger receivedNumber;
    BOOL shouldVibrate;
}
@property (nonatomic, retain) BFTransmitter * transmitter;
@property (nonatomic, weak) ReceivedNotificationsViewController * receivedNotifsController;


@end

@implementation SendNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Transmitter initialization
    self.transmitter = [[BFTransmitter alloc] initWithApiKey:@"YOUR_API_KEY"];
    self.transmitter.delegate = self;
    [self.transmitter start];
    
    //UI controls load
    sentNumber = [self getSentNotificationsNumber];
    receivedNumber = [self getReceivedNotificationsNumber];
    self.nameLabel.text = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME]];
    self.uuidLabel.text = [NSString stringWithFormat:@"%@", [self truncatedUUID]];
    [self refreshCounters];
    self.sentStatusLabel.text = @"";
    
    self.sendButton.layer.cornerRadius = 14.0;
    self.sendButton.layer.borderWidth = 2.0;
    self.sendButton.layer.borderColor = [UIColor redColor].CGColor;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    shouldVibrate = [[NSUserDefaults standardUserDefaults] boolForKey:VIBRATION_ENABLED];
    
    [self registerForNotifications];
}

-(void)refreshCounters
{
    self.sentNotificationsLabel.text =
    [NSString stringWithFormat:@"%ld", (long)sentNumber];
    self.receivedNotificationsLabel.text =
    [NSString stringWithFormat:@"%ld", (long)receivedNumber];
}

-(NSString *)truncatedUUID
{
    return [self.transmitter.currentUser substringToIndex:5];
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vibrationSettingChanged:)
                                                 name:VIBRATION_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(usernameWasUpdated:)
                                                 name:USERNAME_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetSentAlertsCounter:)
                                                 name:RESET_SENT_ALERTS_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteReceivedAlerts:)
                                                 name:DELETE_RECEIVED_ALERTS_NOTIFICATION
                                               object:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"received"])
    {
        self.receivedNotifsController = segue.destinationViewController;
    }
}


#pragma mark - Actions

-(IBAction)sendNotification:(id)sender
{
    //Sending the message.
    NSError * error;
    BFSendingOption options = (BFSendingOptionBroadcastReceiver |
                               BFSendingOptionNotEncrypted |
                               BFSendingOptionMeshTransmission);
    NSDictionary * dictionary = @{@"number": @(sentNumber + 1),
                                  @"date_sent": @(floor([[NSDate date] timeIntervalSince1970] * 1000)),
                                  @"device_name": [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME]
                                  };
    [self.transmitter sendDictionary:dictionary
                              toUser:nil
                             options:options
                               error:&error];
    if (error)
    {
        NSLog(@"Error %@", error.localizedDescription);
    }
}


#pragma mark - BFTransmitterDelegate

- (void)transmitter:(BFTransmitter *)transmitter meshDidAddPacket:(NSString *)packetID
{
    // Packet added to mesh
    // Just called when the option BFSendingOptionMeshTransmission was used
    sentNumber++;
    self.sentStatusLabel.text = [NSString stringWithFormat:
                                 @"Broadcasting alert number %ld",
                                 (long)sentNumber];
    [self updateSentNotifications:sentNumber];
    [self refreshCounters];
}

- (void)transmitter:(BFTransmitter *)transmitter didReachDestinationForPacket:( NSString *)packetID
{
    //Mesh packet reached destiny (no always invoked)
}

- (void)transmitter:(BFTransmitter *)transmitter meshDidStartProcessForPacket:( NSString *)packetID;
{
    //A message entered in the mesh process (was added).
    // Just called when the option BFSendingOptionFullTransmission was used.
}

- (void)transmitter:(BFTransmitter *)transmitter didSendDirectPacket:(NSString *)packetID
{
    //A direct message was sent
}

- (void)transmitter:(BFTransmitter *)transmitter didFailForPacket:(NSString *)packetID error:(NSError * _Nullable)error
{
    //A direct message transmission failed.
}

- (void)transmitter:(BFTransmitter *)transmitter meshDidDiscardPackets:(NSArray<NSString *> *)packetIDs
{
    //A mesh message was discared and won't still be transmitted.
}

- (void)transmitter:(BFTransmitter *)transmitter meshDidRejectPacketBySize:(NSString *)packetID
{
    NSLog(@"The packet %@ was rejected from mesh because it exceeded the limit size.", packetID);
}

- (void)transmitter:(BFTransmitter *)transmitter
didReceiveDictionary:(NSDictionary<NSString *, id> * _Nullable) dictionary
           withData:(NSData * _Nullable)data
           fromUser:(NSString *)user
           packetID:(NSString *)packetID
          broadcast:(BOOL)broadcast
               mesh:(BOOL)mesh
{
    receivedNumber++;
    [self updateReceivedNotifications:receivedNumber];
    
    if (shouldVibrate) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    [self refreshCounters];
    // A dictionary was received by BFTransmitter.
    if (self.receivedNotifsController)
    {
        // If the the notifications screen is shown
        // update it.
        [self.receivedNotifsController addNotificationDictionary:dictionary
                                                        fromUUID:user];
    } else
    {
        //Otherwise, just update the data in file.
        [ReceivedNotificationsViewController addNotificationToFile:dictionary
                                                          fromUUID:user];
    }
    
}

- (void)transmitter:(BFTransmitter *)transmitter didDetectConnectionWithUser:(NSString *)user
{
    //A connection was detected (no necessarily secure)
}

- (void)transmitter:(BFTransmitter *)transmitter didDetectDisconnectionWithUser:(NSString *)user
{
    // A disconnection was detected.
}

- (void)transmitter:(BFTransmitter *)transmitter didFailAtStartWithError:(NSError *)error
{
    NSLog(@"An error occurred at start: %@", error.localizedDescription);
}

- (void)transmitter:(BFTransmitter *)transmitter didOccurEvent:(BFEvent)event description:(NSString *)description
{
    NSLog(@"Event reported: %@", description);
    
    if (event == BFEventStartFinished) {
        NSUserDefaults *usrDefaults = [NSUserDefaults standardUserDefaults];
        if (![usrDefaults boolForKey:INFO_SHOWED]) {
            [self infoPressed:nil];
            [usrDefaults setBool:YES
                          forKey:INFO_SHOWED];
            [usrDefaults synchronize];
        }
    }
}

- (void)transmitter:(BFTransmitter *)transmitter didDetectSecureConnectionWithUser:(NSString *)user
{
    // A secure connection was detected
}

- (void)transmitter:(nonnull BFTransmitter *)transmitter didDetectNearbyUser:(nonnull NSString *)user {
    // A nearby user has been detected
}


- (void)transmitter:(nonnull BFTransmitter *)transmitter didFailConnectingToUser:(nonnull NSString *)user error:(nonnull NSError *)error {
    // An on-demand connection has failed
}


- (void)transmitter:(nonnull BFTransmitter *)transmitter userIsNotAvailable:(nonnull NSString *)user {
    // A user is no longer nearby
}


#pragma mark - Persistence of indicators
-(void)updateSentNotifications:(NSInteger)numNotifications
{
    [[NSUserDefaults standardUserDefaults] setObject:@(numNotifications) forKey:kSentKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSInteger)getSentNotificationsNumber
{
    NSNumber * value = [[NSUserDefaults standardUserDefaults] valueForKey:kSentKey];
    if (value == nil)
        return 0;
    return [value integerValue];
}
-(void)updateReceivedNotifications:(NSInteger)numNotifications
{
    [[NSUserDefaults standardUserDefaults] setObject:@(numNotifications) forKey:kReceivedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSInteger)getReceivedNotificationsNumber
{
    NSNumber * value = [[NSUserDefaults standardUserDefaults] valueForKey:kReceivedKey];
    if (value == nil)
        return 0;
    return [value integerValue];
}

#pragma mark - Info method

- (IBAction)infoPressed:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Broadcast Alert"
                                                                             message:@"This app is designed to send and receive alerts without an internet connection."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

#pragma mark - Notification handlers

- (void)vibrationSettingChanged:(NSNotification *)notification {
    shouldVibrate = [[NSUserDefaults standardUserDefaults] boolForKey:VIBRATION_ENABLED];
}

- (void)usernameWasUpdated:(NSNotification *)notification {
    self.nameLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
}

- (void)resetSentAlertsCounter:(NSNotification *)notification {
    sentNumber = 0;
    [self updateSentNotifications:sentNumber];
    [self refreshCounters];
    self.sentStatusLabel.text = @"";
}

- (void)deleteReceivedAlerts:(NSNotification *)notification {
    if ([ReceivedNotificationsViewController clearReceivedNotifications]) {
        receivedNumber = 0;
        [self updateReceivedNotifications:receivedNumber];
        [self refreshCounters];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
