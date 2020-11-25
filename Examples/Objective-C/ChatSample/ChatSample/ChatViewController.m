//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import "ChatViewController.h"

NSString* const broadcastConversation = @"broadcast";

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    [self.tableView setEstimatedRowHeight:100];
    
    [self setOnlineStatus];
    if (self.broadcastType) {
        self.navigationItem.title = @"Broadcast";
    }
    else {
        self.navigationItem.title = self.deviceName;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHidden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addMessage:(Message*)message
{
    [self.messages insertObject:message atIndex:0];
    [self addRowToTable];
}

- (void)updateOnlineTo:(BOOL)onlineStatus
{
    self.online = onlineStatus;
    [self setOnlineStatus];
}

- (void)setOnlineStatus
{
    if (self.broadcastType) {
        self.onlineLabel.textColor = [UIColor redColor];
        self.onlineLabel.text = @"Messages for all peers";
        return;
    }
    if (self.online) {
        self.onlineLabel.textColor = [UIColor redColor];
        self.onlineLabel.text = @"ONLINE PEER";
    }
    else {
        self.onlineLabel.textColor = [UIColor grayColor];
        self.onlineLabel.text = @"OFFLINE PEER";
    }
}

- (IBAction)sendText:(id)sender
{
    if ([self.textField.text isEqualToString:@""]) {
        return;
    }
    Message* message = [[Message alloc] init];
    message.text = self.textField.text;
    message.date = [NSDate date];
    message.received = NO;
    message.broadcast = self.broadcastType;

    if (self.broadcastType) {
        [self.chatDelegate sendMessage:message
                        toConversation:broadcastConversation];
    }
    else {
        //If conversation is not broadcast send a direct message to the UUID
        [self.chatDelegate sendMessage:message
                        toConversation:self.userUUID];
    }

    self.textField.text = @"";
    [self.messages insertObject:message atIndex:0];
    [self addRowToTable];
}

- (void)addRowToTable
{
    [self.tableView beginUpdates];
    NSIndexPath* index = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[ index ] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
}

#pragma mark - Table Data Source
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];

    UILabel* userLabel = [(UILabel*)cell.contentView viewWithTag:1000];
    UILabel* messageLabel = [(UILabel*)cell.contentView viewWithTag:1001];
    UILabel* dateLabel = [(UILabel*)cell.contentView viewWithTag:1002];
    UILabel* transmissionLabel = [(UILabel*)cell.contentView viewWithTag:1003];
    UIImageView* deviceTypeImageView = [(UIImageView*)cell.contentView viewWithTag:1004];
    Message* message = [self.messages objectAtIndex:indexPath.item];

    if (message.received) {
        userLabel.textColor = [UIColor redColor];
        userLabel.text = message.sender;
        transmissionLabel.textColor = message.mesh ? [UIColor blueColor] : [UIColor redColor];
        transmissionLabel.text = message.mesh ? @"MESH" : @"DIRECT";
        
        switch (message.deviceType) {
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
    }
    else {
        userLabel.textColor = [UIColor blueColor];
        userLabel.text = @"You:";
        transmissionLabel.text = @"";
        deviceTypeImageView.image = nil;
    }
    messageLabel.text = message.text;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    dateLabel.text = [dateFormatter stringFromDate:message.date];

    return cell;
}

#pragma mark - Table Delegate
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self.textField resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Keyboard management
- (void)keyboardShown:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [keyboardFrameBegin CGRectValue];
    CGFloat padding = 0.0;
    padding = self.view.safeAreaInsets.bottom;

    self.keyboardConstraint.constant = (frame.size.height * -1) + padding;
    [UIView animateWithDuration:.5f animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (void)keyboardHidden:(NSNotification*)notification
{
    [UIView animateWithDuration:.5f animations:^{
        self.keyboardConstraint.constant = 0;
        [self.view updateConstraints];
    }];
}

@end
