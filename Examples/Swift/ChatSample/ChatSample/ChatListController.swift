//
//  ChatListController.swift
//  ChatSample
//
//  Created by Daniel Heredia on 7/22/16.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit
import BFTransmitter

let onlineSection = 0
var peersFile = "peersfile"
var messageTextKey = "text"
var peerNameKey = "device_name"
var peerTypeKey = "device_type"

open class ChatListController: UITableViewController, BFTransmitterDelegate, ChatViewControllerDelegate {
    
    fileprivate var openUUID: String = ""
    fileprivate var openStateOnline: Bool = false
    fileprivate var transmitter: BFTransmitter
    fileprivate var peerNamesDictionary: NSMutableDictionary
    fileprivate var onlinePeers: NSMutableArray
    fileprivate var offlinePeers: NSMutableArray
    fileprivate weak var chatController: ChatViewController? = nil
    
    public required init?(coder aDecoder: NSCoder) {
        
        //Transmitter initialization
        self.transmitter = BFTransmitter(apiKey: "YOUR API KEY")
        self.peerNamesDictionary = NSMutableDictionary()
        self.onlinePeers = NSMutableArray()
        self.offlinePeers = NSMutableArray()
        super.init(coder: aDecoder)
        self.transmitter.delegate = self
        self.transmitter.isBackgroundModeEnabled = true
        //Load demo related data and register for background enter
        self.loadPeers()
        
    }
    

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatListController.savePeers),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)

        self.transmitter.start()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Table view data source
    
    override open func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == onlineSection {
            return self.onlinePeers.count
        } else {
            return self.offlinePeers.count
        }
    }
    
    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        if section == onlineSection {
            return "Online peers"
        } else {
            return "Offline peers"
        }
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         // Just cell appereance configuration
        let cell = tableView.dequeueReusableCell(withIdentifier: "peerCell", for: indexPath)
        let peerIdLabel = cell.contentView.viewWithTag(1000) as! UILabel
        let onlineStatusLabel = cell.contentView.viewWithTag(1001) as! UILabel
        let deviceTypeImageView = cell.contentView.viewWithTag(1002) as! UIImageView
        var identifier: String
        if indexPath.section == onlineSection {
            onlineStatusLabel.textColor = UIColor.red
            onlineStatusLabel.text = "ONLINE"
            identifier = self.onlinePeers.object(at: indexPath.item) as! String
        } else {
            onlineStatusLabel.textColor = UIColor.gray
            onlineStatusLabel.text = "OFFLINE"
            identifier = self.offlinePeers.object(at: indexPath.item) as! String
        }
        
        let peerInfo = self.peerNamesDictionary[identifier] as! Dictionary<String, Any>
        
        if peerInfo["name"] != nil {
            let userDeviceName = peerInfo["name"] as! String
            peerIdLabel.text = userDeviceName
        }
        
        let devType: DeviceType = DeviceType(rawValue: peerInfo["type"] as! Int)!
        switch devType {
        case .undefined:
            deviceTypeImageView.image = nil
        case .android:
            deviceTypeImageView.image = UIImage.init(named: "android")
        case .ios:
            deviceTypeImageView.image = UIImage.init(named: "ios")
        }
        
        return cell
    }
    
    // MARK: Table view delegate
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Prepares to open a conversation with a concrete user.
        if indexPath.section == onlineSection {
            openUUID = self.onlinePeers.object(at: indexPath.item) as! String
            openStateOnline = true
        } else {
            openUUID = self.offlinePeers.object(at: indexPath.item) as! String
            openStateOnline = false
        }
        self.performSegue(withIdentifier: "openContactChat", sender: self)
    }
    
    // MARK: ChatViewControllerDelegate
    
    open func sendMessage(_ message: Message, toConversation uuid: String) {
        var dictionary: Dictionary<String, Any>
        var receiverUUID: String?
        var options: BFSendingOption
        if message.broadcast {
            //A broadcast message don't have a concrete receiver
            //this is sent to all peers. For this reason
            //receiverUUID is nil.
            receiverUUID = nil
            // The encryption option is not included because a broadcast message can't
            // be encrypted.
            options = [.fullTransmission, .broadcastReceiver]
            
            // Creation of the dictionary for the message to be sent
            // We included the device name because is possible that
            // the final receiver doesn't have it.
            dictionary = [
                messageTextKey: message.text,
                peerNameKey: UIDevice.current.name,
                peerTypeKey: DeviceType.ios.rawValue
            ]
            
        } else {
            // The message isn't not broadcast, instead is a direct message.
            // A direct message can be encrypted.
            receiverUUID = uuid
            options = [.fullTransmission, .encrypted]
            // Creation of the dictionary for the message to be sent
            dictionary = [messageTextKey: message.text]
        }
        
        do {
            try self.transmitter.send(dictionary, toUser: receiverUUID, options: options)
        }
        catch let err as NSError {
            print("Error: \(err)")
        }
        
        //Just persistence management
        self.saveMessage(message, forConversation: uuid)
    }
    
    // MARK: Segue Methods
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        let chatController = segue.destination as! ChatViewController
        if segue.identifier == "openContactChat" {
            // Conversation with a concrete user.
            chatController.online = openStateOnline
            chatController.userUUID = openUUID
            let peerInfo: Dictionary<String, Any> = self.peerNamesDictionary[openUUID] as! Dictionary
            chatController.deviceName = peerInfo["name"] as! String
            chatController.deviceType = DeviceType(rawValue: peerInfo["type"] as! Int)!
            chatController.messages = self.loadMessagesForConversation(openUUID)
            chatController.broadcastType = false
        } else {
            // Broadcast conversation
            // (the messages will be sent to all available users)
            chatController.online = openStateOnline
            chatController.userUUID = "broadcast";
            chatController.messages = self.loadMessagesForConversation(broadcastConversation)
            chatController.broadcastType = true
        }
        chatController.chatDelegate = self
        self.chatController = chatController
    }
    
    // MARK: BFTransmitterDelegate

    public func transmitter(_ transmitter: BFTransmitter, meshDidAddPacket packetID: String) {
        //Packet added to mesh
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didReachDestinationForPacket packetID: String) {
        //Mesh packet reached destiny (no always invoked)
    }
    
    public func transmitter(_ transmitter: BFTransmitter, meshDidStartProcessForPacket packetID: String) {
        //A message entered in the mesh process.
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didSendDirectPacket packetID: String) {
        //A direct message was sent
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didFailForPacket packetID: String, error: Error?) {
        //A direct message transmission failed.
    }
    
    public func transmitter(_ transmitter: BFTransmitter, meshDidDiscardPackets packetIDs: [String]) {
        //A mesh message was discared and won't still be transmitted.
    }
    
    public func transmitter(_ transmitter: BFTransmitter, meshDidRejectPacketBySize packetID: String) {
        print("The packet \(packetID) was rejected from mesh because it exceeded the limit size.");
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didReceive dictionary: [String : Any]?, with data: Data?, fromUser user: String, packetID: String, broadcast: Bool, mesh: Bool) {
        
        
        // A dictionary was received by BFTransmitter.
        if (dictionary?[messageTextKey] != nil) {
            // If it contains a value for the key messageTextKey it's a message
            processReceivedMessage(dictionary! ,
                                   fromUser: user, byMesh: mesh, asBroadcast: broadcast)
        } else {
            //If it doesn't contain the key messageTextKey it's the device name of the other user.
            processReceivedPeerInfo(dictionary!, fromUser: user)
        }
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didDetectConnectionWithUser user: String) {
        //A connection was detected (no necessarily secure)
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didDetectDisconnectionWithUser user: String) {
        self.discardUUID(user)
        self.offlinePeers.add(user)
        self.tableView.reloadData()
        if self.chatController != nil &&
            self.chatController!.userUUID == user {
            //If currently a the related conversation is shown,
            //update the state.
            self.chatController!.updateOnlineTo(false)
        }
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didFailAtStartWithError error: Error)
    {
        print("An error occurred at start: \(error.localizedDescription)");
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didOccur event: BFEvent, description: String)
    {
        print("Event reported: \(description)");
    }
    
    public func transmitter(_ transmitter: BFTransmitter, shouldConnectSecurelyWithUser user: String) -> Bool {
        return true //if true establish connection with encryption capacities.
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didDetectSecureConnectionWithUser user: String) {
        // A secure connection was detected,
        // A secure connection has encryption capabilities.
        
        // Check if there's a name saved for this user.
        processName(forUser: user)
        
        //Update the table accord this new connection
        if self.peerNamesDictionary[user] == nil {
            self.peerNamesDictionary.setValue("", forKey: user)
        }
        
        self.discardUUID(user)
        self.onlinePeers.add(user)
        self.tableView.reloadData()
        if self.chatController != nil &&
            self.chatController!.userUUID == user {
            //If currently a the related conversation is shown,
            //update the state.
            self.chatController!.updateOnlineTo(true)
        }
    }
    
    // MARK: Name and message utils
    
    func processName(forUser user: String) {
    
        // If there's not a name a temporary name is assigned
        // meanwhile the real name is received.
        
        if self.peerNamesDictionary[user] == nil {
            let tmpName = "Id: \((user as NSString).substring(to: 5))"
            let peerInfo = ["name": tmpName as Any,
                            "type": DeviceType.undefined.rawValue]
            self.peerNamesDictionary[user] = peerInfo
        }
        
        // In case the other user don't have our devicename,
        // this is sent as an initial message.
        sendDeviceNameToUser(user)
    
    }
    
    func sendDeviceNameToUser(_ user: String) {
        let dictionary = [peerNameKey: UIDevice.current.name as Any,
                          peerTypeKey: DeviceType.ios.rawValue]
        let options: BFSendingOption = [.directTransmission, .encrypted]
        
        do {
            try self.transmitter.send(dictionary, toUser: user, options: options)
        }
        catch let err as NSError {
            print("Error: \(err)")
        }
        
    }
    
    func processReceivedMessage(_ dictionary: Dictionary<String, Any>, fromUser user: String, byMesh mesh: Bool, asBroadcast broadcast: Bool) {
        
        // Processing a new message
        let text: String = dictionary[messageTextKey] as! String
        let message = Message()
        message.text = text
        message.received = true
        message.date = Date()
        message.mesh = mesh
        message.broadcast = broadcast// If YES received message is broadcast.
        
        let conversation: String
        if message.broadcast {
            conversation = broadcastConversation
            let deviceType = DeviceType(rawValue: dictionary[peerTypeKey] as! Int)!
            message.deviceType = deviceType
            // The deviceName will be processed because it's possible we don't have it yet.
            processReceivedPeerInfo(dictionary, fromUser: user)
        } else {
            conversation = user
        }
        let peerInfo = self.peerNamesDictionary[user] as! Dictionary<String, Any>
        message.sender = peerInfo["name"] as! String
        self.saveMessage(message, forConversation: conversation)
        
        // YES if the related conversation for the user is shown
        let showingSameUser = !message.broadcast &&
                              self.chatController != nil &&
                              self.chatController?.userUUID == user
        // YES if received message is for broadcast and broadcast is shown
        let showingBroadcast = message.broadcast &&
                               self.chatController != nil &&
                               self.chatController!.broadcastType
        if showingBroadcast || showingSameUser {
            // If the related conversation to the message is being shown.
            // update messages.
            self.chatController!.addMessage(message)
        }
        
    }
    
    func processReceivedPeerInfo(_ peerInfo: Dictionary<String, Any>, fromUser user: String) {

        let existingDeviceName = (self.peerNamesDictionary[user] as! Dictionary<String, Any>)["name"] as! String
        let receivedDeviceName = peerInfo[peerNameKey] as! String
        let receivedDeviceType = peerInfo[peerTypeKey] as! Int
        
        if receivedDeviceName != existingDeviceName {
            let name = "\(receivedDeviceName) (\((user as NSString).substring(to: 5)))"
            let userInfo: Dictionary<String, Any> = ["name": name,
                            "type": receivedDeviceType]
            self.peerNamesDictionary.setValue(userInfo, forKey: user)
            self.tableView.reloadData()
        }
    }

    
    // MARK: Clumsy data management
    
    // The methods in this section are not relevant to show
    // the BFTransmitter functionality.
    
    func discardUUID(_ uuid: String) {
        if self.onlinePeers.index(of: uuid) != NSNotFound {
            self.onlinePeers.remove(uuid)
        }
        if self.offlinePeers.index(of: uuid) != NSNotFound {
            self.offlinePeers.remove(uuid)
        }
    }
    
    func saveMessage(_ message: Message, forConversation conversation: String) {
        let filePath = self.fullPathForFile(conversation)
        let messages: NSMutableArray = self.loadMessagesForConversation(conversation)
        messages.insert(message, at: 0)
        let data = NSKeyedArchiver.archivedData(withRootObject: messages)
        try? data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
    }
    
    func loadMessagesForConversation(_ conversation: String) -> NSMutableArray {
        let filePath = self.fullPathForFile(conversation)
        let data: Data? = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        let messages: NSMutableArray
        if data != nil {
            messages = NSKeyedUnarchiver.unarchiveObject(with: data!) as! NSMutableArray
        }
        else {
            messages = NSMutableArray()
        }
        return messages
    }
    
    @objc func savePeers() {
        let filePath = self.fullPathForFile(peersFile)
        let data = NSKeyedArchiver.archivedData(withRootObject: self.peerNamesDictionary)
        try? data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
    }
    
    func loadPeers() {
        let filePath = self.fullPathForFile(peersFile)
        let data: Data? = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        if (data != nil) {
            self.peerNamesDictionary = NSKeyedUnarchiver.unarchiveObject(with: data!) as! NSMutableDictionary
            self.offlinePeers = NSMutableArray(array: peerNamesDictionary.allKeys)
        } else {
            self.peerNamesDictionary = NSMutableDictionary()
            self.offlinePeers = NSMutableArray()
        }
    }
    
    func fullPathForFile(_ file: String) -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        return url.appendingPathComponent(file).path
    }
}
