//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

typedef NS_ENUM(NSUInteger, DeviceType) {
    DeviceTypeUndefined = 0,
    DeviceTypeAndroid,
    DeviceTypeIos
};

@property (nonatomic, retain) NSString* sender;
@property (nonatomic, retain) NSString* text;
@property (nonatomic) BOOL received;
@property (nonatomic, retain) NSDate* date;
@property (nonatomic) BOOL mesh;
@property (nonatomic) BOOL broadcast;
@property (nonatomic) DeviceType deviceType;

@end
