//
//  Copyright © 2020 Bridgefy. All rights reserved.
//

import UIKit

class OthersGame: Game {
    
    fileprivate (set) var sequence: Int
    fileprivate (set) var player1Id: String
    fileprivate (set) var player2Id: String
    fileprivate (set) var lastMoveDate: Date
    fileprivate var _gameId: String
    fileprivate var lastPlayerId: String
    fileprivate var _lastMatchState: MatchState
    fileprivate var _player1Name: String
    fileprivate var _player2Name: String
    fileprivate var _player1Symbol: TTTSymbol
    fileprivate var _player2Symbol: TTTSymbol
    fileprivate var _player1Wins: Int
    fileprivate var _player2Wins: Int
    fileprivate var _boardState: [[TTTSymbol]]
    
    init(withMove move: [String: Any], sender: String) {
        _gameId = move[matchid_key] as! String
        lastPlayerId = sender
        let player1 = (move[participants_key] as! [String: Any])[x_key] as! [String: Any]
        let player2 = (move[participants_key] as! [String: Any])[o_key] as! [String: Any]
        player1Id = player1[uuid_key] as! String
        _player1Name = player1[nick_key] as! String
        _player1Symbol = TTTSymbol.cross
        _player1Wins = player1[wins_key] as! Int
        player2Id = player2[uuid_key] as! String
        _player2Name = player2[nick_key] as! String
        _player2Symbol = TTTSymbol.ball
        _player2Wins = player2[wins_key] as! Int
        _boardState = (move[board_key] as! [[Int]]).map{ $0.map{ TTTSymbol(rawValue: $0)! }}
        
        if let matchStateRaw = move[winner_key] as? Int {
            _lastMatchState = MatchState(rawValue: matchStateRaw)!
        } else {
            _lastMatchState = .mustContinue
        }
        sequence = move[sequence_key] as! Int
        lastMoveDate = Date()
    }
    
    func update(withMove move: [String: Any], sender: String) -> Bool {
        let lastSequence = move[sequence_key] as! Int
        if lastSequence <= sequence {
            return false
        }
        lastPlayerId = sender
        let player1 = (move[participants_key] as! [String: Any])[x_key] as! [String: Any]
        let player2 = (move[participants_key] as! [String: Any])[o_key] as! [String: Any]
        _player1Wins = player1[wins_key] as! Int
        _player2Wins = player2[wins_key] as! Int
        _boardState = (move[board_key] as! [[Int]]).map{ $0.map{ TTTSymbol(rawValue: $0)! }}
        
        if let matchStateRaw = move[winner_key] as? Int {
            _lastMatchState = MatchState(rawValue: matchStateRaw)!
        } else {
            _lastMatchState = .mustContinue
        }
        sequence = lastSequence
        lastMoveDate = Date()
        return true
    }
}

// MARK: - Game delegate

extension OthersGame {
    
    var gameId: String {
        return _gameId
    }
    var isLocalTurn: Bool {
        return false
    }
    var player1Name: String {
        return _player1Name
    }
    var player2Name: String {
        return _player2Name
    }
    var player1Symbol: TTTSymbol {
        return _player1Symbol
    }
    var player2Symbol: TTTSymbol {
        return _player2Symbol
    }
    var player1Wins: Int {
        return _player1Wins
    }
    var player2Wins: Int {
        return _player2Wins
    }
    var isPlayer1Turn: Bool {
        return lastPlayerId != player1Id
    }
    var isPlayer2Turn: Bool {
        return lastPlayerId != player2Id
    }
    var boardState: [[TTTSymbol]] {
        return _boardState
    }
    var lastMatchState: MatchState {
        return _lastMatchState
    }
}
