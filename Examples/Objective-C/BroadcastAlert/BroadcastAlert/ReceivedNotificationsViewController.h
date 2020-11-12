//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceivedNotificationsViewController : UITableViewController

- (void)addNotificationDictionary:(NSDictionary*)dictionary fromUUID:(NSString*)uuid;
+ (void)addNotificationToFile:(NSDictionary*)dictionary fromUUID:(NSString*)uuid;
+ (BOOL)clearReceivedNotifications;

@end
