//
//  Copyright © 2020 Bridgefy. All rights reserved.
//

import UIKit

class MatchViewController: UIViewController, TTTBoardViewDataSource, TTTBoardViewDelegate {
    
    weak var game: Game!
    weak var activeGame: ActiveGame?
    var sideSize = 3
    var timeoutWorkItem: DispatchWorkItem?

    
    @IBOutlet weak var boardView: TTTBoardView!
    @IBOutlet weak var player1SymbolLabel: UILabel!
    @IBOutlet weak var player1UsernameLabel: UILabel!
    @IBOutlet weak var player1ScoreLabel: UILabel!
    @IBOutlet weak var player2SymbolLabel: UILabel!
    @IBOutlet weak var player2UsernameLabel: UILabel!
    @IBOutlet weak var player2ScoreLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var scoresContainer: UIView!
    @IBOutlet weak var buttonsContainer: UIView!
    @IBOutlet weak var player1Container: UIView!
    @IBOutlet weak var player2Container: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    
    @IBOutlet var portraitContraints: [NSLayoutConstraint]!
    var landscapeContraints: [NSLayoutConstraint] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBasicInfo()
        boardView.dataSource = self
        boardView.delegate = self
        boardView.isUserInteractionEnabled = game.isLocalTurn
    }
        
    func setupBasicInfo() {
        leaveButton.layer.cornerRadius = 3.0
        continueButton.layer.cornerRadius = 6.0
        continueButton.layer.borderColor = leaveButton.backgroundColor?.cgColor
        continueButton.layer.borderWidth = 1.5
        player1Container.layer.borderColor = UIColor.lightGray.cgColor
        player1Container.layer.borderWidth = 1.0
        player1Container.layer.cornerRadius = 3.0
        player2Container.layer.borderColor = UIColor.lightGray.cgColor
        player2Container.layer.borderWidth = 1.0
        player2Container.layer.cornerRadius = 3.0
        
        player1UsernameLabel.text = "\(game.player1Name):"
        player2UsernameLabel.text = "\(game.player2Name):"
        if game.player1Symbol == TTTSymbol.cross {
            player1SymbolLabel.text = "X"
            player2SymbolLabel.text = "O"
        } else {
            player1SymbolLabel.text = "O"
            player2SymbolLabel.text = "X"
        }
        updateState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Board state update methods

    func markWinner(player1Wins: Bool) {
        continueButton.isHidden = true
        boardView.isUserInteractionEnabled = false
        let winner = player1Wins ? game.player1Name : game.player2Name
        messageLabel.text = "\(winner) wins!"
        boardView.setNeedsDisplay()
    }
    
    func markLocalPlayerAsWinner() {
        continueButton.isHidden = true
        boardView.isUserInteractionEnabled = false
        messageLabel.text = "You win! Wait..."
        boardView.setNeedsDisplay()
    }
    
    func markOpponentAsWinner() {
        continueButton.isHidden = false
        boardView.isUserInteractionEnabled = false
        messageLabel.text = "You lose"
        boardView.setNeedsDisplay()
    }
    
    func markGameAsActiveTie() {
        boardView.isUserInteractionEnabled = false
        boardView.setNeedsDisplay()
        if game.isLocalTurn {
            continueButton.isHidden = false
            messageLabel.text = "It's a tie!"
        } else {
            continueButton.isHidden = true
            messageLabel.text = "Tie. Wait..."
        }
    }
    
    func markGameAsSpectatorTie() {
        boardView.isUserInteractionEnabled = false
        continueButton.isHidden = true
        boardView.setNeedsDisplay()
        messageLabel.text = "It's a tie!"
    }
    
    func updateWithLastMovement() {
        
        if game.isLocalTurn {
            messageLabel.text = "Your turn!"
        } else if game.isPlayer1Turn {
            messageLabel.text = "\(game.player1Name)'s turn!"
        } else {
            messageLabel.text = "\(game.player2Name)'s turn!"
        }
        continueButton.isHidden = true
        boardView.isUserInteractionEnabled = game.isLocalTurn
        boardView.setNeedsDisplay()
    }
    
    func updateState() {
        discardTimeout()
        player1ScoreLabel.text = "\(game.player1Wins)"
        player2ScoreLabel.text = "\(game.player2Wins)"
        let activeGame = self.activeGame == nil ? false : true
        if game.lastMatchState == .mustContinue {
            updateWithLastMovement()
        } else if game.lastMatchState == .tie {
            if activeGame {
                markGameAsActiveTie()
            } else {
                markGameAsSpectatorTie()
            }
        } else {
            
            let player1Wins = ( game.lastMatchState == .wonX && game.player1Symbol == .cross ) ||
                              ( game.lastMatchState == .wonO && game.player1Symbol == .ball )
            
            if activeGame {
                if player1Wins {
                    markLocalPlayerAsWinner()
                } else {
                    markOpponentAsWinner()
                }
            } else {
                markWinner(player1Wins: player1Wins)
            }
            
        }
    }
    
    // MARK: - UI Event actions
    @IBAction func endGame(sender: UIBarButtonItem) {
        endGameAndExit()
    }
    
    func endGameAndExit() {
        discardTimeout()
        activeGame?.endGame()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playNextGame(sender: UIButton) {
        activeGame?.resetBoard()
        updateWithLastMovement()
    }
    
    // MARK: - TTTBoardViewDataSource
    func boardPositions(in boardView: TTTBoardView) -> [[TTTSymbol]] {
        return game.boardState
    }
    
    // MARK: - TTTBoardViewDelegate
    func boardView(_ boardView: TTTBoardView, didPlayAtPosition positionX: Int, _ positionY: Int) {
        let valid = activeGame?.checkIfValidMove(posX: positionX, posY: positionY) ?? false
        if !valid {
            return
        }
        activeGame?.playMove(posX: positionX, posY: positionY)
        updateState()
        timeoutWorkItem = DispatchWorkItem.init(flags: .inheritQoS, block: { [weak self] in
            self?.endGameAndExit()
        })
        let deadline = DispatchTime.now() + Timeout.match
        DispatchQueue.global().asyncAfter(deadline: deadline,
                                          execute: timeoutWorkItem!)

    }
    
    func discardTimeout() {
        if let timeoutWorkItem = timeoutWorkItem, !timeoutWorkItem.isCancelled{
            timeoutWorkItem.cancel()
        }
        timeoutWorkItem = nil
    }
    
    deinit {
        discardTimeout()
    }
    
}
