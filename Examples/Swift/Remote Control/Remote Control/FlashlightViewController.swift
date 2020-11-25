//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

import UIKit

class FlashlightViewController: UIViewController {
    
    @IBOutlet weak var flashlightButton: UIButton!

    @IBAction func turnOnFlashlight(_ sender: Any) {
        flashlightButton.isEnabled = false
        
        perform(#selector(enableFlashlightButton),
                     with: nil,
                     afterDelay: 15)
        
        if let tabBarController = tabBarController as? AdminViewTabBarController {
            tabBarController.send(object: nil, sender: self)
        }
    }
    
    @objc func enableFlashlightButton() {
        flashlightButton.isEnabled = true
    }

}
