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
  let searchController = UISearchController(searchResultsController: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchController.obscuresBackgroundDuringPresentation = false
    tableView.tableHeaderView = searchController.searchBar
    searchController.searchResultsUpdater = self

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
    return booksManager.bookCount
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath)
    let book = booksManager.getBook(at:indexPath.row)
    cell.textLabel?.text = book.title
    cell.detailTextLabel?.text = book.author
    cell.imageView?.image = book.cover
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
      viewController.book = booksManager.getBook(at:selectedIndexPath.row)
      viewController.delegate = self
    } else if let navController = segue.destination as? UINavigationController,
      let viewController = navController.topViewController as? BookViewController {
      //Adding
      viewController.delegate = self
    }
  }
  
  @IBAction func changedSegment(_ sender: UISegmentedControl) {
  }
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
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
extension BooksTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    guard let searchText = 				//#A
      searchController.searchBar.text else { return } //#A
    booksManager.searchFilter = searchText	//#B
    tableView.reloadData()			//#C
  }
}
