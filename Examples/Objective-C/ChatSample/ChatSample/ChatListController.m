//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import "ChatListController.h"
#import <BFTransmitter/BFTransmitter.h>
#import "Message.h"

#import "ChatViewController.h"

#ifndef ChatList
#define ChatList
#define FULLPATH(X) [[NSSearchPathForDirectoriesInDomains\
(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]\
stringByAppendingPathComponent:(X)]
#endif

NSInteger const onlineSection = 0;
NSString * const peersFile = @"peersfile";
NSString * const messageTextKey = @"text";
NSString * const peerNameKey = @"device_name";
NSString * const peerTypeKey = @"device_type";

@interface ChatListController ()<BFTransmitterDelegate, ChatViewControllerDelegate>
{
    NSString * openUUID;
    BOOL openStateOnline;
}
@property (nonatomic, retain) BFTransmitter * transmitter;
@property (nonnull, retain) NSMutableDictionary *peerNamesDictionary;
@property (nonatomic, retain) NSMutableArray * onlinePeers;
@property (nonatomic, retain) NSMutableArray * offlinePeers;
@property (nonatomic, weak) ChatViewController * chatController;
@end

@implementation ChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Load demo related data and register for background enter
    [self loadPeers];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savePeers)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    //Transmitter initialization
    [BFTransmitter setLogLevel:BFLogLevelTrace];
    self.transmitter = [[BFTransmitter alloc] initWithApiKey:@"YOUR API KEY"];
    self.transmitter.delegate = self;
    self.transmitter.backgroundModeEnabled = YES;
    [self.transmitter start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == onlineSection)
    {
        return [self.onlinePeers count];
    } else
    {
        return [self.offlinePeers count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == onlineSection)
    {
        return @"Online peers";
    } else
    {
        return @"Offline peers";
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"peerCell" forIndexPath:indexPath];
    
    // Just cell appereance configuration
    UILabel * peerIdLabel = [(UILabel *)cell.contentView viewWithTag:1000];
    UILabel * onlineStatusLabel = [(UILabel *)cell.contentView viewWithTag:1001];
    UIImageView * deviceTypeImageView = [(UIImageView *)cell.contentView viewWithTag:1002];
    NSString * identifier;
    if (indexPath.section == onlineSection)
    {
        onlineStatusLabel.textColor = [UIColor redColor];
        onlineStatusLabel.text = @"ONLINE";
        identifier = [self.onlinePeers objectAtIndex:indexPath.item];
    }else
    {
        onlineStatusLabel.textColor = [UIColor grayColor];
        onlineStatusLabel.text = @"OFFLINE";
        identifier = [self.offlinePeers objectAtIndex:indexPath.item];
    }
    
    NSDictionary *peerInfo = self.peerNamesDictionary[identifier];
    NSString *userDeviceName = peerInfo[@"name"];
    peerIdLabel.text = userDeviceName;
    
    DeviceType devType = (DeviceType)[peerInfo[@"type"] intValue];
    switch (devType) {
        case DeviceTypeUndefined:
            deviceTypeImageView.image = nil;
            break;
        case DeviceTypeAndroid:
            deviceTypeImageView.image = [UIImage imageNamed:@"android"];
            break;
            
        case DeviceTypeIos:
            deviceTypeImageView.image = [UIImage imageNamed:@"ios"];
            break;
    }
    
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Prepares to open a conversation with a concrete user.
    if (indexPath.section == onlineSection)
    {
        openUUID = [self.onlinePeers objectAtIndex:indexPath.item];
        openStateOnline = YES;
    }else
    {
        openUUID = [self.offlinePeers objectAtIndex:indexPath.item];
        openStateOnline = NO;
    }
    [self performSegueWithIdentifier:@"openContactChat" sender:self];
}

#pragma mark - ChatViewControllerDelegate
#pragma mark - 4
-(void)sendMessage:(Message *)message toConversation:(NSString *)uuid
{
    NSDictionary * dictionary;
    NSError * error;
    NSString * receiverUUID;
    BFSendingOption options;
    if (message.broadcast)
    {
        //A broadcast message don't have a concrete receiver
        //this is sent to all peers. For this reason
        //receiverUUID is nil.
        receiverUUID = nil;
        // The encryption option is not included because a broadcast message can't
        // be encrypted.
        options = (BFSendingOptionFullTransmission | BFSendingOptionBroadcastReceiver);
        
        // Creation of the dictionary for the message to be sent
        // We included the device name because is possible that
        // the final receiver doesn't have it.
        dictionary = @{
                       messageTextKey: message.text,
                       peerNameKey: [[UIDevice currentDevice] name],
                       peerTypeKey: @(DeviceTypeIos)
                       };
    } else
    {
        // The message isn't broadcast, instead is a direct message.
        // A direct message can be encrypted.
        receiverUUID = uuid;
        options = (BFSendingOptionFullTransmission | BFSendingOptionEncrypted);
        
        // Creation of the dictionary for the message to be sent
        dictionary = @{
                       messageTextKey: message.text
                       };
    }
    
    [self.transmitter sendDictionary:dictionary
                              toUser:receiverUUID
                             options:options
                               error:&error];
    if (error)
    {
        NSLog(@"Error %@", error.localizedDescription);
    }
    
    //Just persistence management
    [self saveMessage:message
      forConversation:uuid];
}


#pragma mark - Segue Methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChatViewController * chatController = (ChatViewController *)segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"openContactChat"])
    {
        // Conversation with a concrete user.
        chatController.online = openStateOnline;
        chatController.userUUID = openUUID;
        NSDictionary *peerInfo = self.peerNamesDictionary[openUUID];
        chatController.deviceName = peerInfo[@"name"];
        chatController.deviceType = (DeviceType)[peerInfo[@"type"] intValue];
        chatController.messages = [self loadMessagesForConversation:openUUID];
        chatController.broadcastType = NO;
    } else
    {
        // Broadcast conversation
        // (the messages will be sent to all available users)
        chatController.online = openStateOnline;
        chatController.userUUID = @"broadcast";
        chatController.messages = [self loadMessagesForConversation:broadcastConversation];
        chatController.broadcastType = YES;
    }
    
    chatController.chatDelegate =  self;
    
    self.chatController = chatController;
}


#pragma mark - BFTransmitterDelegate

- (void)transmitter:(BFTransmitter *)transmitter meshDidAddPacket:(NSString *)packetID
{
    //Packet added to mesh
}

- (void)transmitter:(BFTransmitter *)transmitter didReachDestinationForPacket:( NSString *)packetID
{
    //Mesh packet reached destiny (no always invoked)
}

- (void)transmitter:(BFTransmitter *)transmitter meshDidStartProcessForPacket:( NSString *)packetID
{
    //A message entered in the mesh process.
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

#pragma mark - 5
- (void)transmitter:(BFTransmitter *)transmitter
didReceiveDictionary:(NSDictionary<NSString *, id> * _Nullable) dictionary
           withData:(NSData * _Nullable)data
           fromUser:(NSString *)user
           packetID:(NSString *)packetID
          broadcast:(BOOL)broadcast
               mesh:(BOOL)mesh
{
    // A dictionary was received by BFTransmitter.
    if (dictionary[messageTextKey] != nil) {
        // If it contains a value for the key messageTextKey it's a message
        [self processReceivedMessage:dictionary
                            fromUser:user
                                mesh:mesh
                           broadcast:broadcast];
    } else {
        //If it doesn't contain the key messageTextKey it's the device name of the other user.
        [self processReceivedPeerInfo:dictionary
                              fromUser:user];
    }
    
}

#pragma mark - 1
- (void)transmitter:(BFTransmitter *)transmitter didDetectConnectionWithUser:(NSString *)user
{
    //A connection was detected (no necessarily secure)
}

#pragma mark - 3
- (void)transmitter:(BFTransmitter *)transmitter didDetectDisconnectionWithUser:(NSString *)user
{
    if (!user) {
        return;
    }
    // A disconnection was detected.
    [self discardUUID:user];
    [self.offlinePeers addObject:user];
    [self.tableView reloadData];
    if (self.chatController &&
        [self.chatController.userUUID isEqualToString:user])
    {
        //If currently a the related conversation is shown,
        //update the state.
        [self.chatController updateOnlineTo:NO];
    }
}

- (void)transmitter:(BFTransmitter *)transmitter didFailAtStartWithError:(NSError *)error
{
    NSLog(@"An error occurred at start: %@", error.localizedDescription);
}

- (void)transmitter:(BFTransmitter *)transmitter didOccurEvent:(BFEvent)event description:(NSString *)description
{
    NSLog(@"Event reported: %@", description);
}

#pragma mark - 2
-(BOOL)transmitter:(BFTransmitter *)transmitter shouldConnectSecurelyWithUser:(NSString *)user
{
    return YES; //if YES establish connection with encryption capacities.
}

-(void)transmitter:(BFTransmitter *)transmitter didDetectSecureConnectionWithUser:(nonnull NSString *)user
{
    // A secure connection was detected,
    // A secure connection has encryption capabilities.
    
    // Check if there's a name saved for this user.
    [self processNameForUser:user];
    
    //Update the table accord this new connection
    [self discardUUID:user];
    [self.onlinePeers addObject:user];
    [self.tableView reloadData];
    if (self.chatController &&
        [self.chatController.userUUID isEqualToString:user])
    {
        [self.chatController updateOnlineTo:YES];
    }
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


#pragma mark - Name and message utils

- (void)processNameForUser:(nonnull NSString *)user {
    
    // If there's not a name a temporary name is assigned
    // meanwhile the real name is received.
    if (!self.peerNamesDictionary[user]) {
        NSString * tmpName = [NSString stringWithFormat:@"Id: %@", [user substringToIndex:5]];
        NSDictionary *peerInfo = @{@"name": tmpName,
                                   @"type": @(DeviceTypeUndefined)};
        [self.peerNamesDictionary setObject:peerInfo forKey:user];
    }
    
    // In case the other user doesn't have our device name,
    // this is sent as an initial message.
    [self sendDeviceNameToUser:user];
    
}

- (void)sendDeviceNameToUser:(NSString *)user {
    NSDictionary *dictionary = @{
        peerNameKey: [[UIDevice currentDevice] name],
        peerTypeKey: @(DeviceTypeIos)
    };
    NSError *error;
    BFSendingOption options = (BFSendingOptionDirectTransmission | BFSendingOptionEncrypted);
    
    [self.transmitter sendDictionary:dictionary
                              toUser:user
                             options:options
                               error:&error];
    if (error)
    {
        NSLog(@"Error %@", error.localizedDescription);
    }
}

- (void)processReceivedMessage:(NSDictionary *)dictionary
                      fromUser:(NSString *)user
                          mesh:(BOOL)mesh
                     broadcast:(BOOL)broadcast {
    // Processing a new message
    NSString * text = dictionary[messageTextKey];
    Message * message = [[Message alloc] init];
    message.text = text;
    message.received = YES;
    message.date = [NSDate date];
    message.mesh =  mesh;
    message.broadcast = broadcast;// If YES, received message is broadcast.
    NSString * conversation;
    if (message.broadcast)
    {
        conversation = broadcastConversation;
        message.deviceType = (DeviceType)[dictionary[peerTypeKey] intValue];
        // The deviceName will be processed because it's possible we don't have it yet.
        [self processReceivedPeerInfo:dictionary
                             fromUser:user];
        
    } else
    {
        conversation = user;
        message.deviceType = DeviceTypeUndefined;
    }
    
    message.sender = [self.peerNamesDictionary[user] objectForKey:@"name"];
    
    [self saveMessage:message forConversation:conversation];
    
    // YES if the related conversation for the user is shown
    BOOL showingSameUser = !message.broadcast &&
    self.chatController &&
    [self.chatController.userUUID isEqualToString:user];
    // YES if received message is for broadcast and broadcast is shown
    BOOL showingBroadcast = message.broadcast &&
    self.chatController != nil &&
    self.chatController.broadcastType;
    
    if (showingBroadcast || showingSameUser)
    {
        // If the related conversation to the message is being shown.
        // update messages.
        [self.chatController addMessage:message];
    }
}

- (void)processReceivedPeerInfo:(NSDictionary *)peerInfo
                       fromUser:(NSString *)user {
    NSString *existingDeviceName = [self.peerNamesDictionary[user] objectForKey:@"name"];
    NSString *receivedDeviceName = peerInfo[peerNameKey];
    int receivedDeviceType = [[peerInfo valueForKey:peerTypeKey] intValue];
    
    if (![existingDeviceName isEqualToString:receivedDeviceName]) {
        NSString * name = [NSString stringWithFormat:@"%@ (%@)",
                           receivedDeviceName,
                           [user substringToIndex:5]];
        NSDictionary *userInfo = @{@"name": name,
                                   @"type": @(receivedDeviceType)};
        [self.peerNamesDictionary setObject:userInfo forKey:user];
        [self.tableView reloadData];
    }
}

#pragma mark - Clumsy data management

// The methods in this section are not relevant to show
// the BFTransmitter functionality.

-(void)discardUUID:(NSString *)uuid
{
    
    if ([self.onlinePeers indexOfObject:uuid] != NSNotFound)
    {
        [self.onlinePeers removeObject:uuid];
    }
    
    if ([self.offlinePeers indexOfObject:uuid] != NSNotFound)
    {
        [self.offlinePeers removeObject:uuid];
    }
}

-(void)saveMessage:(Message *)message forConversation:(NSString *)conversation
{
    NSString * chatFile = [NSString stringWithFormat:@"%@.chat", conversation];
    NSString * filePath = FULLPATH(chatFile);
    NSMutableArray * messages = [self loadMessagesForConversation:conversation];
    [messages insertObject:message atIndex:0];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:messages];
    [data writeToFile:filePath atomically:YES];
    
}

-(NSMutableArray *)loadMessagesForConversation:(NSString *)conversation
{
    NSString * chatFile = [NSString stringWithFormat:@"%@.chat", conversation];
    NSString * filePath = FULLPATH(chatFile);
    NSData * data = [NSData dataWithContentsOfFile:filePath];
    
    NSMutableArray *messages;
    if (data) {
        messages = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    if (messages == nil)
        messages = [[NSMutableArray alloc] init];
    
    return messages;
}

-(void)savePeers
{
    NSString * filePath = FULLPATH(peersFile);
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:self.peerNamesDictionary];
    [data writeToFile:filePath atomically:YES];
}

-(void)loadPeers
{
    NSString * filePath = FULLPATH(peersFile);
    NSData * data = [NSData dataWithContentsOfFile:filePath];
    if (data != nil) {
        self.peerNamesDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.offlinePeers = [[self.peerNamesDictionary allKeys] mutableCopy];
    }
    
    
    if (self.peerNamesDictionary == nil) {
        self.peerNamesDictionary = [[NSMutableDictionary alloc] init];
        self.offlinePeers = [[NSMutableArray alloc] init];
    }
    
    self.onlinePeers = [[NSMutableArray alloc] init];
    
}

@end
