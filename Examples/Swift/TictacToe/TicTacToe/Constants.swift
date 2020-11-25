//
//  Copyright © 2020 Bridgefy. All rights reserved.
//

import Foundation
import UIKit

struct StoryboardSegues {
    static let setName = "setName"
    static let settings = "settings"
    static let startmatch = "startMatch"
    static let seeOthersMatch = "seeOthersMatch"
}

struct StoredValues {
    static let username = "username"
}

struct NotificationNames {
    static let userReady = "userReady"
}

struct CellIdentifier {
    static let user = "userCell"
    static let game = "gameCell"
}

struct Timeout {
    static let match = 30.0
}

enum TTTSymbol: Int {
    case empty = 0
    case cross = 88
    case ball = 79
}

enum MatchState: Int {
    case mustContinue = 0
    case wonX = 1
    case wonO = 2
    case tie = -1
}

let APP_RED_COLOR = #colorLiteral(red: 0.9647058824, green: 0.3098039216, blue: 0.3098039216, alpha: 1)
let DISABLE_COLOR = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
