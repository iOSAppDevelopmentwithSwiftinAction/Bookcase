//
//  BooksCollectionViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 9/08/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit

private let reuseIdentifier = "bookCollectionCell"
private let sortOrderKey = "CollectionSortOrder"

class BooksCollectionViewController: UICollectionViewController,Injectable {
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
  }
  override func viewDidAppear(_ animated: Bool) {
    updateSortOrderFromKVS()
    NotificationCenter.default.addObserver(self, selector: #selector(uKVSChanged), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(loadCloud), name: Notifications.CloudKitReceived, object: nil)
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
      self.collectionView?.reloadData()
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
      collectionView?.reloadData()
    }
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  func inject(data:BooksManager) {
    self.booksManager = data
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
    NSUbiquitousKeyValueStore.default().set(sortOrder.rawValue, forKey: sortOrderKey)
    collectionView?.reloadData()
  }
  //MARK: Header
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "collectionHeader", for: indexPath)
    if indexPath.section == 0 {
      reusableView.addSubview(searchController.searchBar)
    }
    return reusableView
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
    collectionView?.isUserInteractionEnabled = !waiting
    navigationController?.navigationBar.isUserInteractionEnabled = !waiting
    tabBarController?.tabBar.isUserInteractionEnabled = !waiting
  }
}
extension BooksCollectionViewController:BookViewControllerDelegate {
  func saveBook(book:Book) {
    if let selectedIndexPath = collectionView?.indexPathsForSelectedItems?.first {
      //Update book
      booksManager.updateBook(at: selectedIndexPath.row, with: book)
    } else {
      //Add book
      booksManager.addBook(book: book)
    }
    collectionView?.reloadData()
  }
}
extension BooksCollectionViewController:UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if section == 0 {
      return searchController.searchBar.bounds.size
    } else {
      return CGSize.zero
    }
  }
  public func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
    let book = booksManager.getBook(at: indexPath.row)
    let itemHeight:CGFloat = 90
    let itemWidth = (book.cover.size.height / book.cover.size.width) * itemHeight
    return CGSize(width: itemWidth, height: itemHeight)
  }
}
extension BooksCollectionViewController:UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    guard let searchText = searchController.searchBar.text else { return }
    booksManager.searchFilter = searchText
    collectionView?.reloadSections(NSIndexSet(index: 1) as IndexSet)
  }
}
