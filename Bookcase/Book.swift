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
    static let cover = "cover"
    static let backgroundColor = "backgroundColor"
    static let primaryColor = "primaryColor"
    static let detailColor = "detailColor"
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
        set {
            image = newValue
        }
    }
    var hasCoverImage:Bool {
        return image != nil
    }
    private var image:UIImage?
    var backgroundColor:UIColor
    var primaryColor:UIColor
    var detailColor:UIColor
    
    init(title:String,author:String,rating:Double,isbn:String,notes:String,cover:UIImage? = nil,backgroundColor:UIColor = .white,primaryColor:UIColor = .black, detailColor:UIColor = .black) {
        self.title = title
        self.author = author
        self.rating = rating
        self.isbn = isbn
        self.notes = notes
        self.image = cover
        self.backgroundColor = backgroundColor
        self.primaryColor = primaryColor
        self.detailColor = detailColor
    }
    // MARK: NSCoding
    convenience required init?(coder aDecoder: NSCoder) {
        let rating = aDecoder.decodeDouble(forKey: Key.rating)
        guard let title = aDecoder.decodeObject(forKey: Key.title) as? String,
            let author = aDecoder.decodeObject(forKey:Key.author) as? String,
            let isbn = aDecoder.decodeObject(forKey:Key.isbn) as? String,
            let notes = aDecoder.decodeObject(forKey:Key.notes) as? String,
            let backgroundColor = aDecoder.decodeObject(forKey:Key.backgroundColor) as? UIColor,
            let primaryColor = aDecoder.decodeObject(forKey:Key.primaryColor) as? UIColor,
            let detailColor = aDecoder.decodeObject(forKey:Key.detailColor) as? UIColor
            else { return nil }
        let cover = aDecoder.decodeObject(forKey:Key.cover) as? UIImage
        self.init(
            title: title,
            author: author,
            rating: rating,
            isbn: isbn,
            notes: notes,
            cover: cover,
            backgroundColor: backgroundColor,
            primaryColor: primaryColor,
            detailColor: detailColor
        )
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: Key.title)
        aCoder.encode(author, forKey: Key.author)
        aCoder.encode(rating, forKey: Key.rating)
        aCoder.encode(isbn, forKey: Key.isbn)
        aCoder.encode(notes, forKey: Key.notes)
        aCoder.encode(backgroundColor, forKey: Key.backgroundColor)
        aCoder.encode(primaryColor, forKey: Key.primaryColor)
        aCoder.encode(detailColor, forKey: Key.detailColor)
        if let image = image {
            aCoder.encode(image, forKey: Key.cover)
        }
    }
    override var description: String {
        return "\(title) by \(author) : \(hasCoverImage ? "Has" : "No") cover image"
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
            lhs.cover == rhs.cover &&
            lhs.backgroundColor == rhs.backgroundColor &&
            lhs.primaryColor == rhs.primaryColor &&
            lhs.detailColor == rhs.detailColor
    )
}
