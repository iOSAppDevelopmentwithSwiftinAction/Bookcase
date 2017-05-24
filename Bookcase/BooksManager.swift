//
//  BooksManager.swift
//  Bookcase
//
//  Created by Craig Grummitt on 28/07/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import Foundation
import CloudKit


enum SortOrder:Int {
  case title
  case author
}
struct Notifications {
  static let CloudKitReceived = Notification.Name("CloudKitReceived")
}
// MARK: Paths

class BooksManager {
  private var books:[Book] = []
  var booksRequireLoading = true
  var filteredBooks:[Book] = []
  var sortOrder:SortOrder = .title {
    didSet {
      sort(books:&books)
    }
  }
  var searchFilter:String = "" {
    didSet {
      filter()
    }
  }
  var bookCount:Int {
    let bookC = searchFilter.isEmpty ? books.count : filteredBooks.count
    print("Count = \(bookC)")
    return searchFilter.isEmpty ? books.count : filteredBooks.count
  }
  let db = CKContainer.default().privateCloudDatabase
  init() {
    subscribe()
    NotificationCenter.default.addObserver(
      forName: Notifications.CloudKitReceived,
      object: nil,
      queue: OperationQueue.main,
      using: { notification in
        self.booksRequireLoading = true
    }
    )
  }
  func getBook(at index:Int)->Book {
    return searchFilter.isEmpty ? books[index] : filteredBooks[index]
  }
  func addBook(_ book:Book) {
    books.append(book)
    sort(books:&books)
  }
  func removeBook(at index:Int) {
    if searchFilter.isEmpty {
      books.remove(at: index)
    } else {
      //index is relevant to filteredBooks
      let removedBook = filteredBooks.remove(at: index)
      guard let bookIndex = books.index(of: removedBook) else {
        print("Error: book not found")
        return
      }
      books.remove(at: bookIndex)
    }
  }
  func updateBook(at index:Int, with book:Book) {
    if searchFilter.isEmpty {
      books[index] = book
      sort(books:&books)
    } else {
      let bookToUpdate = filteredBooks[index]
      guard let bookIndex = books.index(of: bookToUpdate) else {
        print("Error: book not found")
        return
      }
      books[bookIndex] = book
      sort(books:&books)
      filter()
    }
  }
  func filter() {
    filteredBooks = books.filter { book in
      return book.title.localizedLowercase.contains(searchFilter.localizedLowercase) ||
        book.author.localizedLowercase.contains(searchFilter.localizedLowercase)
    }
  }
  func sort(books:inout [Book]) {
    switch sortOrder {
    case .title:
      books.sort(by: {
        return ($0.title.localizedLowercase,$0.author.localizedLowercase) < ($1.title.localizedLowercase,$1.author.localizedLowercase)
      })
    case .author:
      books.sort(by: {
        return ($0.author.localizedLowercase,$0.title.localizedLowercase) < ($1.author.localizedLowercase,$1.title.localizedLowercase)
      })
    }
  }
  //MARK: CloudKit
  //List of error codes:
  //https://developer.apple.com/library/ios/documentation/CloudKit/Reference/CloudKit_constants/#//apple_ref/c/tdef/CKErrorCode
  func addBookCloudKit(book:Book, completion: @escaping (_ error:CKError?)->Void) {
    db.save(book.record) { (record, error) in
      DispatchQueue.main.async {
        if let error = error as? CKError {
          if let retryInterval = error.userInfo[CKErrorRetryAfterKey] as? TimeInterval {
            DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
              self.addBookCloudKit(book:book, completion:completion)
            }
            return
          }
          //Error occurred
          completion(error)
        } else {
          //Record saved to iCloud
          self.addBook(book)
          completion(nil)
        }
      }
    }
  }
  func updateBookCloudKit(at index:Int, with book:Book, completion: @escaping (_ error:Error?)->Void) {
    db.save(book.record) { (record, error) in
      DispatchQueue.main.async {
        if let error = error as? CKError {
          //Error occurred
          if error.code == .serverRecordChanged {
            if let serverRecord = error.userInfo[CKRecordChangedErrorServerRecordKey] as? CKRecord {
              book.record = serverRecord
              self.updateBook(at: index, with: book)
            }
          } else if let retryInterval = error.userInfo[CKErrorRetryAfterKey] as? TimeInterval {
            DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
              self.updateBookCloudKit(at:index, with:book, completion:completion)
            }
            return
          }
          
          completion(error)
        } else {
          self.updateBook(at: index, with: book)
          completion(nil)
        }
        
      }
    }
  }
  func deleteBookCloudKit(at index:Int, book:Book, completion: @escaping (_ error:Error?)->Void) {
    let record = book.record
    db.delete(withRecordID: record.recordID, completionHandler: { (recordID, error) -> Void in
      DispatchQueue.main.async {
        if let error = error as? CKError {
          if let retryInterval = error.userInfo[CKErrorRetryAfterKey] as? TimeInterval {
            DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
              self.deleteBookCloudKit(at:index,book:book,completion:completion)
            }
            return
          }
          completion(error)
        } else {
          self.removeBook(at: index)
          completion(nil)
        }
      }
    })
  }
  
  
  func loadBooksCloudKit(completion: @escaping (_ error:Error?)->Void) {
    let query = CKQuery(recordType: Book.recordType, predicate: NSPredicate(value: true))
    db.perform(query, inZoneWith: nil) { (records, error) in
      DispatchQueue.main.async {
        if let error = error as? CKError,
          error.code != .unknownItem {
          //Error occurred
          completion(error)
        } else if let records = records {
          self.books = records.map { Book(record: $0) }
          self.booksRequireLoading = false
          completion(nil)
        }
      }
    }
  }
  //MARK: Subscription
  
  func subscribe() {
    let alreadySubscribed = "alreadySubscribed"
    if !UserDefaults.standard.bool(forKey: alreadySubscribed) {
      let subscription = CKQuerySubscription(
        recordType: Book.recordType,
        predicate: NSPredicate(value: true),
        subscriptionID: "All Book updates",
        options: [.firesOnRecordCreation,
                  .firesOnRecordDeletion,
                  .firesOnRecordUpdate]
      )
      
      let notificationInfo = CKNotificationInfo()
      notificationInfo.shouldSendContentAvailable = true
      //notificationInfo.shouldBadge = true
      //notificationInfo.alertBody = "Your books have changed!"
      //notificationInfo.soundName = "default"
      subscription.notificationInfo = notificationInfo
      db.save(subscription) { (subscription, error) in
        if error == nil {
          UserDefaults.standard.set(true, forKey: alreadySubscribed)
        }
      }
    }
  }
}
