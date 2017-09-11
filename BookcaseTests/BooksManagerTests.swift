//
//  BooksManagerTests.swift
//  Bookcase
//
//  Created by Craig Grummitt on 14/11/16.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import XCTest
@testable import Bookcase
class BooksManagerTests: XCTestCase {
    var booksManager:BooksManager!
    var bookDaVinci:Book!
    var bookGulliver:Book!
    var bookOdyssey:Book!

    override func setUp() {
      super.setUp()
      bookDaVinci = Book(title: "The Da Vinci Code", author: "Dan Brown", rating: 5, isbn: "", notes: "")
      bookGulliver = Book(title: "Gulliver's Travels", author: "Jonathan Swift", rating: 5, isbn: "", notes: "")
      bookOdyssey = Book(title: "The Odyssey", author: "Homer", rating: 5, isbn: "", notes: "")
      booksManager = BooksManager()
      booksManager.addBook(bookDaVinci)
      booksManager.addBook(bookGulliver)
      booksManager.addBook(bookOdyssey)
    }
  
    override func tearDown() {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      super.tearDown()
    }
  
    func testSortTitle() {
      booksManager.sortOrder = .title
      XCTAssert(booksManager.getBook(at: 0) == bookGulliver)
      XCTAssert(booksManager.getBook(at: 1) == bookDaVinci)
      XCTAssert(booksManager.getBook(at: 2) == bookOdyssey)
    }
    func testSortAuthor() {
      booksManager.sortOrder = .author
      XCTAssert(booksManager.getBook(at: 0) == bookDaVinci)
      XCTAssert(booksManager.getBook(at: 1) == bookOdyssey)
      XCTAssert(booksManager.getBook(at: 2) == bookGulliver)
    }
    func testSearch() {
      booksManager.searchFilter = "Vinci"
      XCTAssertEqual(booksManager.bookCount, 1)
      XCTAssertEqual(booksManager.getBook(at: 0), bookDaVinci)
    }

}
