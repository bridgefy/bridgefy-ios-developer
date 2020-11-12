//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import "Notification.h"

@implementation Notification

- (id)initWithCoder:(NSCoder*)decoder
{
    if (self = [super init]) {
        self.number = [[decoder decodeObjectForKey:@"number"] integerValue];
        self.senderId = [decoder decodeObjectForKey:@"senderId"];
        self.senderName = [decoder decodeObjectForKey:@"senderName"];
        self.date = [decoder decodeObjectForKey:@"date"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:@(self.number) forKey:@"number"];
    [encoder encodeObject:self.senderId forKey:@"senderId"];
    [encoder encodeObject:self.senderName forKey:@"senderName"];
    [encoder encodeObject:self.date forKey:@"date"];
}

@end
