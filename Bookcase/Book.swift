//
//  Book.swift
//  Bookcase
//
//  Created by Craig Grummitt on 28/07/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit
internal struct Key {
    static let title = "title"
    static let author = "author"
    static let rating = "rating"
    static let isbn = "isbn"
    static let notes = "notes"
}

struct Book {
    static let defaultCover = UIImage(named: "book.jpg")!
    var title:String
    var author:String
    var rating:Double
    var isbn:String
    var notes:String
    var cover:UIImage {
        get {
            return image ?? Book.defaultCover
        }
    }
    var hasCoverImage:Bool {
        return image != nil
    }
    private var image:UIImage? = nil
    
    init(title:String,author:String,rating:Double,isbn:String,notes:String,cover:UIImage? = nil) {
        self.title = title
        self.author = author
        self.rating = rating
        self.isbn = isbn
        self.notes = notes
        self.image = cover
    }
    //XML
    var xml:XMLNode {
        let bookNode = XMLNode(name: "book")
        bookNode.addChild(name: Key.title, value: self.title)
        bookNode.addChild(name: Key.author, value: self.author)
        bookNode.addChild(name: Key.rating, value: String(self.rating))
        bookNode.addChild(name: Key.isbn, value: self.isbn)
        bookNode.addChild(name: Key.notes, value: self.notes)
        return bookNode
    }
    init?(book:XMLNode) {
      guard let title = book[Key.title]?.text,
              let author = book[Key.author]?.text,
              let ratingString = book[Key.rating]?.text,
              let rating = Double(ratingString),
              let isbn = book[Key.isbn]?.text,
              let notes = book[Key.notes]?.text
              else {return nil}
      self.init(title:title,
              author:author,
              rating:rating,
              isbn:isbn,
              notes:notes
          )
    }
}
extension Book:Equatable {}
func ==(lhs: Book, rhs: Book) -> Bool {
    return (
        lhs.title == rhs.title &&
        lhs.author == rhs.author &&
        lhs.rating == rhs.rating &&
        lhs.isbn == rhs.isbn &&
        lhs.notes == rhs.notes &&
        lhs.cover == rhs.cover
    )
}
