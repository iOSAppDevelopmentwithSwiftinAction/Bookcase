//
//  BooksTableViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 27/07/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit

class BooksTableViewController: UITableViewController {
    var booksManager:BooksManager = BooksManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return booksManager.books.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath)
        let book = booksManager.books[indexPath.row]
        cell.textLabel?.text = book.title
        cell.detailTextLabel?.text = book.author
        cell.imageView?.image = book.cover ?? (UIImage(named: "book.jpg")!)
        return cell
    }
    //override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    //    return true
    //}
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            booksManager.removeBook(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow,
            let viewController = segue.destination as? BookViewController {
            //Editing
            viewController.book = booksManager.books[selectedIndexPath.row]
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
        tableView.reloadData()
    }

}
extension BooksTableViewController:BookViewControllerDelegate {
    func saveBook(book:Book) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            //Update book
            booksManager.updateBook(at: selectedIndexPath.row, with: book)
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
        } else {
            //Add book
            booksManager.addBook(book: book)
            let numRows = tableView.numberOfRows(inSection: 0)
            let newIndexPath = IndexPath(row: numRows, section: 0)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
        }
    }
}
