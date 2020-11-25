//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

import UIKit

let broadcastConversation: String = "broadcast"

public protocol ChatViewControllerDelegate: NSObjectProtocol {
    func sendMessage(_ message: Message, toConversation uuid: String)
}

open class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak open var chatDelegate: ChatViewControllerDelegate?
    var userUUID: String = ""
    var deviceName: String = ""
    var deviceType: DeviceType = .undefined
    var online: Bool = false
    var broadcastType: Bool = false
    var messages: NSMutableArray = []
    
    //UI objects
    @IBOutlet weak var onlineLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    
    
    func addMessage(_ message: Message) {
        self.messages.insert(message, at: 0)
        self.addRowToTable()
    }
    
    func updateOnlineTo(_ onlineStatus: Bool) {
        self.online = onlineStatus
        self.setOnlineStatus()
    }
    
    @IBAction func sendText(_ sender: AnyObject) {
        if self.textField.text!.isEmpty {
            return
        }
        let message: Message = Message()
        message.text = self.textField!.text!
        message.date = Date()
        message.received = false
        message.broadcast = self.broadcastType
        if self.broadcastType {
            self.chatDelegate?.sendMessage(message, toConversation: broadcastConversation)
        } else {
            //If conversation is not broadcast send a direct message to the UUID
            self.chatDelegate?.sendMessage(message, toConversation: self.userUUID)
        }
        self.textField.text = ""
        self.messages.insert(message, at: 0)
        self.addRowToTable()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.setOnlineStatus()
        if self.broadcastType {
            self.navigationItem.title = "Broadcast"
        } else {
            self.navigationItem.title = self.deviceName
        }
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardHidden(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setOnlineStatus() {
        if self.broadcastType {
            self.onlineLabel.textColor = UIColor.red
            self.onlineLabel.text = "Messages for all peers"
            return
        }
        if self.online {
            self.onlineLabel.textColor = UIColor.red
            self.onlineLabel.text = "ONLINE PEER"
        } else {
            self.onlineLabel.textColor = UIColor.gray
            self.onlineLabel.text = "OFFLINE PEER"
        }
    }
    
    func addRowToTable() {
        self.tableView.beginUpdates()
        let index = IndexPath(row:0, section: 0)
        self.tableView.insertRows(at: [index], with: UITableView.RowAnimation.bottom)
        self.tableView.endUpdates()
    }
    
    // MARK: Table Data Source
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        let userLabel = cell.contentView.viewWithTag(1000) as! UILabel
        let messageLabel = cell.contentView.viewWithTag(1001) as! UILabel
        let dateLabel = cell.contentView.viewWithTag(1002) as! UILabel
        let transmissionLabel = cell.contentView.viewWithTag(1003) as! UILabel
        let deviceTypeImageView = cell.contentView.viewWithTag(1004) as! UIImageView
        let message: Message = self.messages.object(at: indexPath.item) as! Message
        if message.received {
            userLabel.textColor = UIColor.red
            userLabel.text = message.sender
            transmissionLabel.textColor = message.mesh ? UIColor.blue : UIColor.red
            transmissionLabel.text = message.mesh ? "MESH" : "DIRECT"
            
            switch message.deviceType {
            case .undefined:
                deviceTypeImageView.image = nil;
            case .android:
                deviceTypeImageView.image = UIImage.init(named: "android")
            case .ios:
                deviceTypeImageView.image = UIImage.init(named: "ios")
            }
        } else {
            userLabel.textColor = UIColor.blue
            userLabel.text = "You:"
            transmissionLabel.text = ""
            deviceTypeImageView.image = nil;
        }
        messageLabel.text = message.text
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateLabel.text = dateFormatter.string(from: message.date as Date)
        return cell
    }
    
    // MARK: Table Delegate
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.textField.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: Keyboard management
    
    @objc func keyboardShown(_ notification: Notification) {
        let keyboardInfo = notification.userInfo!
        let keyboardFrameBegin = keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey]
        let frame: CGRect = (keyboardFrameBegin! as AnyObject).cgRectValue
        var padding: CGFloat = 0.0;
        if #available(iOS 11, *) {
            padding = self.view.safeAreaInsets.bottom;
        }
        self.keyboardConstraint.constant = frame.size.height - padding
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
    
    @objc func keyboardHidden(_ notification: Notification) {
        self.keyboardConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
}
