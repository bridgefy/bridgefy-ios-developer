//
//  TransferManager.swift
//  TwitterForwarder
//
//  Created by Danno on 7/17/17.
//  Copyright © 2017 Daniel Heredia. All rights reserved.
//

import UIKit

class TransferManager: NSObject {
    
    let transmitter: BFTransmitter
    var twitterClient: TWTRAPIClient?
    weak var dataController: DataController?
    var isInternetForwardEnabled: Bool {
        didSet {
            self.postPendingTweetsToInternet()
        }
    }
    
    override init() {
        self.transmitter = BFTransmitter(apiKey: "YOUR_API_KEY")
        self.isInternetForwardEnabled = false
        super.init()
        self.transmitter.delegate = self
        self.transmitter.start()
        self.startTwitterSession()
        self.subscribeToNetworkChanges()
    }
    
    func sendTweet(_ tweet: Tweet) {
        self.postTweetToInternet(tweet: tweet, completion: { success in
            self.transmitTweetOffline(tweet)
        })
    }
    
    func transmitTweetOffline(_ tweet: Tweet) {
        let posted = tweet.status == .onInternet
        let time = UInt64(tweet.time)
        let packet = [ PacketKeys.id: tweet.messageId!,
                       PacketKeys.sender: tweet.userId!,
                       PacketKeys.content: tweet.text!,
                       PacketKeys.date: time,
                       PacketKeys.posted: posted ] as [String : Any]
        
        do {
            try self.transmitter.send(packet,
                                      toUser: nil,
                                      options: [.meshTransmission, .broadcastReceiver])
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Network changes

extension TransferManager {
    
    func subscribeToNetworkChanges() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NotificationNames.networkChange),
                                               object: nil,
                                               queue: nil) { (notification) in
                                                    self.processNetworkChange()
                                                }
    }
    
    func processNetworkChange() {
        if self.canDumpToInternet {
            self.postPendingTweetsToInternet()
        } else if self.twitterClient == nil {
            self.startTwitterSession()
        }
    }
    
    var canDumpToInternet: Bool {
        let netValue = self.transmitter.networkStatus.rawValue & BFNetworkConnectionStatus.internet.rawValue
        let hasInternet = netValue != 0
        let hasSession = self.twitterClient != nil
        return hasSession && hasInternet
    }
}

// MARK: - BFTransmitterDelegate

extension TransferManager: BFTransmitterDelegate {
    
    func transmitter(_ transmitter: BFTransmitter, meshDidAddPacket packetID: String) {
        // A packet was added to the mesh process
        
    }
    func transmitter(_ transmitter: BFTransmitter, didReachDestinationForPacket packetID: String) {
        // A mesh packet reached the destination (not necessarilly called)
    }
    func transmitter(_ transmitter: BFTransmitter, meshDidStartProcessForPacket packetID: String) {
        //A packet was added to mesh after it was tried to send with direct transmission.
    }
    func transmitter(_ transmitter: BFTransmitter, didSendDirectPacket packetID: String) {
        // A packet was sent using direct transmission
    }
    func transmitter(_ transmitter: BFTransmitter, didFailForPacket packetID: String, error: Error?) {
        // There was an error sending a packet
    }
    
    func transmitter(_ transmitter: BFTransmitter, meshDidDiscardPackets packetIDs: [String]) {
        // A packet in mesh was discarded ( won't reach destiny)
    }
    
    func transmitter(_ transmitter: BFTransmitter, meshDidRejectPacketBySize packetID: String) {
        // The packet was too large to be added to mesh
    }
    
    func transmitter(_ transmitter: BFTransmitter,
                     didReceive dictionary: [String : Any]?,
                     with data: Data?,
                     fromUser user: String,
                     packetID: String,
                     broadcast: Bool,
                     mesh: Bool) {
        
        self.dataController?.processReceivedTweet(withDictionary: dictionary!)
    }
 
    func transmitter(_ transmitter: BFTransmitter, didDetectConnectionWithUser user: String) {
        // A connection was detected
    }
    
    func transmitter(_ transmitter: BFTransmitter, didDetectDisconnectionWithUser user: String) {
        // A disconnection was detected
    }
    
    func transmitter(_ transmitter: BFTransmitter, didFailAtStartWithError error: Error) {
        print("ERROR: There was a problem starting the transmitter \(error.localizedDescription)")
    }
    
    func transmitter(_ transmitter: BFTransmitter, didOccur event: BFEvent, description: String) {
        print("An event occurred: \(description)")
    }
    
    func transmitter(_ transmitter: BFTransmitter, didDetectSecureConnectionWithUser user: String) {
        // A secure connection was detected
    }
    
    func transmitter(_ transmitter: BFTransmitter, shouldConnectSecurelyWithUser user: String) -> Bool {
        //We want to establish secure connection with all the users.
        return true
    }
    
    func transmitterNeedsInterfaceActivation(_ transmitter: BFTransmitter) {
        let alert = UIAlertController(title: "Alert",
                                      message: "TwitterForwarder needs bluetooth activation!",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        let window = UIApplication.shared.windows.last!
        window.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

// MARK: - TwitterKit

extension TransferManager {
    
    fileprivate func startTwitterSession() {
        Twitter.sharedInstance().start(withConsumerKey: TwitterCredentials.consumerKey,
                                       consumerSecret: TwitterCredentials.consumerSecret)
        Twitter.sharedInstance().sessionStore.saveSession(withAuthToken: TwitterCredentials.authToken,
                                                          authTokenSecret: TwitterCredentials.authTokenSecret ) { (session, error) in
                                                            if error != nil {
                                                                print("ERROR: There was an auth session error with twiter \(error!)")
                                                            } else {
                                                                self.startTwitterClient()
                                                            }
        }
    }
    
    private func startTwitterClient() {
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            self.twitterClient = TWTRAPIClient(userID: userID)
            self.postPendingTweetsToInternet()
        } else {
            print("ERROR: There is not twitter session, so client can't be started.")
        }
    }
    
    func postTweetToInternet(tweet: Tweet, completion: @escaping (_ success: Bool) -> Void ) {
        
        if !self.isInternetForwardEnabled  {
            print("Internet forward disabled, tweet won't be posted.")
            completion(false)
            return
        }
        
        guard let twitterClient = twitterClient else {
            print("ERROR: Twitter client not started, tweet won't be posted to internet")
            completion(false)
            return
        }
        
        let text = "#\(tweet.userId!) \(tweet.text!)"
        twitterClient.sendTweet(withText: text) { (onlineTweet, error) in
            let success = (error == nil)
            // Code 187 means that the tweet is duplicated, so it will never be posted.
            let shouldSave = success || (error! as NSError).code == 187
            if shouldSave {
                tweet.status = TweetStatus.onInternet
                self.dataController?.saveContext()
            }
            
            if !success {
                print("ERROR: Failed posting tweet. \(error!.localizedDescription)")
            }
            
            completion(success)
        }
    }
}

// MARK: - Pending tweets

extension TransferManager {
    func postPendingTweetsToInternet() {
        if !isInternetForwardEnabled || !self.canDumpToInternet{
            return
        }
        guard let dataController = self.dataController else {
            return
        }
        let pendingTweets = dataController.findPendingTweetsToPost()
        for tweet in pendingTweets {
            self.postTweetToInternet(tweet: tweet, completion: { success in
                if success {
                    self.transmitTweetOffline(tweet)
                }
            })
        }
    }
}
