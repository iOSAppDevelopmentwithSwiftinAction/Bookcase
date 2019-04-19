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
private var appSupportDirectory:URL = {
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
private var booksFile:URL = {
    let filePath = appSupportDirectory.appendingPathComponent("Books").appendingPathExtension("db")
  print(filePath)
    if !FileManager().fileExists(atPath: filePath.path) {
        if let bundleFilePath = Bundle.main.resourceURL?.appendingPathComponent("Books").appendingPathExtension("db") {
            do {
                try FileManager().copyItem(at: bundleFilePath, to: filePath)
            } catch let error as NSError {
                //fingers crossed
                print("\(error.localizedDescription)")
            }
        }
    }
    return filePath
}()

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
        return retrieveBooks() ?? []
    }
    func addBook(_ book:Book) {
        var book = book
        SQLAddBook(book: &book)
        books.append(book)
        sort(books:&books)
    }
    func removeBook(at index:Int) {
        var bookToRemove:Book
        if searchFilter.isEmpty {
            bookToRemove = books.remove(at: index)
        } else {
            //index is relevant to filteredBooks
            let removedBook = filteredBooks.remove(at: index)
            guard let bookIndex = books.firstIndex(of: removedBook) else {
                print("Error: book not found")
                return
            }
            bookToRemove = books.remove(at: bookIndex)
        }
        SQLRemoveBook(book: bookToRemove)
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
        SQLUpdateBook(book: book)
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
    //MARK: SQLite
    func retrieveBooks() -> [Book]? {
        guard let db = getOpenDB() else { return nil }
        var books:[Book] = []
        do {
            let rs = try db.executeQuery(
                "SELECT *, ROWID FROM Books", values: nil)
            while rs.next() {
                if let book = Book(rs: rs) {
                    books.append(book)
                }
            }
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        db.close()
        return books
    }
    func SQLAddBook(book:inout Book) {
        guard let db = getOpenDB() else { return  }
        do {
            try db.executeUpdate(
                "insert into Books (title, author, rating, isbn, notes) values (?, ?, ?, ?, ?)",
                values: [book.title, book.author, book.rating, book.isbn, book.notes]
            )
            book.id = Int(db.lastInsertRowId)
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        db.close()
    }
    func SQLRemoveBook(book:Book) {
        guard let db = getOpenDB() else { return  }
        do {
            try db.executeUpdate(
                "delete from Books where ROWID = ?",
                values: [book.id]
            )
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        db.close()
    }
    func SQLUpdateBook(book:Book) {
        guard let db = getOpenDB() else { return  }
        do {
            try db.executeUpdate(
                "update Books SET title = ?, author = ?, rating = ?, isbn = ?, notes = ? WHERE ROWID = ?", values: [book.title, book.author, book.rating, book.isbn, book.notes, book.id]
            )
        } catch {
            print("failed: \(error.localizedDescription)")
        }
        db.close()
    }
    func getOpenDB()->FMDatabase? {
        let db = FMDatabase(path: booksFile.path)
        guard db.open() else {
            print("Unable to open database")
            return nil
        }
        return db
    }


}
