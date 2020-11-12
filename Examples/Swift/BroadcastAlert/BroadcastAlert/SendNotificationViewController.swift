//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

import UIKit
import BFTransmitter

let sent_key = "sent_n"
let received_key = "recev_n"


open class SendNotificationViewController: UIViewController, BFTransmitterDelegate {
    
    fileprivate var transmitter: BFTransmitter
    fileprivate weak var receivedNotifsController: ReceivedNotificationsViewController? = nil
    private var sentNumber: Int
    private var receivedNumber: Int
    private var shouldVibrate = false
    
    //UI objects
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var sentNotificationsLabel: UILabel!
    @IBOutlet weak var sentStatusLabel: UILabel!
    @IBOutlet weak var receivedNotificationsLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var controlsContainer: UIView!
    
    public required init?(coder aDecoder: NSCoder) {
        
        //Transmitter initialization
        self.transmitter = BFTransmitter(apiKey: "YOUR API KEY")
        sentNumber = 0
        receivedNumber = 0
        super.init(coder: aDecoder)
        self.transmitter.delegate = self
        sentNumber = self.getSentNotificationsNumber()
        receivedNumber = self.getReceivedNotificationsNumber()
        
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.transmitter.start()
        //UI controls load
        self.nameLabel.text = UserDefaults.standard.string(forKey: Constants.username)
        self.uuidLabel.text = self.truncatedUUID()
        self.refreshCounters()
        self.sentStatusLabel.text = ""
        self.sendButton.layer.cornerRadius = 14.0
        self.sendButton.layer.borderWidth = 2.0
        self.sendButton.layer.borderColor = UIColor.red.cgColor
        self.controlsContainer.layer.cornerRadius = 14.0
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil,
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        
        shouldVibrate = UserDefaults.standard.bool(forKey: Constants.vibrationEnabled)
        
        registerForNotifications()
    }
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(vibrationSettingChanged),
                                               name: .vibrationNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(usernameWasUpdated),
                                               name: .usernameNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resetSentAlertsCounter),
                                               name: .resetSentAlertNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deleteReceivedAlerts),
                                               name: .resetReceivedAlertsNotification,
                                               object: nil)
    }
    
    func refreshCounters() {
        self.sentNotificationsLabel.text = "\(sentNumber)"
        self.receivedNotificationsLabel.text = "\(receivedNumber)"
    }
    
    func truncatedUUID() -> String {
        let uuid: String = self.transmitter.currentUser!
        return String(uuid[..<uuid.index(uuid.startIndex, offsetBy: 5)])
    }
    
    // MARK: Segue Method
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "received" {
            self.receivedNotifsController = segue.destination as? ReceivedNotificationsViewController
        }
    }
    
    // MARK: - Notification handlers
    
    @objc
    func vibrationSettingChanged() {
        shouldVibrate = UserDefaults.standard.bool(forKey: Constants.vibrationEnabled)
    }
    
    @objc
    func usernameWasUpdated() {
        nameLabel.text = UserDefaults.standard.string(forKey: Constants.username)
    }
    
    @objc
    func resetSentAlertsCounter() {
        sentNumber = 0
        updateSentNotifications(sentNumber)
        refreshCounters()
    }
    
    @objc
    func deleteReceivedAlerts() {
        if ReceivedNotificationsViewController.clearReceivedNotifications() {
            receivedNumber = 0
            updateReceivedNotifications(receivedNumber)
            refreshCounters()
        }
    }
    
    // MARK: IB Actions
    
    @IBAction func sendNotification(_ sender: AnyObject) {
        //Sending the message.
        let dictionary: Dictionary<String, AnyObject> = ["number": (sentNumber + 1) as AnyObject,
                                                         "device_name": UserDefaults.standard.string(forKey: Constants.username) as AnyObject,
                                                         "date_sent": floor(Date().timeIntervalSince1970 * 1000) as AnyObject]
        let options: BFSendingOption = [.broadcastReceiver, .meshTransmission]
        
        do {
            try self.transmitter.send(dictionary, toUser: nil, options: options)
        }
        catch let err as NSError {
            print("Error: \(err)")
        }
    }
    
    // MARK: BFTransmitterDelegate
    
    public func transmitter(_ transmitter: BFTransmitter, meshDidAddPacket packetID: String) {
        // Packet added to mesh
        // Just called when the option BFSendingOptionMeshTransmission was used
        sentNumber += 1
        self.sentStatusLabel.text = "Broadcasting alert number \(sentNumber)"
        self.updateSentNotifications(sentNumber)
        self.refreshCounters()
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didReachDestinationForPacket packetID: String) {
        //Mesh packet reached destiny (no always invoked)
    }
    
    public func transmitter(_ transmitter: BFTransmitter, meshDidStartProcessForPacket packetID: String) {
        //A message entered in the mesh process (was added).
        // Just called when the option BFSendingOptionFullTransmission was used.
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
    
    public func transmitter(_ transmitter: BFTransmitter,
        didReceive dictionary: [String : Any]?,
                    with data: Data?, fromUser
                         user: String,
                     packetID: String,
                    broadcast: Bool,
                         mesh: Bool) {
        receivedNumber += 1
        self.updateReceivedNotifications(receivedNumber)
        self.refreshCounters()
        // A dictionary was received by BFTransmitter.
        if self.receivedNotifsController != nil {
            // If the the notifications screen is shown
            // update it.
            self.receivedNotifsController!.addNotificationDictionary(dictionary!, fromUUID: user)
        } else {
            //Otherwise, just update the data in file.
            ReceivedNotificationsViewController.addNotificationToFile(dictionary!, fromUUID: user)
        }
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didDetectConnectionWithUser user: String) {
        // A connection was detected (no necessarily secure)
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didDetectDisconnectionWithUser user: String) {
        // A disconnection was detected.
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didFailAtStartWithError error: Error)
    {
        print("An error occurred at start: \(error.localizedDescription)");
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didOccur event: BFEvent, description: String)
    {
        print("Event reported: \(description)");
        
        if event == .startFinished,
           !UserDefaults.standard.bool(forKey: Constants.infoShowed) {
            infoPressed(self)
            UserDefaults.standard.setValue(true, forKey: Constants.infoShowed)
        }
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didDetectSecureConnectionWithUser user: String) {
        // A secure connection was detected,
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didDetectNearbyUser packetID: String) {
        // A nearby user has been detected
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didFailConnectingToUser packetID: String, error: Error) {
        // An on-demand connection failed
    }
    
    public func transmitter(_ transmitter: BFTransmitter, userIsNotAvailable user: String) {
        // A user is no longer nearby
    }
    
    // MARK: Persistence of indicators
    
    func updateSentNotifications(_ numNotifications: Int) {
        UserDefaults.standard.set((numNotifications), forKey: sent_key)
        UserDefaults.standard.synchronize()
    }
    
    func getSentNotificationsNumber() -> Int {
        let value = UserDefaults.standard.value(forKey: sent_key)
        if value == nil {
            return 0
        }
        return (value! as AnyObject).intValue
    }
    
    func updateReceivedNotifications(_ numNotifications: Int) {
        UserDefaults.standard.set((numNotifications), forKey: received_key)
        UserDefaults.standard.synchronize()
    }
    
    func getReceivedNotificationsNumber() -> Int {
        let value = UserDefaults.standard.value(forKey: received_key)
        if value == nil {
            return 0
        }
        return (value! as AnyObject).intValue
    }
    
    // MARK: - Info method
    
    @IBAction func infoPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Broadcast Alert",
                                                message: "This app is designed to send and receive alerts without an internet connection",
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK",
                                     style: .default)
        
        alertController.addAction(okAction)
        
        present(alertController,
                animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
