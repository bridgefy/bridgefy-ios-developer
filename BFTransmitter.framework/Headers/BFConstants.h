//
//  BFGlobalConstants.h
//  Bridgefy
//
//  Created by Danno on 2/4/15.
//  Copyright (c) 2015 Bridgefy Inc. All rights reserved.
//
// This file contain the global constants or configurations used by Bridgefy mobile


#ifndef Bridgefy_BFTransmitterConstants_h
#define Bridgefy_BFTransmitterConstants_h

#endif

/**
 *  Set of options for sending messages, can be combined using the operator |
 */
typedef NS_OPTIONS(NSUInteger, BFSendingOption) {
    /**
     *  Send the packet only when the receiver is in range.
     */
    BFSendingOptionDirectTransmission = 0b0001,
    /**
     *  Send the packet using mesh, it doesn't need the receiver be in range. The size of the packets
     *  to send by mesh is limited to 2048 bytes, if a packet is rejected by this reason the method
     *  `transmitter:meshDidRejectPacketBySize:` of the delegate will be invoked. You can use the method
     *  `transmissionSizeFor:encryption:` to know the size of the packet before sending, but it's not
     *  recommendable because it requires a considerable amount of extra processing.
     *
     */
    BFSendingOptionMeshTransmission = 0b0010,
    /**
     *  Try to send the packet if the peer is in range, otherwise ingrese the packet to the mesh process.
     */
    BFSendingOptionFullTransmission = 0b0011,
    /**
     *  Send the packet encrypted, it can provoke an error if a secure connection has not been established at least once.
     */
    BFSendingOptionEncrypted = 0b0100,
    /**
     *  Send the packet without encryption.
     */
    BFSendingOptionNotEncrypted = 0b0000,
    /**
     *  Send a message using mesh without a defined receiver, the message is broadcasted to all nearby users, being in
     *  range or not. If this option is used and encryption option is added it will cause an error.
     */
    BFSendingOptionBroadcastReceiver = 0b1000,
};

/**
 *  Set of options that represents the network status.
 */
typedef NS_OPTIONS(NSInteger, BFNetworkConnectionStatus) {
    /**
     *  Can't perform network operations.
     */
    BFNetworkConnectionStatusUnreachable            = 0x0,
    /**
     *  Access to internet is available.
     */
    BFNetworkConnectionStatusInternet               = 0x01,
    /**
     *  There is access just to the local network.
     */
    BFNetworkConnectionStatusAccessPoint             = 0x02,
    /**
     *  There is access to Wi-Fi operations.
     */
    BFNetworkConnectionStatusWifi                   = 0x04,
    /**
     *  Access to bluetooth.
     */
    BFNetworkConnectionStatusBluetooth              = 0x08
};

/**
 *  Profiles that can be used to start the BFTransmitter instance,
 *  these profiles affect in different form how the data is transmitted,
 *  by now just one profile is available.
 */
typedef NS_ENUM(NSUInteger, BFTransmitterProfile) {
    /**
     *  Default profile.
     */
    BFTransmitterProfileDefault = 0
};

/**
 *  Set of the available logs levels to use in Bridfgefy framework.
 */
typedef NS_ENUM(NSUInteger, BFLogLevel) {
    /**
     *  Prints just errors.
     */
    BFLogLevelError = 0,
    /**
     *  Prints errors and information related to the framework processes.
     */
    BFLogLevelInfo,
    /**
     *  Prints errors, info and events .
     */
    BFLogLevelDebug,
    /**
     *  Acts like the previous level, but also prints a full trace information for the mesh packets and some other specific events.
     */
    BFLogLevelTrace
};

/**
 *  Set of the available events that can occur in Bridfgefy framework.
 */
typedef NS_ENUM(NSUInteger, BFEvent) {
    /**
     *  Waiting for online validation to start the transmitter.
     */
    BFEventStartWaiting = 0,
    /**
     *  The transmitter was started.
     */
    BFEventStartFinished,
    /**
     *  The transmitter needs internet to validate license.
     */
    BFEventInternetNeeded,
    /**
     *  The transmitter was already started.
     */
    BFEventAlreadyStarted,
    /**
     * Something was detected in backend validation, but if the license is valid, this doesn't stop the transmitter.
     */
    BFEventOnlineWarning,
    /**
     * An error was detected in backend validation and service must be stopped.
     */
    BFEventOnlineError,
    /**
     * Indicates if a near peer was detected, this event is only invoked if the app is in background mode and this mode is enabled in the BFTransmitter instance.
     */
    BFEventNearbyPeerDetected,
    /**
     * Indicates that the bluetooth interface was disabled or the app doesn't have permissions.
     */
    BFEventBluetoothDisabled,
    /**
     * Indicates that the Wi-fi interface was disabled or the app doesn't have permissions.
     */
    BFEventWifiDisabled,
    /**
     * Indicates that the binary part of a packet has been discarded
     */
    BFEventBinaryDiscarded,
    /**
     * Peer not found
     */
    BFEventPeerNotFound,
    /**
     * Invalid preloaded license
     */
    BFEventInvalidPreloadedLicense
};

/**
 *  Set of the error codes managed by the transmitter.
 */
typedef NS_ENUM(NSInteger, BFError) {
    /**
     * Indicates neither data or dictionary were provided to send
     */
    BFErrorNoDataToSend = 50000,
    /**
     * Indicates a message can't be encrypted and broadcasted at the same time
     */
    BFErrorInvalidArguments = 50001,
    /**
     * Indicates a message with just binary data can't be sent with mesh options
     */
    BFErrorNoBinaryInMesh = 50003,
    /**
     * Indicates a direct message can't be sent
     */
    BFErrorDirectMessage = 50004,
    /**
     * Indicates BFTransmitter is not supported in iOS Simulator, so it won't be started
     */
    BFErrorNoSimulator = 50005,
    /**
     * Indicates no session is available in BFTransmitter
     */
    BFErrorSession = 50006,
    /**
     * Indicates the licence for the current app has been expired
     */
    BFErrorLicenseExpired = 50007,
    /**
     * Indicates a message can't be encrypted because there isn't a key for this user or a secure connection has never been established before
     */
    BFErrorNoSecureConnection = 50008,
    /**
     * Indicates provided AppKey is not valid
     */
    BFErrorInvalidAppKey = 50009,
    /**
     * Indicates there is no internet connection available
     */
    BFErrorNoInternetAvailable = 50010,
    /**
     * Indicates application do not match with registered AppKey
     */
    BFErrorAppDoesNotExist = 50011,
    /**
     * Indicates applications bundleID do not match with registered AppKey
     */
    BFErrorBundleIdDoesNotExist = 50012,
    /**
     * Indicates license has expired by date
     */
    BFErrorLicenseExpiredByDate = 50013,
    /**
     * Indicates that the license expired because it exceeded the maximum number of messages
     */
    BFErrorLicenseExpiredByMessages = 50014,
    /**
     * Indicates that the license expired because it exceeded the maximum number of users
     */
    BFErrorLicenseExpiredByUsers = 50015,
    /**
     * Indicates that the license has not been paid
     */
    BFErrorLicenseExpiredByPayment = 50016,
    /**
     * Indicates that the license has been blocked for misuse
     */
    BFErrorLicenseBlocked = 50017,
    /**
     * Indicates a violation in service use
     */
    BFErrorServiceViolation = 50018,
    /**
     * Indicates a warning in service use
     */
    BFErrorServiceWarning = 50019
};

