//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import "Notification.h"
#import "ReceivedNotificationsViewController.h"
#import "Constants.h"

#ifndef ReceivedNotifications
#define ReceivedNotificiations
#define FULLPATH(X) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] \
    stringByAppendingPathComponent:(X)]
#define kNotificationsFile @"notifs.txt"
#endif

@interface ReceivedNotificationsViewController ()
@property (nonatomic, retain) NSArray* notifications;
@end

@implementation ReceivedNotificationsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Load previous notifications
    self.notifications = [self.class loadNotifications];
    
    // Prevents a shadow on the nav bar when pushed
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
}

- (void)addNotificationDictionary:(NSDictionary*)dictionary fromUUID:(NSString*)uuid
{
    //Process the data sent by other peer.
    [self.class addNotificationToFile:dictionary
                             fromUUID:uuid];
    [self refreshData];
}

- (void)refreshData
{
    self.notifications = [self.class loadNotifications];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notifications count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];
    Notification* notification = [self.notifications objectAtIndex:indexPath.item];
    UILabel *fromUsernameLabel = [(UILabel *)cell.contentView viewWithTag:1001];
    UILabel *fromUUIDLabel = [(UILabel *)cell.contentView viewWithTag:1002];
    UILabel *alertNumberLabel = [(UILabel *)cell.contentView viewWithTag:1003];
    UILabel *dateLabel = [(UILabel *)cell.contentView viewWithTag:1004];
    UILabel *timeLabel = [(UILabel *)cell.contentView viewWithTag:1005];
    
    fromUsernameLabel.text = notification.senderName;
    fromUUIDLabel.text = [NSString stringWithFormat:@"(%@)", notification.senderId];
    alertNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)notification.number];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSString* dateString = [dateFormatter stringFromDate:notification.date];
    dateLabel.text = dateString;
    
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *timeString = [dateFormatter stringFromDate:notification.date];
    timeLabel.text = timeString;

    return cell;
}

#pragma mark - Clumsy data management

// The methods in this section are not relevant to show
// the BFTransmitter functionality.

+ (void)addNotificationToFile:(NSDictionary*)dictionary fromUUID:(NSString*)uuid
{
    Notification* notification = [[Notification alloc] init];
    notification.number = [dictionary[@"number"] integerValue];
    notification.senderId = [uuid substringToIndex:5];
    notification.senderName = dictionary[@"device_name"];
    double doubleDate = [dictionary[@"date_sent"] doubleValue] / 1000;
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:doubleDate];
    notification.date = date;

    NSMutableArray* notifications = [self loadNotifications];
    [notifications insertObject:notification
                        atIndex:0];

    NSString* filePath = FULLPATH(kNotificationsFile);
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:notifications];
    [data writeToFile:filePath atomically:YES];
}

+ (NSMutableArray*)loadNotifications
{
    NSString* filePath = FULLPATH(kNotificationsFile);
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSMutableArray* notifications;
    
    if (data) {
        notifications = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    if (notifications == nil)
        notifications = [[NSMutableArray alloc] init];

    return notifications;
}

+ (BOOL)clearReceivedNotifications {
    
    NSString* filePath = FULLPATH(kNotificationsFile);
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
    return [data writeToFile:filePath atomically:YES];
}

@end
