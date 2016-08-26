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

class Book {
    static let defaultCover = UIImage(named: "book.jpg")!
    var title:String
    var author:String
    var rating:Double
    var isbn:String
    var notes:String
    var id:Int
    var cover:UIImage {
        get {
            return image ?? Book.defaultCover
        }
    }
    var hasCoverImage:Bool {
        return image != nil
    }
    private var image:UIImage?
    
    init(title:String,author:String,rating:Double,isbn:String,notes:String,id:Int? = nil,cover:UIImage? = nil) {
        self.title = title
        self.author = author
        self.rating = rating
        self.isbn = isbn
        self.notes = notes
        self.id = id ?? -1
        self.image = cover
    }
    convenience init?(rs:FMResultSet) {
        let rating = rs.double(forColumn: Key.rating)
        let id = rs.int(forColumn: "ROWID")
        guard let title = rs.string(forColumn: Key.title),
            let author = rs.string(forColumn: Key.author),
            let isbn = rs.string(forColumn: Key.isbn),
            let notes = rs.string(forColumn: Key.notes)
            else { return nil }
        self.init(title:title,
                  author:author,
                  rating:rating,
                  isbn:isbn,
                  notes:notes,
                  id:Int(id)
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
        lhs.cover == rhs.cover &&
        lhs.id == rhs.id
    )
}
