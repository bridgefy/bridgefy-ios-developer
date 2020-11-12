//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

import UIKit

struct Constants {
    
    static let redColor = UIColor(red: 246.0/255.0, green: 79.0/255.0, blue: 79.0/255.0, alpha: 1)
    
    static let infoShowed = "info_showed"
    
    static let username = "username"
    static let vibrationEnabled = "vibration_enabled"
    
}

extension NSNotification.Name {
    
    static let vibrationNotification = NSNotification.Name("vibration_notification")
    static let usernameNotification = NSNotification.Name("username_notification")
    static let resetSentAlertNotification = NSNotification.Name("reset_sent_alerts_notification")
    static let resetReceivedAlertsNotification = NSNotification.Name("reset_received_alerts_notification")
}
