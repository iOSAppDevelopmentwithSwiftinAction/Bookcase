//
//  BooksTableViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 27/07/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit
import CoreData

private let sortOrderKey = "TableSortOrder"

class BooksTableViewController: UITableViewController {
    static let defaultCover = UIImage(named: "book.jpg")!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
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
        tableView.tableHeaderView = searchController.searchBar
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let sortOrder = SortOrder(rawValue:UserDefaults.standard.integer(forKey: sortOrderKey)) {
            sortSegmentedControl.selectedSegmentIndex = sortOrder.rawValue
            fetchedResultsController = getFetch()
        }
        tableView.reloadData()
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
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath)
        let book = self.fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = book.title
        cell.detailTextLabel?.text = book.author
        cell.imageView?.image = BooksTableViewController.defaultCover
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(fetchedResultsController.object(at: indexPath))
            appDelegate.saveContext()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow,
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
        UserDefaults.standard.set(sortOrder.rawValue, forKey: sortOrderKey)
        fetchedResultsController = getFetch()
        self.tableView.reloadData()
    }
    //MARK: FetchedResultsController
    lazy var fetchedResultsController : NSFetchedResultsController<Book> = self.getFetch()
    func getFetch()->NSFetchedResultsController<Book> {
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        //sort
        let segmentIndex = sortSegmentedControl.selectedSegmentIndex
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
extension BooksTableViewController:NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
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
extension BooksTableViewController:BookViewControllerDelegate {
    func saveBook(book:Book) {
        appDelegate.saveContext()
    }
}
extension BooksTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        fetchedResultsController = getFetch()
        tableView.reloadData()
    }
}
