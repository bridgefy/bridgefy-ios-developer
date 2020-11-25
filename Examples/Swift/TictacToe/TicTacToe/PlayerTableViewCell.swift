//
//  Copyright © 2020 Bridgefy. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    func configure(withPlayer player: Player) {
        playerNameLabel.text = player.userName
        if player.playerStatus == .Available {
            statusLabel.text = "Available"
            statusLabel.textColor = #colorLiteral(red: 0.5058823529, green: 0.7921568627, blue: 0.09411764706, alpha: 1)
        } else {
            statusLabel.text = "Busy"
            statusLabel.textColor = #colorLiteral(red: 0.9333333333, green: 0.3607843137, blue: 0.2705882353, alpha: 1)
        }
    }

}
