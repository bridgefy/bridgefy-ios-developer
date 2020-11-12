//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendNotificationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel* uuidLabel;
@property (nonatomic, retain) IBOutlet UILabel* sentNotificationsLabel;
@property (nonatomic, retain) IBOutlet UILabel* sentStatusLabel;
@property (nonatomic, retain) IBOutlet UILabel* receivedNotificationsLabel;
@property (nonatomic, retain) IBOutlet UIButton* sendButton;
@property (nonatomic, retain) IBOutlet UIView* controlsContainer;

- (IBAction)sendNotification:(id)sender;

@end
