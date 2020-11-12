//
//  Copyright © 2020 Bridgefy Inc. All rights reserved.
//

import UIKit
import AudioToolbox

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var vibrationSwitch: UISwitch!
    
    private var alertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateValues()
    }
    
    func updateValues() {
        usernameLabel.text = UserDefaults.standard.string(forKey: Constants.username)
        vibrationSwitch.setOn(UserDefaults.standard.bool(forKey: Constants.vibrationEnabled),
                              animated: false)
    }
    
    @IBAction func vibrationSettingChanged(_ sender: UISwitch) {
        UserDefaults.standard.setValue(sender.isOn,
                                       forKey: Constants.vibrationEnabled)
        
        if sender.isOn {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        NotificationCenter.default.post(name: .vibrationNotification,
                                        object: nil)
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView,
                            willDisplayFooterView view: UIView,
                            forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .darkGray
            header.textLabel?.font = .systemFont(ofSize: 14)
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            showTextAlert()
        case 2:
            showResetSentCounterAlert()
        case 3:
            showResetReceivedAlerts()
        case 4:
            openBridgefyPage()
        default:
            break
        }
    }
    
    func showTextAlert() {
        alertController = UIAlertController(title: "Set the new username",
                                            message: nil,
                                            preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "New username"
            textField.autocapitalizationType = .words
            textField.delegate = self
        }
        
        let okAction = UIAlertAction(title: "OK",
                                     style: .default) { _ in
            self.updateUsername(self.alertController.textFields![0].text!)
            self.clearTableSelection()
        }

        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) { _ in
            self.clearTableSelection()
        }
        
        okAction.isEnabled = false

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController,
                animated: true)
    }
    
    func updateUsername(_ username: String) {
        usernameLabel.text = username
        
        UserDefaults.standard.setValue(username, forKey: Constants.username)
        
        NotificationCenter.default.post(name: .usernameNotification,
                                        object: nil)
    }
    
    func showResetSentCounterAlert() {
        let alertController = UIAlertController(title: "Reset sent alerts counter?",
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        let okAction = UIAlertAction(title: "Yes",
                                     style: .destructive) { _ in
            NotificationCenter.default.post(name: .resetSentAlertNotification,
                                            object: nil)
            self.clearTableSelection()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) { _ in
            self.clearTableSelection()
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController,
                animated: true)
    }
    
    func showResetReceivedAlerts() {
        let alertController = UIAlertController(title: "Delete all received notification?",
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        let okAction = UIAlertAction(title: "Yes",
                                     style: .destructive) { _ in
            NotificationCenter.default.post(name: .resetReceivedAlertsNotification,
                                            object: nil)
            self.clearTableSelection()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) { _ in
            self.clearTableSelection()
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController,
                animated: true)
    }
    
    func openBridgefyPage() {
        
    }
    
    func clearTableSelection() {
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath,
                                  animated: true)
        }
    }
    
    func clean(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}

// MARK: - UITextFieldDelegate

extension SettingsTableViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        var revisedText = ""
        if let text = textField.text,
           let swiftRange = Range(range, in: text) {
            revisedText = text.replacingCharacters(in: swiftRange,
                                                   with: string)
        } else {
           revisedText = string
        }
        
        self.alertController.actions[0].isEnabled = clean(revisedText).count > 0
        
        return true
    }
}
