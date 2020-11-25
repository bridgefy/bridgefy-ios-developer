//
//  Copyright © 2020 Bridgefy. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentationController?.delegate = self
        startButton.isEnabled = false
        startButton.backgroundColor = DISABLE_COLOR
        nameTextField.delegate = self
        nameTextField.becomeFirstResponder()
        addStyle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func addStyle() {
        //Textfield
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0.0,
                              y: nameTextField.frame.size.height - width,
                              width: nameTextField.frame.size.width,
                              height: width)
        border.borderWidth = width
        nameTextField.layer.addSublayer(border)
        nameTextField.layer.masksToBounds = true
        
        //Button
        startButton.layer.cornerRadius = 4.0
        
    }
    
    @IBAction func didChangeText(sender: UITextField) {
        startButton?.isEnabled = sender.text != ""
        startButton.backgroundColor = sender.text != "" ? UIColor.white: DISABLE_COLOR
        
    }
    
    @IBAction func startApp(sender: UIButton) {
        // Username validation
        
        let myString = nameTextField.text
        let trimmedString = myString?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedString == "" {
            nameTextField.text = ""
            nameTextField.placeholder = "Enter a valid username"
            startButton.isEnabled = false
            startButton.backgroundColor = DISABLE_COLOR
            return
        }
        
        UserDefaults.standard.setValue(nameTextField?.text, forKey: StoredValues.username)
        let username: String = nameTextField!.text!
        let userInfo: [AnyHashable : Any] = [StoredValues.username: username]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNames.userReady),
                                        object: self,
                                        userInfo: userInfo)
        dismiss(animated: true)
        
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            startApp(sender: startButton)
        }
        
        return true
    }

}

// - MARK: UIAdaptivePresentationControllerDelegate

extension InitialViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
}
