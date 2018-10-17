//
//  BooksTableViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 27/07/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit

private let sortOrderKey = "TableSortOrder"
let beenHereBefore = "BeenHereBefore"

class BooksTableViewController: UITableViewController,Injectable {
    var booksManager:BooksManager!
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: Search
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
          self.navigationItem.searchController = searchController
        } else {
          tableView.tableHeaderView = searchController.searchBar
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UserDefaults.standard.bool(forKey: beenHereBefore) {
            self.performSegue(withIdentifier: "helpSegue", sender: self)
        }
        if let sortOrder = SortOrder(rawValue:UserDefaults.standard.integer(forKey: sortOrderKey)) {
            booksManager.sortOrder = sortOrder
            sortSegmentedControl.selectedSegmentIndex = booksManager.sortOrder.rawValue
        }
        tableView.reloadData()
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
        cell.backgroundColor = book.backgroundColor
        cell.textLabel?.textColor = book.primaryColor
        cell.detailTextLabel?.textColor = book.detailColor
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            booksManager.removeBook(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
        UserDefaults.standard.set(sortOrder.rawValue, forKey: sortOrderKey)
        tableView.reloadData()
    }

}
extension BooksTableViewController:BookViewControllerDelegate {
    func saveBook(_ book:Book) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            //Update book
            booksManager.updateBook(at: selectedIndexPath.row, with: book)
        } else {
            //Add book
            booksManager.addBook(book)
        }
        tableView.reloadData()
    }
}
extension BooksTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        booksManager.searchFilter = searchText
        tableView.reloadData()
    }
}
