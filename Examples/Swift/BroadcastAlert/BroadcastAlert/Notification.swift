//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

import UIKit

open class Notification: NSObject, NSCoding {
    var number: NSInteger
    var senderId: String
    var senderName: String
    var date: Date

    
    override required public init()
    {
        self.number = 0
        self.senderId = ""
        self.senderName = ""
        self.date = Date()
    }
    
    required public init(coder decoder: NSCoder) {
        self.number =  (decoder.decodeObject(forKey: "number") as! NSNumber).intValue
        self.senderId = decoder.decodeObject(forKey: "senderId") as! String
        self.senderName = decoder.decodeObject(forKey: "senderName") as! String
        self.date = decoder.decodeObject(forKey: "date") as! Date

    }
    
    open func encode(with encoder: NSCoder) {
        encoder.encode(NSNumber(value: self.number as Int), forKey: "number")
        encoder.encode(self.senderId, forKey: "senderId")
        encoder.encode(self.senderName, forKey: "senderName")
        encoder.encode(self.date, forKey: "date")

    }
}
