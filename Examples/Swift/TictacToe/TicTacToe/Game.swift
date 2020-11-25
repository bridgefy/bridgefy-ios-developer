//
//  Copyright © 2020 Bridgefy. All rights reserved.
//

import UIKit

protocol Game: class {
    var gameId: String { get }
    var isLocalTurn: Bool { get }
    var player1Name: String { get }
    var player2Name: String { get }
    var player1Symbol: TTTSymbol { get }
    var player2Symbol: TTTSymbol { get }
    var player1Wins: Int { get }
    var player2Wins: Int { get }
    var isPlayer1Turn: Bool { get }
    var isPlayer2Turn: Bool { get }
    var boardState: [[TTTSymbol]] { get }
    var lastMatchState: MatchState { get }
}

protocol ActiveGame: class {
    func resetBoard()
    func endGame()
    func checkIfValidMove(posX x: Int, posY y: Int) -> Bool
    func playMove(posX x: Int, posY y: Int)
}
