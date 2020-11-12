//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

import UIKit

let notificationsFile = "notifications.txt"

open class ReceivedNotificationsViewController: UITableViewController {
    
    fileprivate var notifications: NSMutableArray

    public required init?(coder aDecoder: NSCoder) {
        //Load previous notifications
        self.notifications = ReceivedNotificationsViewController.loadNotifications()
        super.init(coder: aDecoder)
        
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Info update interface methods
    
    open func addNotificationDictionary(_ dictionary: [AnyHashable: Any], fromUUID uuid: String) {
            //Process the data sent by other peer.
            ReceivedNotificationsViewController.addNotificationToFile(dictionary, fromUUID: uuid)
            self.refreshData()
        }
        
    func refreshData() {
        self.notifications = ReceivedNotificationsViewController.loadNotifications()
        self.tableView.reloadData()
    }

    // MARK: Table view data source
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
        let notification: Notification = self.notifications.object(at: indexPath.item) as! Notification
        let fromUsernameLabel = cell.contentView.viewWithTag(1001) as! UILabel
        let fromUUIDLabel = cell.contentView.viewWithTag(1002) as! UILabel
        let alertNumberLabel = cell.contentView.viewWithTag(1003) as! UILabel
        let dateLabel = cell.contentView.viewWithTag(1004) as! UILabel
        let timeLabel = cell.contentView.viewWithTag(1005) as! UILabel
        
        fromUsernameLabel.text = notification.senderName
        fromUUIDLabel.text = "(\(notification.senderId)"
        
        alertNumberLabel.text = "\(notification.number)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd//MM//yyyy"
        dateLabel.text = dateFormatter.string(from: notification.date)
        
        dateFormatter.dateFormat = "HH:mm:ss"
        timeLabel.text = dateFormatter.string(from: notification.date)
        
        return cell
    }

    // MARK: Clumsy data management.
    
    // The methods in this section are not relevant to show
    // the BFTransmitter functionality.

    static func addNotificationToFile(_ dictionary: [AnyHashable: Any], fromUUID uuid: String) {
        let notification = Notification()
        notification.number = (dictionary["number"] as! NSNumber).intValue
        notification.senderId = String(uuid[..<uuid.index(uuid.startIndex, offsetBy: 5)])
        notification.senderName = dictionary["device_name"] as! String
        let doubleValue = (dictionary["date_sent"] as! NSNumber).doubleValue / 1000
        let date = Date(timeIntervalSince1970: doubleValue)
        notification.date = date
        let notifications: NSMutableArray = self.loadNotifications()
        notifications.insert(notification, at: 0)
        let filePath = fullPathForFile(notificationsFile)
        let data = NSKeyedArchiver.archivedData(withRootObject: notifications)
        try? data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
    }
    
    static func loadNotifications() -> NSMutableArray {
        let filePath = fullPathForFile(notificationsFile)
        
        guard
            let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
            let mutableArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSMutableArray
        else {
            return NSMutableArray()
        }
        
        return mutableArray
    }

    static func fullPathForFile(_ file: String) -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        return url.appendingPathComponent(file).path
    }
    
    static func clearReceivedNotifications() -> Bool {
        let filePath = fullPathForFile(notificationsFile)
        let data = NSKeyedArchiver.archivedData(withRootObject: [])
        do {
            try data.write(to: URL(fileURLWithPath: filePath))
            return true
        } catch {
            return false
        }
    }
}
