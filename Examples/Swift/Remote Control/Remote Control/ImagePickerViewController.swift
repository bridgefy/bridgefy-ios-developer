//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

import UIKit

class ImagePickerViewController: UIViewController {
    
    var currentButton: UIButton?
    
    @IBAction func imageButtonPressed(_ sender: Any) {
        let selectedButton = sender as! UIButton
        
        currentButton?.setImage(#imageLiteral(resourceName: "radioButtonOff"), for: .normal)
        selectedButton.setImage(#imageLiteral(resourceName: "radioButtonOn"), for: .normal)
        currentButton = selectedButton
        
        if let tabBarController = tabBarController as? AdminViewTabBarController {
            tabBarController.send(object: selectedButton.tag as Any, sender: self)
        }
    }
    
}
