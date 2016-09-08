//
//  BooksCollectionViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 9/08/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "bookCollectionCell"
private let sortOrderKey = "CollectionSortOrder"

class BooksCollectionViewController: UICollectionViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    lazy var context:NSManagedObjectContext = {
        return self.appDelegate.persistentContainer.viewContext
    }()
    let searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: Search
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let sortOrder = SortOrder(rawValue:UserDefaults.standard.integer(forKey: sortOrderKey)) {
            segmentedControl.selectedSegmentIndex = sortOrder.rawValue
            fetchedResultsController = getFetch()
        }
        collectionView?.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCollectionViewCell
        let book = self.fetchedResultsController.object(at: indexPath)
        cell.imageView?.isHidden = true
        cell.titleLabel.text = book.title
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedIndexPath = collectionView?.indexPathsForSelectedItems?.first,
            let viewController = segue.destination as? BookViewController {
            //Editing
            viewController.book = self.fetchedResultsController.object(at: selectedIndexPath)
            viewController.context = context
            viewController.delegate = self
        } else if let navController = segue.destination as? UINavigationController,
            let viewController = navController.topViewController as? BookViewController {
            //Adding
            viewController.delegate = self
            viewController.context = context
        }
    }
    @IBAction func changedSegment(_ sender: UISegmentedControl) {
        guard let sortOrder = SortOrder(rawValue:sender.selectedSegmentIndex) else {return}
        fetchedResultsController = getFetch()
        UserDefaults.standard.set(sortOrder.rawValue, forKey: sortOrderKey)
        collectionView?.reloadData()
    }
    //MARK: Header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "collectionHeader", for: indexPath)
        reusableView.addSubview(searchController.searchBar)
        return reusableView
    }
    //MARK: FetchedResultsController
    lazy var fetchedResultsController : NSFetchedResultsController<Book> = self.getFetch()
    func getFetch()->NSFetchedResultsController<Book> {
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        //sort
        let segmentIndex = segmentedControl.selectedSegmentIndex
        guard let sortOrder = SortOrder(rawValue:segmentIndex) else {fatalError("Segment error")}
        let titleDescriptor = NSSortDescriptor(key: "title", ascending: true,
                                               selector:#selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let authorDescriptor = NSSortDescriptor(key: "author", ascending: true,
                                                selector:#selector(NSString.localizedCaseInsensitiveCompare(_:)))
        if sortOrder == .title {
            fetchRequest.sortDescriptors = [titleDescriptor,authorDescriptor]
        } else {
            fetchRequest.sortDescriptors = [authorDescriptor,titleDescriptor]
        }
        //search
        guard let searchText = searchController.searchBar.text else { fatalError("No search bar") }
        if searchText != "" {
            fetchRequest.predicate = NSPredicate(format: "(title CONTAINS[CD] '\(searchText)') OR (author contains[cd] '\(searchText)')")
        }
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest:fetchRequest,
            managedObjectContext:self.context,
            sectionNameKeyPath:nil,
            cacheName:nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            return fetchedResultsController
        } catch {
            fatalError("Error \(error)")
        }
    }
}
extension BooksCollectionViewController:NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView?.reloadData()
    }
    //Alternatively, you can perform the specific updates with the following:
    /*
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(tableView.cellForRow(at: indexPath!)!, with: anObject as! Book)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        //no sections in this project
    }
    */
}

extension BooksCollectionViewController:BookViewControllerDelegate {
    func saveBook(book:Book) {
        appDelegate.saveContext()
    }
}
extension BooksCollectionViewController:UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 90)
    }
}
extension BooksCollectionViewController:UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        fetchedResultsController = getFetch()
        collectionView?.reloadData()
    }
}
