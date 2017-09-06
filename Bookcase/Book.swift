//
//  Book.swift
//  Bookcase
//
//  Created by Craig Grummitt on 28/07/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit
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
    private var image:UIImage?
    
    init(title:String,author:String,rating:Double,isbn:String,notes:String,cover:UIImage? = nil) {
        self.title = title
        self.author = author
        self.rating = rating
        self.isbn = isbn
        self.notes = notes
        self.image = cover
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
