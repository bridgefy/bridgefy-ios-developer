//
//  BFTransmitter.h
//  Bridgefy
//
//  Created by Daniel Heredia on 4/28/16.
//  Copyright © 2016 Bridgefy Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFConstants.h"


//! Project version number for BFTransmitter.
FOUNDATION_EXPORT double BFTransmitterVersionNumber;
//! Project version string for BFTransmitter.
FOUNDATION_EXPORT const unsigned char BFTransmitterVersionString[];

@class BFTransmitter;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol to be implemented by the client in order to be notified about certain events like 
 *  successful transmission of packets, new connections and disconnections, reception of packets and others.
 */
@protocol BFTransmitterDelegate<NSObject>
/**
 *  Indicates that a packet was successfully to another user using direct transmission
 * (for more details see BFSendingOption).
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 *  @param packetID ID of the packet.
 */
- (void)transmitter:(BFTransmitter *)transmitter didSendDirectPacket:(NSString *)packetID;
/**
 *  Indicates that a packet that was sent using direct transmission failed.
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 *  @param packetID ID of the packet.
 *  @param error    Related error.
 */
- (void)transmitter:(BFTransmitter *)transmitter didFailForPacket:(NSString *)packetID error:(NSError * _Nullable)error;
/**
 *  Indicates that a packet that is destined to the local user has been received.
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 *  @param dictionary Dictionary received (may be nil, if data isn't).
 *  @param data       Data received (may be nil, if dictionary isn't).
 *  @param user   User that sends the packet.
 *  @param packetID   ID of the packet.
 *  @param broadcast  Indicates if the packet includes the broadcast option (see BFSendingOption).
 *  @param mesh       Indicates if the message was received via mesh.
 */
- (void)transmitter:(BFTransmitter *)transmitter
        didReceiveDictionary:(NSDictionary<NSString *, id> * _Nullable) dictionary
                    withData:(NSData * _Nullable)data
                    fromUser:(NSString *)user
                    packetID:(NSString *)packetID
                   broadcast:(BOOL)broadcast
                        mesh:(BOOL)mesh;
/**
 *  Indicates that a connection has been established.
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 *  @param user User that has established connection.
 */
- (void)transmitter:(BFTransmitter *)transmitter didDetectConnectionWithUser:(NSString *)user;
/**
 *  Indicates that a used has disconnected from the local user.
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 *  @param user The disconnected user.
 */
- (void)transmitter:(BFTransmitter *)transmitter didDetectDisconnectionWithUser:(NSString *)user;
/**
 *  Method invoked when the transmitter could not be started.
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 *  @param error Error with the reason of this event.
 */
- (void)transmitter:(BFTransmitter *)transmitter didFailAtStartWithError:(NSError *)error;

@optional
/**
 *  Indicates if a packet was added to the mesh forwarding process.
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 *  @param packetID ID of the packet.
 */
- (void)transmitter:(BFTransmitter *)transmitter meshDidAddPacket:(NSString *)packetID;
/**
 *  Is called when a packet that was sent via mesh reach its destination,
 *  don't depend on the call of this method, because due to the nature of the
 *  forwarding mesh algorithm is not always called even if the receiver gets the packet.
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 *  @param packetID ID of the packet.
 */
- (void)transmitter:(BFTransmitter *)transmitter didReachDestinationForPacket:( NSString *)packetID;
/**
 *  Is almost the same than transmitter:meshDidAddPacket: with the difference that this method is called when
 *  the packet was first intented to send via direct transmission (for more details see BFSendingOption).
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 *  @param packetID ID of the packet.
 */
- (void)transmitter:(BFTransmitter *)transmitter meshDidStartProcessForPacket:( NSString *)packetID;
/**
 *  Indicates that a packet was discarded of the mesh process.
 *  so it won't reach its destination. In the case of broadcast packets,
 *  a destination could be reached before the call of this method.
 *  (for more details see BFSendingOption).
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 *  @param packetIDs ID's of the packets that has been discarded.
 */
- (void)transmitter:(BFTransmitter *)transmitter meshDidDiscardPackets:(NSArray<NSString *> *)packetIDs;
/**
 *  Indicates that a packet was rejected of the mesh process because its size
 *  exceeds 2048 bytes, if you want to send a packet using the mesh option
 *  the packet must not exceed this limit.
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 *  @param packetID ID of the packet that mesh rejected.
 */
- (void)transmitter:(BFTransmitter *)transmitter meshDidRejectPacketBySize:(NSString *)packetID;
/**
 Method used to notify about certain events occurred in the transmitter (these are not necessarlly errors).
 
 @param transmitter The BFTransmitter instance that invokes the method.
 @param event       Kind of the event.
 @param description Description of the event.
 */
- (void)transmitter:(BFTransmitter *)transmitter didOccurEvent:(BFEvent)event description:(NSString *)description;
/**
 *  Indicates that a secure connection has been established.
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 *  @param user The user that has established secure connection.
 */
- (void)transmitter:(BFTransmitter *)transmitter didDetectSecureConnectionWithUser:(NSString *)user;
/**
 *  Asks if a secure connection should be  established by default with a detected user.
 *  If this method is not implemented, by default the secure connection won't be established.
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 *  @param user The involved user.
 *
 *  @return YES if should be established, not otherwise.
 */
- (BOOL)transmitter:(BFTransmitter *)transmitter shouldConnectSecurelyWithUser:(NSString *)user;
/**
 *  This method is invoked when the transmitter is running but there isn't any network interface
 *  to use.
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 */
- (void)transmitterNeedsInterfaceActivation:(BFTransmitter *)transmitter;
/**
 *  Method invoked when there is another instance already running.
 *
 *  @param transmitter The BFTransmitter instance that invokes the method.
 */
- (void)transmitterDidDetectAnotherInterfaceStarted:(BFTransmitter *)transmitter;

@end

/**
 *  This class is the main interface between the client and Bridgefy Framework, the instance of this class
 *  is used mainly for the transmission and reception of packets, but also allows to configure several option.
 */
@interface BFTransmitter : NSObject
/**
 *  This reference is used to notify the client about certain events like successful transmission of packets, new connections and disconnections and reception of packets, in order to the client receives the incoming packets is mandatory to set this reference.
 */
@property (nonatomic, weak) id <BFTransmitterDelegate> _Nullable delegate;
/**
 *  Array of strings with the nearby detected peers.
 */
@property (nonatomic, readonly) NSArray<NSString *> * _Nullable activePeers;
/**
 *  Identifier assigned to the local user. It changes each time a session is generated.
 */
@property (nonatomic, readonly) NSString * _Nullable currentUser;
/**
 *  Base 64 representation of the public key of the local user (key is used to establish secure connections),
 *  this property is useful if a remote user (not nearby user that has not established a secure connection before)
 *  wants to send encrypted information to the local user via mesh. In order to this to happend, the other user must
 *  import this key. It changes each time a session is generated.
 */
@property (nonatomic, readonly) NSString * _Nullable localPublicKey;
/**
 *  Indicates if a session already exists, this session is persistent and must be generated in order to transmit and receive packets. 
 *  If there is no an existing session, this will be generated automatically by the transmitter when it starts. This session contains 
 *  unique data used to identify the current user.
 */
@property (nonatomic, readonly) BOOL hasSession;
/**
 *  YES if the instance of BFTransmitter has been started.
 */
@property (nonatomic, readonly) BOOL isStarted;
/**
 *  Indicates the current status of the network, for further details see NetworkState.
 */
@property (nonatomic, readonly) BFNetworkConnectionStatus networkStatus;
/**
 *  Indicates if the background mode is enabled, it's YES when is enabled and NO otherwise.
 *  this mode allows to preserve the active connections when the app is sent to background.
 *  In order to enable the background mode you will need to add the `UIBackgroundModes`key to 
 *  your `Info.plist` file and setting the key’s value to an array containing one of the strings 
 *  `bluetooth-peripheral` and `bluetooth-central`, if these keys are not added the framework will launch an error.
 */
@property (nonatomic, getter=isBackgroundModeEnabled) BOOL backgroundModeEnabled;

/**
 *  Enables/disables the reception of broadcast packets, nevertheless these can still be sent.
 *  By default the value is YES (enabled)
 */
@property (nonatomic, getter=isBroadcastReceptionEnabled) BOOL broadcastReceptionEnabled;


- (id)init NS_UNAVAILABLE;
 /**
 Creates an instance of BFTransmitter using a certain api key.
 
 @param apiKey Api key to be used by the transmitter.

 @return The instance of BFTransmitter.
 */
- (id)initWithApiKey:(NSString *)apiKey;

/**
 Creates an instance of BFTransmitter using a certain api key and indicating the
 dispatch queue to be used.

 @param apiKey Api key to be used by the transmitter.
 @param queue The dispatch queue to be used by BFTransmitter.
 @return The instance of BFTransmitter
 */
-(id)initWithApiKey:(NSString *)apiKey andQueue:(dispatch_queue_t) queue;

/**
 *  Send a dictionary to other user. This method is asynchronous, but an initial parameters 
 *  validation is performed over the current queue.
 *
 *  @param dictionary Dictionary to send.
 *  @param user       The user that is going to receive the dictionary. Nil if the packet includes the broadcast option.
 *  @param options    Sending options (see BFSendingOptions fot further details).
 *  @param error      Reference to an nil NSError object, it will be set if an error happens.
 *
 *  @return Returns an string with an identifier for the packet sent, will be nil if some error occurred.
 */
- (NSString * _Nullable)sendDictionary:(NSDictionary<NSString *, id> *)dictionary
                                toUser:(NSString * _Nullable)user
                               options:(BFSendingOption)options
                                 error:(NSError *_Nullable*_Nullable)error;
/**
 *  Send an NSData object to other user. This method is asynchronous, but an initial parameters 
 *  validation is performed over the current queue.
 *
 *  @param data    NSData to be sent to other user.
 *  @param user    The user that is going to receive the dictionary. Nil if the packet includes the broadcast option.
 *  @param options Sending options (see BFSendingOptions fot further details).
 *  @param error   Reference to an nil NSError object, it will be set if an error happens.
 *
 *  @return  Returns an string with an identifier for the packet sent, will be nil if some error occurred.
 */

- (NSString * _Nullable)sendData:(NSData *)data
                          toUser:(NSString * _Nullable)user
                         options:(BFSendingOption)options
                           error:(NSError *_Nullable *_Nullable)error;
/**
 *  Send a dictionary and/or an NSData object to other user.  This method is asynchronous, but an initial 
 *  parameters validation is performed over the current queue.
 *
 *  @param dictionary Dictionary to send.
 *  @param data    NSData to be sent to other user.
 *  @param user    The user that is going to receive the dictionary. Nil if the packet includes the broadcast option.
 *  @param options Sending options (see BFSendingOptions fot further details).
 *  @param error   Reference to an nil NSError object, it will be set if an error happens.
 *
 *  @return  Returns an string with an identifier for the packet sent, will be nil if some error occurred.
 */
- (NSString * _Nullable)sendDictionary:(NSDictionary<NSString *, id> * _Nullable)dictionary
                              withData:(NSData * _Nullable)data
                                toUser:(NSString * _Nullable)user
                               options:(BFSendingOption)options
                                 error:(NSError *_Nullable*_Nullable)error;
/**
 *  Indicates if a user is currently available.
 *
 *  @param user Identifier of the user.
 *
 *  @return YES if is available, NO otherwise.
 */
- (BOOL)isUserAvailable:(NSString *)user;
/**
 *  Indicates if the connection with a certain user is secure.
 *
 *  @param user Identifier of the user.
 *
 *  @return YES if the user is available and a secure connection has been established, NO otherwise.
 */
- (BOOL)isSecureConnection:(NSString *)user;
/**
 *  Start the process to establish a secure connection with other user. Basicly a secure connection
 *  is the interchange of RSA public keys that allow to send and receive encrypted content.
 *
 *  @param user  Identifier of the user.
 *  @param error Reference to an nil NSError object, it will be set if an error occurs.
 */
- (void)establishSecureConnection:(NSString *)user error:(NSError *_Nullable*_Nullable)error;

/**
 *  Deletes the current session and stops the transmitter. A new session will be generated once the transmitter is started again.
 */
- (void)destroySession;
/**
 *  If the app is closed and the transmitter is not stopped before, this method cleans and saves some
 *  control data, the use is not mandatory but is recommended stop the transmitter or call this method before
 *  the app is closed.
 */
- (void)saveState;
/**
 *  Stops the transmitter, this method stops all the involved interfaces and the packet forwarding, also clean certain control data.
 *  Is recommended to stop the transmitter when the use is not necessary in order to save energy.
 */
- (void)stop;
/**
 *  Starts the BFTransmitter with an App Key and the default profile.
 */
- (void)start;
/**
 *  Starts the BFTransmitter with an App Key and a certain profile.
 *
 *  @param transmitterProfile Profile to be used for logs.
 */
- (void)startWithProfile:(BFTransmitterProfile)transmitterProfile;
/**
 *  Imports manually a public session from another user in other that encrypted content can be sent
 *  to the other user without the need of establish a secure connection before.
 *
 *  @param key  Base64 key representation
 *  @param user Identifier of the user.
 */
- (void)savePublicKey:(NSString *)key forUser:(NSString *)user;
/**
 *  Indicates if a key already exists for a certain user.
 *
 *  @param user User to check.
 *
 *  @return YES if the key exists, NO otherwise.
 */
- (BOOL)existsKeyForUser:(NSString *)user;
/**
 *  Get the value in hours that a user should reach without any activity
 *  to their secure connection expires, when a secure connection expires,
 *  encrypted content cannot be sent to the receiver until a new secure connection
 *  is established again. For this purpose, "activity" is when the user is in range,
 *  or encrypted content is sent even when the user is out of range.
 *
 *  @return A persistent value in hours.
 */
- (NSInteger)secureConnectionExpirationLimit;
/**
 *  Set the expiration limit explained previously, this value is persistent
 *  and is preferably set before instance BFTransmitter.
 *
 *  @param limit Value in hours to be saved.
 */
- (void)setSecureConnectionExpirationLimit:(NSInteger)limit;
/**
 *  Establish the log level that the framework will use (see BFLogLevel for further details).
 *
 *  @param logLevel Log level to be used.
 */
+ (void)setLogLevel:(BFLogLevel)logLevel;
/**
 *  Returns the current log level being used.
 *
 *  @return The log level value.
 */
+ (BFLogLevel)logLevel;

/**
 *  Set the api key to be used by the instances when they are initialized without any other api key.
 *
 * @param apiKey String representation of the api key.
 */
+ (void)setApiKey:(NSString *)apiKey;


/**
 * Calculates the final size of the data to send in bytes.
 *
 * @warning The use of this method is not recommended because it encodes the entire dictionary to
 *          determine the final size.
 *
 * @param dictionary Dictionary object to send
 * @param encryption Indicates if the dictionary woul be sent using encryption.
 * @return The number of bytes that would be used.
 */
+ (NSUInteger)transmissionSizeFor:(NSDictionary *)dictionary encryption:(BOOL)encryption;

@end

NS_ASSUME_NONNULL_END
