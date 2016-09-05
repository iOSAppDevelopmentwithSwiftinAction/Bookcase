//
//  Book.swift
//  Bookcase
//
//  Created by Craig Grummitt on 28/07/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit
import CloudKit

internal struct Key {
    static let title = "title"
    static let author = "author"
    static let rating = "rating"
    static let isbn = "isbn"
    static let notes = "notes"
}

class Book {
    static let defaultCover = UIImage(named: "book.jpg")!
    var record:CKRecord
    static let recordType = "Books"
    var title:String {
        get { return record[Key.title] as! String }
        set { record[Key.title] = newValue as NSString }
    }
    var author:String {
        get { return record[Key.author] as! String }
        set { record[Key.author] = newValue as NSString }
    }
    var rating:Double {
        get { return record[Key.rating] as! Double }
        set { record[Key.rating] = newValue as NSNumber }
    }
    var isbn:String {
        get { return record[Key.isbn] as! String }
        set { record[Key.isbn] = newValue as NSString }
    }
    var notes:String {
        get { return record[Key.notes] as! String }
        set { record[Key.notes] = newValue as NSString }
    }
    
    var cover:UIImage {
        get {
            return image ?? Book.defaultCover
        }
    }
    var hasCoverImage:Bool {
        return image != nil
    }
    private var image:UIImage?
    
    init(record:CKRecord? = nil,title:String,author:String,rating:Double,isbn:String,notes:String,cover:UIImage? = nil) {
        if let record = record {
            self.record = record
        } else {
            self.record = CKRecord(recordType: Book.recordType)
        }
        self.title = title
        self.author = author
        self.rating = rating
        self.isbn = isbn
        self.notes = notes
        self.image = cover
    }
    init(record:CKRecord) {
        self.record = record
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
