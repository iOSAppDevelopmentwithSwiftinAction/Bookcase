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
        booksManager.books = [bookDaVinci,bookGulliver,bookOdyssey]
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSortTitle() {
        booksManager.sortOrder = .title
        XCTAssert(booksManager.books == [bookGulliver,bookDaVinci,bookOdyssey])
    }
    func testSortAuthor() {
        booksManager.sortOrder = .author
        XCTAssertEqual(booksManager.books,[bookDaVinci,bookOdyssey,bookGulliver])
    }
    func testSearch() {
        booksManager.searchFilter = "Vinci"
        XCTAssertEqual(booksManager.bookCount, 1)
        XCTAssertEqual(booksManager.getBook(at: 0), bookDaVinci)
    }
}
