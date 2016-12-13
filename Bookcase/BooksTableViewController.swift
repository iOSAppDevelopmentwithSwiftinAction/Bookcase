//
//  BooksTableViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 27/07/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit
import CloudKit

private let sortOrderKey = "TableSortOrder"

class BooksTableViewController: UITableViewController, Injectable {
    var booksManager:BooksManager!
    let searchController = UISearchController(searchResultsController: nil)

    lazy var activityIndicator:UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            indicator.center = self.view.center
            self.view.addSubview(indicator)
        return indicator
    }()
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: Search
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSortOrderFromKVS()
        NotificationCenter.default.addObserver(self, selector: #selector(uKVSChanged), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: nil)
        if booksManager.booksRequireLoading {
            loadCloud()
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle =
            NSAttributedString(string: "Reload Books")
        refreshControl?.addTarget(self, action: #selector(loadCloud), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(loadCloud),
            name: Notifications.CloudKitReceived,
            object: nil)
    }
    
    func loadCloud(reload:Bool = false) {
        cloudOperation(waiting: true)
        booksManager.loadBooksCloudKit(completion: { (error) in
            self.cloudErrors(error: error,buttonTitle:"Try again") {
                self.loadCloud()
                return
            }
            self.cloudOperation(waiting: false)
            self.updateSortOrderFromKVS()
            self.tableView?.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    func uKVSChanged(notification:Notification) {
        updateSortOrderFromKVS()
    }
    func updateSortOrderFromKVS() {
        if let sortOrder = SortOrder(rawValue:Int(NSUbiquitousKeyValueStore.default().longLong(forKey: sortOrderKey))) {
            booksManager.sortOrder = sortOrder
            sortSegmentedControl.selectedSegmentIndex = booksManager.sortOrder.rawValue
            tableView.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func inject(data:BooksManager) {
        self.booksManager = data
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return booksManager.bookCount
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath)
        let book = booksManager.getBook(at: indexPath.row)
        cell.textLabel?.text = book.title
        cell.detailTextLabel?.text = book.author
        cell.imageView?.image = book.cover
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let book = booksManager.getBook(at: indexPath.row)
            cloudOperation(waiting:true)
            booksManager.deleteBookCloudKit(at: indexPath.row, book: book, completion: { (error) in
                self.cloudOperation(waiting:false)
                self.cloudErrors(error: error)
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow,
            let viewController = segue.destination as? BookViewController {
            //Editing
            viewController.book = booksManager.getBook(at: selectedIndexPath.row)
            viewController.delegate = self
        } else if let navController = segue.destination as? UINavigationController,
            let viewController = navController.topViewController as? BookViewController {
            //Adding
            viewController.delegate = self
        }
    }
    @IBAction func changedSegment(_ sender: UISegmentedControl) {
        guard let sortOrder = SortOrder(rawValue:sender.selectedSegmentIndex) else {return}
        booksManager.sortOrder = sortOrder
        NSUbiquitousKeyValueStore.default().set(sortOrder.rawValue, forKey: sortOrderKey)
        tableView.reloadData()
    }
    //MARK: Cloudkit
    func cloudErrors(error: Error?, buttonTitle:String = "OK", completion:(()->Void)? = nil) {
        if let error = error {
            let alertController = UIAlertController(title: "CloudKit error", message: error.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: buttonTitle, style: .default) { (action) in
                completion?()
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
    }
    func cloudOperation(waiting: Bool) {
        if waiting {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        tableView?.isUserInteractionEnabled = !waiting
        navigationController?.navigationBar.isUserInteractionEnabled = !waiting
        tabBarController?.tabBar.isUserInteractionEnabled = !waiting
    }
}
extension BooksTableViewController:BookViewControllerDelegate {
    func saveBook(book:Book) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            //Update book
            cloudOperation(waiting:true)
            booksManager.updateBookCloudKit(at: selectedIndexPath.row, with: book, completion: { (error) in
                self.cloudOperation(waiting:false)
                self.cloudErrors(error: error)
                self.tableView.reloadData()
            })
        } else {
            //Add book
            cloudOperation(waiting:true)
            booksManager.addBookCloudKit(book: book, completion: { (error) in
                self.cloudOperation(waiting:false)
                self.cloudErrors(error: error)
                self.tableView.reloadData()
            })
        }
    }
}
extension BooksTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        booksManager.searchFilter = searchText
        tableView.reloadData()
    }
}

