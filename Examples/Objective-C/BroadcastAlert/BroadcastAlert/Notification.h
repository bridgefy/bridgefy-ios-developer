//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

@property (nonatomic) NSInteger number;
@property (nonatomic, retain) NSString *senderId;
@property (nonatomic, retain) NSString *senderName;
@property (nonatomic, retain) NSDate* date;

@end
