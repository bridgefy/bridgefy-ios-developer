//
//  Copyright © 2020 Bridgefy. All rights reserved.
//

import UIKit

class MatchesTableViewController: UITableViewController, SpectatorDelegate {

    var gameManager: GameManager!
    var noPlayersView: UIView?
    weak var showingmatchController: MatchViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameManager = (tabBarController as! TicTacToeTabBarController).gameManager
        gameManager.spectatorDelegate = self
        checkNoPlayersView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if gameManager.cleanOldOthersGames() == true {
            checkNoPlayersView()
            tableView.reloadData()
        }
    }
    
    func checkNoPlayersView() {
        if gameManager.othersGames.count == 0 {
            noPlayersView = Bundle.main.loadNibNamed("NoMatches", owner: self, options: nil)?.first as? UIView
            tableView.tableHeaderView = noPlayersView
        } else {
            noPlayersView = nil
            tableView.tableHeaderView = nil
        }
    }
}

// MARK: - Table view data source

extension MatchesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameManager.othersGames.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.game, for: indexPath) as! GameTableViewCell
        let game = gameManager.othersGames[indexPath.row]
        cell.configure(withGame: game)
        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
}

// MARK: - Table view delegate

extension MatchesTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let othersGame = gameManager.othersGames[indexPath.row]
        if othersGame.lastMoveDate.timeIntervalSinceNow * -1 > Timeout.match {
            //The game is not longer valid and can't be opened.
            if gameManager.cleanOldOthersGames() == true {
                checkNoPlayersView()
                tableView.reloadData()
            }
        } else {
            performSegue(withIdentifier: StoryboardSegues.seeOthersMatch, sender: othersGame)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - Segue management

extension MatchesTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegues.seeOthersMatch {
            let navController = segue.destination as! UINavigationController
            let matchController = navController.topViewController  as! MatchViewController
            showingmatchController = matchController
            matchController.game = sender as? Game
            matchController.activeGame = nil
        }
    }
}

// MARK: - Spectators delegate

extension MatchesTableViewController {
    func gameManager(_ gameManager: GameManager, didDetectNewSpectatorGame othersGame: OthersGame) {
        checkNoPlayersView()
        tableView.reloadData()
    }
    
    func gameManager(_ gameManager: GameManager, didFinishGame othersGame: OthersGame) {
        if othersGame.gameId == showingmatchController?.game.gameId {
            showingmatchController?.endGameAndExit()
        }
        checkNoPlayersView()
        tableView.reloadData()
    }
    
    func gameManager(_ gameManager: GameManager, didDetectMoveInSpectatorGame othersGame: OthersGame) {
        if othersGame.gameId == showingmatchController?.game.gameId {
            showingmatchController?.updateState()
        }
    }

}
