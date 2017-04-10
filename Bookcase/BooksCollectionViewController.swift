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
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: UICollectionViewDataSource
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return booksManager.bookCount
  }
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCollectionViewCell
    let book = booksManager.getBook(at: indexPath.row)
    cell.imageView.image = book.cover
    cell.titleLabel.text = book.hasCoverImage ? "" : book.title
    cell.imageView.isHidden = !book.hasCoverImage
    
    return cell
  }
  
  // MARK: Header
  override func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
    let reusableView =
      collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                      withReuseIdentifier: "collectionHeader", for: indexPath)
      reusableView.addSubview(searchController.searchBar)
    return reusableView
  }
}
extension BooksCollectionViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    guard let searchText = searchController.searchBar.text else { return }
    booksManager.searchFilter = searchText
   collectionView?.reloadData()
  }
}
