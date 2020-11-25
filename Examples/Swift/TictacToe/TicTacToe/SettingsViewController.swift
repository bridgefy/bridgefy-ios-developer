//
//  Copyright © 2020 Bridgefy. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var gameManager: GameManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        gameManager = (tabBarController as! TicTacToeTabBarController).gameManager
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nameTextField.text = gameManager.username
        saveButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didChangeText(sender: UITextField) {
        
        saveButton?.isEnabled = sender.text != nil && sender.text != "" && sender.text != gameManager.username
        
    }
    @IBAction func saveName(sender: UIBarButtonItem) {
        
        UserDefaults.standard.setValue(nameTextField?.text, forKey: StoredValues.username)
        gameManager.stop()
        gameManager.start(withUsername: nameTextField.text!)
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func tap(gesture: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

}
