//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

import UIKit

class AdminViewTabBarController: UITabBarController {
    
    public var mvc: MainViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Admin panel"
    }
    
    public func send(object: Any?, sender: Any) {
        if (mvc != nil) {
            mvc!.send(object: object, sender: sender);
        }
    }
    
}
