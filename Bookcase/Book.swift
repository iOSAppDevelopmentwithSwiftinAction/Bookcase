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

class Book: NSObject, NSCoding {
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
    private var image:UIImage?
    
    init(title:String,author:String,rating:Double,isbn:String,notes:String,cover:UIImage? = nil) {
        self.title = title
        self.author = author
        self.rating = rating
        self.isbn = isbn
        self.notes = notes
        self.image = cover
    }
    // MARK: NSCoding
    convenience required init?(coder aDecoder: NSCoder) {
        let rating = aDecoder.decodeDouble(forKey: Key.rating)
        guard let title = aDecoder.decodeObject(forKey: Key.title) as? String,
            let author = aDecoder.decodeObject(forKey:Key.author) as? String,
            let isbn = aDecoder.decodeObject(forKey:Key.isbn) as? String,
            let notes = aDecoder.decodeObject(forKey:Key.notes) as? String
            else { return nil }
        
        self.init(
            title: title,
            author: author,
            rating: rating,
            isbn: isbn,
            notes: notes
        )
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.title, forKey: Key.title)
        aCoder.encode(self.author, forKey: Key.author)
        aCoder.encode(self.rating, forKey: Key.rating)
        aCoder.encode(self.isbn, forKey: Key.isbn)
        aCoder.encode(self.notes, forKey: Key.notes)
    }

}
//extension Book:Equatable {}
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
