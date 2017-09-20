//
//  BooksCollectionViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 3/4/17.
//  Copyright © 2017 Craig Grummitt. All rights reserved.
//

import UIKit

private let reuseIdentifier = "bookCollectionCell"

class BooksCollectionViewController: UICollectionViewController {
  let searchController = UISearchController(searchResultsController: nil)
  var booksManager:BooksManager = BooksManager()
  var editingSearch = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchResultsUpdater = self
    searchController.isActive = true
    definesPresentationContext = true
    
  }
  override func viewDidAppear(_ animated: Bool) {
    collectionView?.reloadData()
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: UICollectionViewDataSource
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return section == 0 ? 0 : booksManager.bookCount
  }
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCollectionViewCell
    let book = booksManager.getBook(at: indexPath.row)
    cell.imageView.image = book.cover
    cell.titleLabel.text = book.hasCoverImage ? "" : book.title
    cell.imageView.isHidden = !book.hasCoverImage
    
    return cell
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let selectedIndexPath = collectionView?.indexPathsForSelectedItems?.first,
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
    collectionView?.reloadData()
  }
  // MARK: Header
  override func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
    let reusableView =
      collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                      withReuseIdentifier: "collectionHeader", for: indexPath)
    if indexPath.section == 0 {
      reusableView.addSubview(searchController.searchBar)
    }
    
    return reusableView
  }
}
extension BooksCollectionViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    guard let searchText = searchController.searchBar.text else { return }
    booksManager.searchFilter = searchText
   collectionView?.reloadSections(NSIndexSet(index: 1) as IndexSet)
  }
}
extension BooksCollectionViewController:BookViewControllerDelegate {
  func saveBook(_ book:Book) {
    if let selectedIndexPath = collectionView?.indexPathsForSelectedItems?.first {
      //Update book
      booksManager.updateBook(at: selectedIndexPath.row, with: book)
    } else {
      //Add book
      booksManager.addBook(book)
    }
    collectionView?.reloadData()
  }
}
extension BooksCollectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if section == 0 {
      return searchController.searchBar.bounds.size
    } else {
      return CGSize.zero
    }
  }
  func collectionView(_ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath) -> CGSize {
    let book = booksManager.getBook(at: indexPath.row)
    let itemHeight:CGFloat = 90
    let itemWidth = (book.cover.size.width /
      book.cover.size.height) * itemHeight
    return CGSize(width: itemWidth, height: itemHeight)
  }

}
