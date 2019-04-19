//
//  BooksManager.swift
//  Bookcase
//
//  Created by Craig Grummitt on 28/07/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import Foundation

enum SortOrder:Int {
    case title
    case author
}
// MARK: Paths
private let appSupportDirectory:URL = {
    let url = FileManager().urls(for:.applicationSupportDirectory,in: .userDomainMask).first!
    if !FileManager().fileExists(atPath: url.path) {
        do {
            try FileManager().createDirectory(at: url,
                                              withIntermediateDirectories: false)
        } catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        
    }
    return url
}()
private let booksFile = appSupportDirectory.appendingPathComponent("Books")

class BooksManager {
    private lazy var books:[Book] = self.loadBooks()
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
    func getBook(at index:Int)->Book {
        return searchFilter.isEmpty ? books[index] : filteredBooks[index]
    }
    private func loadBooks()->[Book] {
        return retrieveBooks() ?? sampleBooks()
    }
    func addBook(_ book:Book) {
        books.append(book)
        sort(books:&books)
        storeBooks()
    }
    func removeBook(at index:Int) {
        if searchFilter.isEmpty {
            books.remove(at: index)
        } else {
            //index is relevant to filteredBooks
            let removedBook = filteredBooks.remove(at: index)
            guard let bookIndex = books.firstIndex(of: removedBook) else {
                print("Error: book not found")
                return
            }
            books.remove(at: bookIndex)
        }
        storeBooks()
    }
    func updateBook(at index:Int, with book:Book) {
        if searchFilter.isEmpty {
            books[index] = book
            sort(books:&books)
        } else {
            let bookToUpdate = filteredBooks[index]
            guard let bookIndex = books.firstIndex(of: bookToUpdate) else {
                print("Error: book not found")
                return
            }
            books[bookIndex] = book
            sort(books:&books)
            filter()
        }
        storeBooks()
    }
    private func sampleBooks()->[Book] {
        return []
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
    // MARK: Encoding
    func storeBooks() {
      do {
        let encoder = PropertyListEncoder()
        let data = try encoder.encode(books)
        let success = NSKeyedArchiver.archiveRootObject(data, toFile: booksFile.path)
        print(success ? "Successful save" : "Save Failed")
      } catch {
        print("Save Failed")
      }
    }
    
    // MARK: Decoding
    func retrieveBooks() -> [Book]? {
      guard let data = NSKeyedUnarchiver.unarchiveObject(withFile: booksFile.path) as? Data else { return nil }
      do {
        let decoder = PropertyListDecoder()
        let books = try decoder.decode([Book].self, from: data)
        return books
      } catch {
        print("Retrieve Failed")
        return nil
      }
    }


}
