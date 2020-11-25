//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import "Message.h"

@implementation Message

- (id)initWithCoder:(NSCoder*)decoder
{
    if (self = [super init]) {
        self.sender = [decoder decodeObjectForKey:@"sender"];
        self.text = [decoder decodeObjectForKey:@"text"];
        self.received = [[decoder decodeObjectForKey:@"received"] boolValue];
        self.date = [decoder decodeObjectForKey:@"date"];
        self.mesh = [[decoder decodeObjectForKey:@"mesh"] boolValue];
        self.broadcast = [[decoder decodeObjectForKey:@"broadcast"] boolValue];
        self.deviceType = (DeviceType)[[decoder decodeObjectForKey:@"device_type"] intValue];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:self.sender forKey:@"sender"];
    [encoder encodeObject:self.text forKey:@"text"];
    [encoder encodeObject:@(self.received) forKey:@"received"];
    [encoder encodeObject:self.date forKey:@"date"];
    [encoder encodeObject:@(self.mesh) forKey:@"mesh"];
    [encoder encodeObject:@(self.broadcast) forKey:@"broadcast"];
    [encoder encodeObject:@(self.deviceType) forKey:@"device_type"];
}

@end
