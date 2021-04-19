### Bridgefy 

<p align="center"><a href="https://bridgefy.me" target="_blank" rel="noopener noreferrer"><img width="400" src="https://bridgefy.me/wp-content/uploads/2021/04/bridgefy_logo_red.svg" alt="Vue logo"></a></p>

![Cocoapods](https://img.shields.io/cocoapods/v/BFTransmitter) ![GitHub last commit](https://img.shields.io/github/last-commit/bridgefy/bridgefy-ios-developer) ![GitHub issues](https://img.shields.io/github/issues-raw/bridgefy/bridgefy-ios-developer?style=plastic)

### Overview

The Bridgefy Software Development Kit (SDK) is a state-of-the-art, plug-and-play package of awesomeness that will let people use your mobile app when they don’t have access to the Internet by using mesh networks.

Integrate the Bridgefy SDK into your [Android](https://github.com/bridgefy/bridgefy-android-samples) and [iOS](https://github.com/bridgefy/bridgefy-ios-developer) app to reach the 3.5 billion people that don’t always have access to an Internet connection, and watch engagement and revenue grow!

<p>Website. https://bridgefy.me/sdk/</p>
<p>Email. contact@bridgefy.me</p>
<p>Twitter. https://twitter.com/bridgefy</p>
<p>Facebook. https://www.facebook.com/bridgefy</p>

---

 **IMPORTANT NOTE!**  
This repository doesn't contain the official version of the framework. In order to run the example projects, please go to the [distribution repository][BRIDGEFY_DIST] to get the latest official version of `BFTransmitter.framework` and replace the local copy. You will also need to have an API key for every project you run, so please go to [Bridgefy website][BRIDGEFY_WEB] to know how to obtain it.

---

## Pod setup

Create your Podfile, it should look like this:

```

target 'YOUR_TARGET' do
  pod 'BFTransmitter'
end
```

Where `YOUR_TARGET` is the name of your project's target.

Setup the new source. This step is necessary so BFTransmitter can be added to the Pod list:

```bash
$ pod setup
```

And install the pod:

```bash
$ pod install
```
---

## Manual setup

Download the official version of `BFTransmitter.framework` [here][BRIDGEFY_DIST], open your project and drag the file and drop it in the "Embedded Binaries" section of your project as shown in the following picture:  
![Framework file](img/addframework.png)  
Select the option "Copy items if needed" and you will be able to use the framework.

### Swift projects
If you need to use the framework in a Swift project, you will need to create a bridging header. This process is described [here][BRIDGING_HEADER]. An easy way to do it is by just creating an Objective-C class, then XCode will ask you to create the bridging header automatically. Once created, delete the new class and edit the file `YOUR_PROJECT-Bridging-Header.h` to replace the content with `#import <BFTransmitter/BFTransmitter.h>`.

---

## Submit to the App Store

In order to submit to the App Store, you will need to add the key `NSBluetoothPeripheralUsageDescription` to `Info.plist`, as a value to introduce a description of the use of Bluetooth in the app. This message will be shown to the user.

Additionally, if you made a **manual setup** (you **didn't** use CocoaPods), you will need to strip the architectures `i386` and `x86_64`, this is because the framework is sent including these architectures, so you can run your apps in the simulator, although the App Store doesn't accept them for distribution. You can do this by adding the following Run Script to the phases of your target:

```sh
if [ "${CONFIGURATION}" = "Release" ]; then

DESTINATION="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
FRAMEWORK_NAME="BFTransmitter"
FRAMEWORK_PATH="${DESTINATION}/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

lipo -remove i386 "$FRAMEWORK_PATH" -output "$FRAMEWORK_PATH"
lipo -remove x86_64 "$FRAMEWORK_PATH" -output "$FRAMEWORK_PATH"
echo "Fat library stripped: ${FRAMEWORK_PATH}"

fi
```

If you don't know how to add Run Scripts, you can check the following image:

![Run Script](img/runscript.png)  

---

### Configuring Transmitter Framework without Internet
Go to your Bridgefy Dashboard, then go to your Licence List and download the .txt file inside, which contains a String. 

![Dashboard licence](https://raw.githubusercontent.com/bridgefy/bridgefy-android-samples/master/img/dashboard.png)  

Copy the certificate string that was generated along with your app's API Key. 

In info.plist, create an entry named `com.bridgefy.SDKLicense` and paste the text value. If there is no Internet connection available, the Transmitter Framework will use this certificate to validate your licence.

![Dashboard licence](./img/cert.png)

---

## Operation modes

### 1. Automatic

Automatic operation mode is the same as in previous versions of the SDK, where all the connections are handled seamlessly by the SDK to create a mesh network. The size of this network depends on the number of devices connected and the environment as a variable factor, allowing you to join nodes in the same network or nodes in different networks.

![alt Mesh Network](img/Mobile_Adhoc_Network.gif "Mesh Network")

### 2. On-demand

This is a new operation mode where the SDK notifies whenever a nearby device is detected, but it doesn't establish a connection; instead, the client app can choose to which nearby device connect. Once the connection is no longer required, it can be closed. You can connect to up to 5 devices at any given moment.

![alt Node](img/single_node_network.gif "Single Node")

It is essential to consider that in On-Demand mode for this version, **only direct messages are supported**; mesh and broadcast messages will be supported in a later version.

---

## Usage

### 1. Instance
The following code shows how to create an instance of BFTransmitter (using your API key) and how to assign the delegate. This last action isn't mandatory but is necessary in order to be notified about connections and data reception:

```objective-c
//Objective-C
    BFTransmitter * transmitter = [[BFTransmitter alloc] initWithApiKey:@"YOUR API KEY"];
    //BFTransmitterDelegate protocol must be implemented.
    transmitter.delegate = self;
```
```swift
//Swift
    let transmitter = BFTransmitter(apiKey: "YOUR API KEY")
    //BFTransmitterDelegate protocol must be implemented.
    transmitter.delegate = self
```

The string "YOUR API KEY" represents a valid API key. This is necessary so the transmitter can be started. An Internet connection is needed at least for the first time the transmitter is instantiated in order to validate the license.


### 2. Start transmitter
The transmitter can be started or stopped in order to use it only when necessary, and to optimize resources. The default state is stopped, and is activated this way:

```objective-c
//Objective-C
[transmitter start];
```
```swift
//Swift
transmitter.start()
```
The first time the transmitter is started, a session will be automatically created. This session contains a unique identifier for the current user, and some other data necessary for the encryption. The session management will be discussed further on in the section "Session".

By default the trasmitter starts using the `Automatic connection` mode; if you want to change the operation mode you have to pass it as a parameter when starting the transmitter using the following code:

```objective-c
//Objetive-C
// Automatic mode
[transmitter startWithConnectionMode:BFTransmitterConnectionModeAutomatic];
// On-demand mode
[transmitter startWithConnectionMode:BFTransmitterConnectionModeOnDemand];
```
```swift
//Swift
// Automatic mode
transmitter.start(with: .automatic)
// On-demand mode
transmitter.start(with: .onDemand)
```

To stop it, use the following code:

```objective-c
//Objective-C
[transmitter stop];
```
```swift
//Swift
transmitter.stop()
```
If something goes wrong during instantiation or start, the following methods will let you know the reason:

```objective-c
//Objective C
// Tipically this method is called when your license is expired or not valid.
- (void)transmitter:(BFTransmitter *)transmitter didFailAtStartWithError:(NSError *)error;
// This isn't necessarily an error, but it lets you know if the transmitter needs Internet to validate the license.
- (void)transmitter:(BFTransmitter *)transmitter didOccurEvent:(BFEvent)event description:(NSString *)description;
```
```swift
//Swift
// Tipically this method is called when your license is expired or not valid.
public func transmitter(_ transmitter: BFTransmitter, didFailAtStartWithError error: Error)
// This isn't necessarily an error, but it lets you know if the transmitter needs Internet to validate the license.
public func transmitter(_ transmitter: BFTransmitter, didOccur event: BFEvent, description: String)
```

### 3. Nearby peer detection

#### Automatic mode

When a peer is detected, the connection is made automatically. The following method is invoked when a peer has established connection:

```objective-c
//Objective C
- (void)transmitter:(BFTransmitter *)transmitter didDetectConnectionWithUser:(NSString *)userUser;
```
```swift
//Swift
public func transmitter(transmitter: BFTransmitter!, didDetectConnectionWithUser userUser: String!)
```
**transmitter**: Instance of BFTransmitter invoking the method.

**user**: Identifier for the user that has established a connection. Must be saved in order to send information to that user.

When a peer is disconnected (out of range), the following method will be invoked:

```objective-c
//Objective-C
- (void)transmitter:(BFTransmitter *)transmitter didDetectDisconnectionWithUser:(NSString *)userUser;
```
```swift
//Swift
public func transmitter(transmitter: BFTransmitter!, didDetectDisconnectionWithUser userUser: String!)
```
**transmitter**: Instance of BFTransmitter invoking the method.

**user**: Identifier of the disconnected user.

#### On-demand mode

When a nearby peer is detected, it is notified with the following transmitter delegate method.


```objective-c
//Objective-C
- (void)transmitter:(nonnull BFTransmitter *)transmitter didDetectNearbyUser:(nonnull NSString *)user
```
```swift
//Swift
func transmitter(_ transmitter: BFTransmitter, didDetectNearbyUser user: String)
```
**transmitter**: Instance of BFTransmitter invoking the method.

**user**: Identifier for the user that has been detected.

To establish a connection with a nearby peer, you have to invoke the following function passing the peer's ID with whom you want to connect.

```objective-c
//Objective-C
[transmitter connectToUser:(nonnull NSString *) error:(NSError * _Nullable * _Nullable)];
```
```swift
//Swift
transmitter.connect(toUser: String, error: NSErrorPointer)
```

**user**: Identifier for the user that we want to connect.

**error**: Reference to an NSError object, must be nil before the call to the method. If there's an error while connecting with the user, it will be assigned to it.

To disconnect from a peer, you have to pass its ID to the function.

```objective-c
//Objective-C
[transmitter disconnectFromUser:(nonnull NSString *) error:(NSError * _Nullable * _Nullable)];
```
```swift
//Swift
transmitter.disconnect(fromUser: String, error: NSErrorPointer)
```

**user**: Identifier for the user that we want to disconnect.

**error**: Reference to an NSError object, must be nil before the call to the method. If there's an error while disconnectiong from the user, it will be assigned to it.

After the disconnection occurs, you'll receive a notification via the `didDetectDisconnectWithUser` delegate method.

### 4. Send data
The following method is used to send data to another peer. This method performs an initial validation over the received parameters, and if everything is correct, generates a packet identifier that is returned to the client. All of this initial process is synchronous. After this, the packet enters to an asynchronous process for the transmission of the packet.

```objective-c
//Objective-C
- (NSString * _Nullable)sendDictionary:(NSDictionary<NSString *, id> * _Nullable)dictionary
                              withData:(NSData * _Nullable)data
                                toUser:(NSString * _Nullable)user
                               options:(BFSendingOption)options
                                 error:(NSError *_Nullable*_Nullable)error;
```
```swift
//Swift
func sendDictionary(dictionary: [String, AnyObject]?,
                 withData data: NSData?,
                   toUser user: String?,
                       options: BFSendingOption,
                         error: NSError?) -> String?
```
 **dictionary**: NSDictionary object to be sent to the other user, it can be nil if data isn't.

 **data**: NSData object to be sent to the other user, it can be nil if dictionary isn't.

 **options**: Indicates the different options used to send the data.

 **error**: Reference to an NSError object, must be nil before the call to the method. If there's an error while sending the data, it will be assigned to it.

 ***returns***: If the transmission started successfully, it will contain a unique identifier for the packet; otherwise it will be nil.

The following example shows how to send a dictionary to another peer when it's in range and no encryption is required:

```objective-c
//Objective-C
    // Initialize with a serializable NSDictionary object.
    NSDictionary *payload = @{@"text" : @"Text message."};
    // Identifier received previously in the connection detection.
    // This one is just an example.
    NSString *receiverUser = @"6655a16c-8209-46c4-9c51-21d8df3efb95";
    NSError *error = nil;
    NSString *packetID = [transmitter sendDictionary:payload
                                            withData:nil
                                              toUser:receiverUser
                                             options: (BFSendingOptionNoEncrypted |
                                                       BFSendingOptionDirectTransmission)
                                               error: &error];
```
```swift
//Swift
    // Initialize with a serializable NSDictionary object.
    let payload = ["text" : "Text message."]
    // Identifier received previously in the connection detection.
    // This one is just an example.
    let user = "6655a16c-8209-46c4-9c51-21d8df3efb95"
    let options: BFSendingOption = [.NoEncrypted, .DirectTransmission]
    do {
        try transmitter.sendDictionary(payload,
                                       withData: nil,
                                       toUser: user,
                                       options: options)
    }
    catch let err as NSError
    {
        print("Error: \(err)")
    }
```

The options will be explained further on, but in this example the options indicate that the information won't be encrypted and the transmission must be performed only when the other peer is in range.

If the packet was sent successfully, the following method will be invoked:

```objective-c
//Objective-C
- (void)transmitter:(BFTransmitter *)transmitter didSendDirectPacket:(NSString *)packetID;
```
```swift
//Swift
public func transmitter(transmitter: BFTransmitter, didSendDirectPacket packetID: String)
```
**packetID**: Unique identifier assigned to the packet. It's the same as the one returned by sendDictionary:

Otherwise, if there was an error while sending, this method will be invoked:

```objective-c
//Objective-C
- (void)transmitter:(BFTransmitter *)transmitter didFailForPacket:(NSString *)packetID error:(NSError * _Nullable)error;
```
```swift
//Swift
public func transmitter(transmitter: BFTransmitter, didFailForPacket packetID: String, error: NSError?)
```
**transmitter**: Instance of BFTransmitter invoking the method.

**packetID**: Unique identifier assigned to the packet, it's the same as the one returned by sendDictionary:

**error**: Error related to the problem.

### 5. Receive Data
When a packet has been received, the following method will be invoked:

```objective-c
//Objective-C
- (void)transmitter:(BFTransmitter *)transmitter
        didReceiveDictionary:(NSDictionary<NSString *, id> * _Nullable) dictionary
                    withData:(NSData * _Nullable)data
                    fromUser:(NSString *)user
                    packetID:(NSString *)packetID
                   broadcast:(BOOL)broadcast
                        mesh:(BOOL)mesh;
```
```swift
//Swift
    public func transmitter(transmitter: BFTransmitter,
                            didReceiveDictionary dictionary: [String, AnyObject]?,
                            withData data: NSData?,
                            fromUser user: String,
                            packetID: String,
                            broadcast: Bool,
                            mesh: Bool)
```
**transmitter**: Instance of BFTransmitter invoking the method.

**dictionary**: Received dictionary object, can be nil if data isn't nil.

**data**: Received NSData object, can be nil if dictionary isn't nil.

**user**: Identifier related to the user who is sending the packet.

**packetID**: Unique identifier related to the packet.

**broadcast**: Indicates if the packet received was received via broadcast.

**mesh**: Indicates if the packet was received via mesh (will be explained further on).

---

## Secure connections

Optionally, a secure connection can be established. In a secure connection, encrypted content can be sent using RSA encryption.

One option to do it is by implementing the following method:

```objective-c
//Objective-C
- (BOOL)transmitter:(BFTransmitter *)transmitter shouldConnectSecurelyWithUser:(NSString *)user;
```
```swift
//Swift
optional public func transmitter(transmitter: BFTransmitter, shouldConnectSecurelyWithUser user: String) -> Bool
```
**transmitter**: Instance of BFTransmitter invoking the method.

***return***: YES to establish a secure connection, NO otherwise.

This method is called when a connection has just been created, and the returned value is used to know if the process should keep creating a secure connection.

The other option to establish a secure connection is invoking the following method:

```objective-c
//Objective-C
- (void)establishSecureConnection:(NSString *)user
                            error:(NSError *_Nullable*_Nullable)error;
```
```swift
//Swift
public func establishSecureConnection(user: String,
                                      error: NSError?)
```
**user**: Identifier of the user.

**error**: Will be assigned if an error happens.

In both ways, the following delegate method will be invoked to indicate that the secure connection was successful:

```objective-c
//Objective-C
- (void)transmitter:(BFTransmitter *)transmitter didDetectSecureConnectionWithUser:(NSString *)userUser;
```
```swift
//Swift
optional public func transmitter(transmitter: BFTransmitter, didDetectSecureConnectionWithUser user: String)
```
**transmitter**: Instance of BFTransmitter invoking the method.

**user**: Identifier of the user.

The possibility to send encrypted content remains even after the other user has gone out of range (e.g. sending an encrypted mesh packet), but it depends on the secure connection expiration. Expiration is the amount of time during which a connection keeps existing, even without activity. When a secure connection expires, encrypted content cannot be sent to the receiver until a new secure connection is established again. For this purpose, "activity" is when the user is in range, or encrypted content is sent even when the user is out of range.  

The expiration limit is the same for all the connections and can be checked or set up using the following methods:

```objective-c
//Objective-C
//Get the expiration
- (NSInteger)secureConnectionExpirationLimit;
//Set the expiration
- (void)setSecureConnectionExpirationLimit:(NSInteger)limit;
```
```swift
//Swift
//Get the expiration
- (NSInteger)secureConnectionExpirationLimit;
//Set the expiration
- (void)setSecureConnectionExpirationLimit:(NSInteger)limit;
```

---

## Direct and mesh transmission

* **Direct transmission** is a mechanism used to deliver packets to a user that is nearby or visible (a connection has been detected).

* **Mesh transmission** is a mechanism used to deliver offline packets even when the receiving user isn't nearby or visible. It can be achieved taking advantage of other nearby peers; these receive the package, hold it, and forward to other peers trying to find the receiver.

A message can be transmitted using mesh transmission, direct transmission, or both. The options used to achieve this will be discussed in the following section.

---

## Sending options

There are several options for sending packets:

- **BFSendingOptionDirectTransmission**: Sends the packet only when the receiver is in range.
- **BFSendingOptionMeshTransmission**: Sends the packet using mesh. It doesn't need the receiver to be in range.
- **BFSendingOptionFullTransmission**: Tries to send the packet if the peer is in range, otherwise, includes the packet in the mesh process.
- **BFSendingOptionEncrypted**:  Sends the packet encrypted. It can cause an error if a secure connection has not been established at least once.
- **BFSendingOptionNoEncrypted**: Sends the packet without encryption.
- **BFSendingOptionBroadcastReceiver**: Sends a packet using mesh without a defined receiver. The packet is broadcast to all nearby users that are or aren't in range. If this option is used and encryption option is added, it will cause an error.

Some examples:

Sending a dictionary packet with encryption to another user via mesh:

```objective-c
//Objective-C
    NSDictionary *payload = @{@"text" : @"Text message."};
    NSString *receiverUser = @"6655a16c-8209-46c4-9c51-21d8df3efb95";
    [transmitter sendDictionary:payload
                       withData:nil
                         toUser:receiverUser
                        options: (BFSendingOptionEncrypted | BFSendingOptionMeshTransmission)
                          error: &error];
```
```swift
//Swift
    let payload = ["text" : "Text message."]
    let user = "6655a16c-8209-46c4-9c51-21d8df3efb95"
    let options: BFSendingOption = [.Encrypted, .MeshTransmission]
    try transmitter.sendDictionary(payload,
                                    withData: nil,
                                    toUser: user,
                                    options: options)
```

Sending a dictionary with encryption to another user, but only if the other user is near:

```objective-c
//Objective-C
    NSDictionary *payload = @{@"text" : @"Text message."};
    NSString *receiverUser = @"6655a16c-8209-46c4-9c51-21d8df3efb95";
    [transmitter sendDictionary:payload
                       withData:nil
                         toUser:receiverUser
                        options: (BFSendingOptionEncrypted | BFSendingOptionDirectTransmission)
                          error: &error];
```
```swift
//Swift
    let payload = ["text" : "Text message."]
    let user = "6655a16c-8209-46c4-9c51-21d8df3efb95"
    let options: BFSendingOption =  [.Encrypted, .DirectTransmission]
    try transmitter.sendDictionary(payload,
                                    withData: nil,
                                    toUser: user,
                                    options: options)
```

Sending a dictionary with encryption to another user, first using direct transmission, and if it fails, then using mesh:

```objective-c
//Objective-C
    NSDictionary *payload = @{@"text" : @"Text message."};
    NSString *receiverUser = @"6655a16c-8209-46c4-9c51-21d8df3efb95";
    [transmitter sendDictionary:payload
                       withData:nil
                         toUser:receiverUser
                        options: (BFSendingOptionEncrypted | BFSendingOptionFullTransmission)
                          error: &error];
```
```swift
//Swift
    let payload = ["text" : "Text message."]
    let user = "6655a16c-8209-46c4-9c51-21d8df3efb95"
    let options: BFSendingOption = [.Encrypted, .FullTransmission]
    try transmitter.sendDictionary(payload,
                                    withData: nil,
                                    toUser: user,
                                    options: options)
```

Sending a dictionary without encryption to another user using only mesh:

```objective-c
//Objective-C
    NSDictionary *payload = @{@"text" : @"Text message."};
    NSString *receiverUser = @"6655a16c-8209-46c4-9c51-21d8df3efb95";
    [transmitter sendDictionary:payload
                       withData:nil
                         toUser:receiverUser
                        options: (BFSendingOptionNoEncrypted | BFSendingOptionMeshTransmission)
                          error: &error];
```
```swift
//Swift
    let payload = ["text" : "Text message."]
    let user = "6655a16c-8209-46c4-9c51-21d8df3efb95"
    let options: BFSendingOption = [.NoEncrypted, .MeshTransmission]
    try transmitter.sendDictionary(payload,
                                    withData: nil,
                                    toUser: user,
                                    options: options)
```

Sending a dictionary with broadcast option (to all nearby users):

```objective-c
//Objective-C
    NSDictionary *payload = @{@"text" : @"Text message."};
    [transmitter sendDictionary:payload
                       withData:nil
                         toUser:nil
                        options: (BFSendingOptionBroadcastReceiver)
                          error: &error];
```
```swift
//Swift
    let payload = ["text" : "Text message."]
    let options: BFSendingOption = [.BroadcastReceiver]
    try transmitter.sendDictionary(payload,
                                    withData: nil,
                                    toUser: nil,
                                    options: options)
```

There are some configurations for sending packets that won't work, like trying to send a broadcast packet (`BFSendingOptionBroadcastReceiver`) encrypted (`BFSendingOptionEncrypted`) or trying to send a broadcast packet  (`BFSendingOptionBroadcastReceiver`) with binary content.

---

## Session

A session is necessary in order for the BFTransmitter instance to work. The session is persistent in the device (even after the user deletes the app) and contains a key pair necessary for encryption and a unique identifier assigned to the device. These credentials are the same for all the BFtransmitter instances and won't expire by themselves. If the client needs to create a new session for another user or simply needs to close the session, it must be destroyed explicitly.

This code shows how to validate if there is an existing session:

```objective-c
//Objective-C
    if ([transmitter hasSession])
    {
        // The session exists
    }
```
```swift
//Swift
    if (transmitter.hasSession)
    {
        // The session exists
    }
```

And this code shows how to destroy a session:

```objective-c
//Objective-C
    [transmitter destroySession];
```
```swift
//Swift
    transmitter.destroySession()
```

---

## Background mode

The framework is able to preserve active connections when the app is sent to background. To enable this characteristic, you will need to set the property `backgroundModeEnabled` of the `BFTransmitter` to YES (the default value is NO).

```objective-c
//Objective-C
    transmitter.backgroundModeEnabled = YES;
```
```swift
//Swift
    transmitter.backgroundModeEnabled = true
```

In order to enable background mode, you will need to add the`UIBackgroundModes`key to your `Info.plist` file and set the keys value to an array containing one of the strings `bluetooth-peripheral` and `bluetooth-central`. If these keys aren't added, the framework will launch an error.

---

## Log levels

The framework has four log levels that can be found in the following enumeration:

```objective-c
//Objective-C
    typedef NS_ENUM(NSUInteger, BFLogLevel) {
        BFLogLevelError = 0,
        BFLogLevelInfo,
        BFLogLevelDebug,
        BFLogLevelTrace
    };
```
```swift
//Swift
    public enum BFLogLevel : UInt {
        case Error
        case Info
        case Debug
        case Trace
    }
```

**error**: Prints just errors.

**info**: Prints errors and information related to the framework processes.

**debug**: Prints error, framework processes information, and debug messages.

**trace**: Acts like the previous level, but also prints a full trace information for the mesh packets and some other specific events.

The default log level is `Error` and it can be changed using the following code (`Trace` will be used as an example):

```objective-c
//Objective-C
    [BFTransmitter setLogLevel:BFLogLevelTrace]
```
```swift
//Swift
    BFTransmitter.setLogLevel(BFLogLevel.Trace)
```
---

## Export and import keys

Encrypted content can only be sent when a secure connection with the receiver has been established at least once. This is because the public keys are needed to be exchanged during the handshake. There is a manual way to do it, by exporting and importing the keys manually, so a third party (like a web server) can distribute the keys to the required users.

Export the public key of the current device:

```objective-c
//Objective-C
+(NSString *)localPublicKey;
```
```swift
//Swift
public class func localPublicKey() -> String!
```
***returns***: The key for the local user encoded in base64.

Import a public key

```objective-c
//Objective-C
- (void)savePublicKey:(NSString *)key forUser:(NSString *)user;
```
```swift
//Swift
public func savePublicKey(key: String!, forUser user: String!)
```
**key**: The public key of the other user encoded in base64 as it was exported.

**user**: Identifier of the other user.

Once the key has been imported, the user can send encrypted content to a receiver even if it's not in range.

The following method shows if a key for a user with a certain identifier already exists:

```objective-c
//Objective-C
- (BOOL)existsKeyForUser:(NSString *)user;
```
```swift
//Swift
public class func existsKeyForUser(user: String!) -> Bool
```
**user**: Identifier of the user.

---

## Other information

### iOS Simulator

The framework isn't currently supported on the iOS Simulator. The framework includes desktop architectures, so the examples or the framework integrated in your project will compile, but the BFTransmitter instance would not be started.

### Save state

If the app is closed and the BFTransmitter instance isn't stopped before, `saveState:` method cleans and saves some control data (cache). The use isn't mandatory, but it's recommended to stop the transmitter or call this method before the app is closed.

### Dictionaries

In order to send a dictionary (see example of the step `4. Send data`, variable `payload`), its components must be JSON encodable. It can also include binary buffers (NSData objects) as values for a key. The main reason of this is that the receiver could be an Android device that could not decode objects like UIImage, UIFont, etc.

Some examples of valid and invalid dictionaries:  

```objective-c
//Objective-C
// Valid dictionary
NSDictionary * payload = @{ @"text": @"Message text",
                            @"sequence": @(3546),
                            @"duration": @(656.2973),
                            @"success":  @(YES)
                          };
// Valid dictionary
NSData * binaryFile = ... // Loads binary content
NSDictionary * payload = @{ @"text": @"Message text",
                            @"file": binaryFile
                          };

// Invalid dictionary (will provoke an error)
UIImage * image = ...// loads an image
NSDictionary * payload = @{ @"text": @"Message text",
                            @"image": image
                          };

```
```swift
//Swift
//Objective-C
// Valid dictionary
let payload = [ "text": "Message text",
                "sequence": 3546,
                "duration": 656.2973,
                "success":  true
              ]
// Valid dictionary
let binaryFile: Data = ... // Loads binary content
let payload = [ "text": "Message text",
                "file": binaryFile
              ]

// Invalid dictionary (will provoke an error)
let image: UIImage = ...// loads an image
let payload = [ "text": "Message text",
                "image": image
              ]

```

### Binary data (files)

We strongly recommend that if you want to send a file (image, music file, or other) don't add it as a value in the dictionary. You can do it, but the framework can send this kind of information separately, to give them a better management. An example that sends a binary file is shown below:

```objective-c
//Objective-C
    NSData * binaryFile = ...// Loads a file
    NSDictionary *dictionary = @{@"text" : @"Data concerning to the file."};
    NSString *receiverUser = @"6655a16c-8209-46c4-9c51-21d8df3efb95";
    [transmitter sendDictionary:dictionary
                       withData:binaryFile
                         toUser:receiverUser
                        options: (BFSendingOptionNoEncrypted | BFSendingOptionMeshTransmission)
                          error: &error];
```
```swift
//Swift
    let binaryFile: Data = ... // Loads a file
    let dictionary = ["text" : "Text message."]
    let user = "6655a16c-8209-46c4-9c51-21d8df3efb95"
    let options: BFSendingOption = [.NoEncrypted, .MeshTransmission]
    try transmitter.sendDictionary(dictionary,
                                    withData: binaryFile,
                                    toUser: user,
                                    options: options)
```

As you can see, you can still send a dictionary and a binary file together in the same packet, or you can also send just the binary part by passing nil instead of the dictionary.

### Mesh

It's important to know that binary files sent using the method explained above can't travel through the mesh network (can't be sent using the option `BFSendingOptionMeshTransmission` nor `BFSendingOptionFullTransmission`, just `BFSendingOptionDirectTransmission`), the reason of this is that binary files regularly are too large and could slow down the performance of the mesh network, so files like pictures with very high resolution, mp3 files and others can't be added. Any way, if you really need to send a binary file using the mesh network you can add it as a value in the dictionary, just consider that any large payload will be rejected, the maximum size is 2048 bytes.

### Broadcast messages

Broadcast messages are restricted to be sent using the mesh network. As a consequence, you can't send a binary file using broadcast mode. You could add it to a dictionary as mentioned before, but it could be rejected if it's too large.

### Connections with Android devices

The iOS framework uses Wi-Fi Peer-to-Peer and Bluetooth Low Energy (BLE) technologies. Wi-Fi peer-to-peer is fast: it can give you up to 2 mbps in the best cases. Unfortunately, it's only available on iOS devices, so any connection with an Android device will be established using BLE. This kind of connection has very low throughput (27 kbps in the best case, considering the restrictions of the OS). It implies that if you want to send a large file (let's say, 1 MB), it will take a really long time. In fact, Bridgefy framework restricts the size of a binary file to 120 KB in BLE (using direct transmission or `BFSendingOptionDirectTransmission`). Although the size of a dictionary isn't restricted, we don't recommend trying to send a large amount of data.

### Maximum package sizes and throughput

These are the allowed sizes for different kind of packages, packages that exceed these limits will be discarded:  

**Dictionary through BLE:** Not restricted, but 120 KB as maximum is recommended.  
**Dictionary through WiFi:** Not restricted.  
**Binary data through BLE:** 120 KB  
**Binary data through WiFi:** Not restricted.  
**Mesh dictionary through BLE:** 1 KB  
**Mesh dictionary through Wifi:** 2 KB  
**Mesh binary data through BLE:** N/A  
**Mesh binary data through BLE:** N/A  
  
The throughput was mentioned in a previous section, but it's listed below for the two types of connection:  
  
**WiFi:** 2 mbps best case. Only available to use between iOS devices.  
**BLE:** 27 kbps best case.  

[ADD_KEY]: https://confluence.atlassian.com/bitbucket/set-up-ssh-for-git-728138079.html
[BRIDGEFY_WEB]: https://bridgefy.me/download-bridgefy.php
[BRIDGEFY_DIST]: https://bitbucket.org/bridgefy/bridgefy-ios-dist/
[BRIDGING_HEADER]: https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html
