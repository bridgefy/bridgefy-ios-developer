//
//  FeedTableViewController.swift
//  TicTacToe
//
//  Created by Bridgefy on 5/22/17.
//  Copyright © 2017 Bridgefy. All rights reserved.
//

import UIKit
import CoreData

class FeedTableViewController: UITableViewController {
    
    fileprivate var dataController: DataController!
    fileprivate var transferManager: TransferManager!
    fileprivate var fetchedResultController: NSFetchedResultsController<Tweet>!
    fileprivate var noTweetsView: UIView?

    
    fileprivate lazy var username: String? = {
        return UserDefaults.standard.value(forKey: StoredValues.username) as? String
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataController = DataController()
        self.dataController.username = self.username
        self.dataController.delegate = self
        self.fetchedResultController = dataController.createFeedFetchedResultController()
        self.fetchedResultController.delegate = self
        self.transferManager = TransferManager()
        self.transferManager.dataController = self.dataController
        self.tableView.estimatedRowHeight = 114.0
        self.registerForNotifications()
        self.checkForNoTweetsView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (username == nil) {
            self.parent!.performSegue(withIdentifier: StoryboardSegues.setName, sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkForNoTweetsView() {
        if self.fetchedResultController.sections![0].numberOfObjects == 0 {
            self.noTweetsView = Bundle.main.loadNibNamed("EmptyTable", owner: self, options: nil)?.first as? UIView
            self.tableView.tableHeaderView = self.noTweetsView
        } else {
            self.noTweetsView = nil
            self.tableView.tableHeaderView = nil
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - User actions

extension FeedTableViewController {
    @IBAction func composeTweet(sender: Any) {
        self.performSegue(withIdentifier: StoryboardSegues.compose, sender: self)
    }
    
    @IBAction func toggletInternetForward(sender: UIBarButtonItem) {
        if self.transferManager.isInternetForwardEnabled {
            self.transferManager.isInternetForwardEnabled = false
            sender.image = #imageLiteral(resourceName: "clouduploaddisabled")
        } else  {
            self.transferManager.isInternetForwardEnabled = true
            sender.image = #imageLiteral(resourceName: "cloudupload")
        }

    }
}

// MARK: - Table view data source

extension FeedTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.tweet, for: indexPath) as! TweetTableViewCell
        let tweet = self.fetchedResultController.object(at: indexPath)
        cell.configure(tweet: tweet)
        return cell
    }
}

// MARK: - Table view delegate

extension FeedTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
    
// MARK: - Notifications

extension FeedTableViewController {
    
    func registerForNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NotificationNames.userReady),
                                               object: nil,
                                               queue: nil) { (notification) in
                                                self.username = (notification.userInfo![StoredValues.username] as! String)
                                                self.dataController.username = self.username
        }
    }
}

// MARK: - Compose Delegate

extension FeedTableViewController: ComposeDelegate {
    
    func composeController(_ composeController: ComposeViewController, didCreateTweet tweetText: String) {
        self.dataController.insertOwnTweet(withText: tweetText)
    }
}

// MARK: - DataController delegate 

extension FeedTableViewController: DataControllerDelegate {
    
    func dataController(_ dataController: DataController, didInsertTweet tweet: Tweet) {
        if tweet.own {
            self.transferManager.sendTweet(tweet)
        } else if tweet.status == TweetStatus.offline {
            self.transferManager.postTweetToInternet(tweet: tweet, completion: { success in
                if success {
                    self.transferManager.transmitTweetOffline(tweet)
                }
            } )
        }
    }
}

// MARK: - Segue management

extension FeedTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegues.compose {
            let composeController = segue.destination as! ComposeViewController
            composeController.delegate = self
            composeController.username = self.username ?? ""
        }
    }
}


// MARK: - Fetched Result Controller Delegate

extension FeedTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            if let cell =  tableView.cellForRow(at: indexPath!) as? TweetTableViewCell {
                let tweet = fetchedResultController.object(at: indexPath!)
                cell.configure(tweet: tweet)
            }
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
        self.checkForNoTweetsView()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
