//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

import UIKit

class InputTextViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var currentTextMessageLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        currentTextMessageLabel.text = ""
    }
    
    // MARK: - UITextFieldDelegate methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let message = textField.text
        currentTextMessageLabel.text = message
        textField.text = ""
        
        if let tabBarController = tabBarController as? AdminViewTabBarController {
            tabBarController.send(object: message as Any, sender: self)
        }
    }

}
