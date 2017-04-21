//
//  BooksManager.swift
//  Bookcase
//
//  Created by Craig Grummitt on 28/07/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import Foundation

enum SortOrder: Int {
  case title
  case author
}


class BooksManager {
  lazy var books:[Book] = self.loadBooks()
  func getBook(at index: Int) -> Book {
    return searchFilter.isEmpty ? books[index] : filteredBooks[index]
  }
  var bookCount: Int {
    return searchFilter.isEmpty ? books.count : filteredBooks.count
  }
  var sortOrder = SortOrder.title
  var searchFilter = "" {
    didSet {
      filter()
    }
  }
  var filteredBooks: [Book] = []

  func loadBooks()->[Book] {
    return sampleBooks()
  }
  func addBook(book:Book) {
    books.append(book)
    sort(books: &books)
  }
  func removeBook(at index: Int) {
    if searchFilter.isEmpty {
      books.remove(at: index)
    } else {
      let removedBook = filteredBooks.remove(at: index)		//#A
      guard let bookIndex = books.index(of: removedBook) else {	//#B
        print("Error: book not found")
        return
      }
      books.remove(at: bookIndex)					//#C

    }
  }

  func updateBook(at index: Int, with book: Book) {
    if searchFilter.isEmpty {
      books[index] = book
      sort(books: &books)
    } else {
      let bookToUpdate = filteredBooks[index]	//#A
      guard let bookIndex = books.index(of: bookToUpdate) else { //#B
        print("Error: book not found")
        return
      }
      books[bookIndex] = book			//#C
      sort(books: &books)
      filter()
    }
    
  }

  func sampleBooks()->[Book] {
    return [
      Book(title: "Great Expectations", author: "Charles Dickens", rating: 5, isbn: "9780140817997", notes: "🎁 from Papa"),
      Book(title: "Don Quixote", author: "Miguel De Cervantes", rating: 4, isbn: "9788471890153", notes: ""),
      Book(title: "Robinson Crusoe", author: "Daniel Defoe", rating: 5, isbn: "", notes: ""),
      Book(title: "Gulliver's Travels", author: "Jonathan Swift", rating: 5, isbn: "", notes: ""),
      Book(title: "Emma", author: "Jane Austen", rating: 5, isbn: "", notes: ""),
      Book(title: "To Kill a Mockingbird", author: "Harper Lee", rating: 5, isbn: "", notes: ""),
      Book(title: "Animal Farm", author: "George Orwell", rating: 4, isbn: "", notes: ""),
      Book(title: "Gone with the Wind", author: "Margaret Mitchell", rating: 5, isbn: "", notes: ""),
      Book(title: "The Fault in Our Stars", author: "John Green", rating: 5, isbn: "", notes: ""),
      Book(title: "The Da Vinci Code", author: "Dan Brown", rating: 5, isbn: "", notes: ""),
      Book(title: "Les Misérables ", author: "Victor Hugo", rating: 5, isbn: "", notes: ""),
      Book(title: "Lord of the Flies ", author: "William Golding", rating: 5, isbn: "", notes: ""),
      Book(title: "The Alchemist", author: "Paulo Coelho", rating: 5, isbn: "", notes: ""),
      Book(title: "Life of Pi", author: "Yann Martel", rating: 5, isbn: "", notes: ""),
      Book(title: "The Odyssey", author: "Homer", rating: 5, isbn: "", notes: ""),
      
      //More books
    ]
  }
  func sort(books: inout [Book]) {
    books.sort(by: {
      return ($0.title.localizedLowercase, $0.author.localizedLowercase) <
        ($1.title.localizedLowercase, $1.author.localizedLowercase)
      
    })
  }
  func filter() {
    filteredBooks = books.filter { book in			//#A
      return book.title.localizedLowercase.contains(	//#B
        searchFilter.localizedLowercase) || 	//#B
        book.author.localizedLowercase.contains(	//#C
          searchFilter.localizedLowercase)		//#C
    }
  }

}
