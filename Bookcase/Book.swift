//
//  Book.swift
//  Bookcase
//
//  Created by Craig Grummitt on 28/07/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit


struct Book: Codable {
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
    private var image:UIImage? = nil
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
    // MARK: Codable
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      title = try container.decode(String.self, forKey: .title)
      author = try container.decode(String.self, forKey: .author)
      rating = try container.decode(Double.self, forKey: .rating)
      isbn = try container.decode(String.self, forKey: .isbn)
      notes = try container.decode(String.self, forKey: .notes)
      
      let backgroundColorData = try container.decode(Data.self, forKey: .backgroundColor)
      self.backgroundColor = NSKeyedUnarchiver.unarchiveObject(with: backgroundColorData) as? UIColor ?? .white
      
      let primaryColorData = try container.decode(Data.self, forKey: .primaryColor)
      self.primaryColor = NSKeyedUnarchiver.unarchiveObject(with: primaryColorData) as? UIColor ?? .black
      
      let detailColorData = try container.decode(Data.self, forKey: .detailColor)
      self.detailColor = NSKeyedUnarchiver.unarchiveObject(with: detailColorData) as? UIColor ?? .black
      
      if let imageData = try container.decodeIfPresent(Data.self, forKey: .imageData) {
        image = NSKeyedUnarchiver.unarchiveObject(with: imageData) as? UIImage
      } else {
        image = nil
      }
    }
    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(title, forKey: .title)
      try container.encode(author, forKey: .author)
      try container.encode(rating, forKey: .rating)
      try container.encode(isbn, forKey: .isbn)
      try container.encode(notes, forKey: .notes)
      
      let backgroundColorData = NSKeyedArchiver.archivedData(withRootObject: backgroundColor)
      try container.encode(backgroundColorData, forKey: .backgroundColor)
      
      let primaryColorData = NSKeyedArchiver.archivedData(withRootObject: primaryColor)
      try container.encode(primaryColorData, forKey: .primaryColor)
      
      let detailColorData = NSKeyedArchiver.archivedData(withRootObject: detailColor)
      try container.encode(detailColorData, forKey: .detailColor)
      
      if let image = image {
        let imageData = NSKeyedArchiver.archivedData(withRootObject: image)
        try container.encode(imageData, forKey: .imageData)
      }
    }
    enum CodingKeys: String, CodingKey {
      case title
      case author
      case rating
      case isbn
      case notes
      case imageData
      case backgroundColor
      case primaryColor
      case detailColor
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
            lhs.backgroundColor == rhs.backgroundColor &&
            lhs.primaryColor == rhs.primaryColor &&
            lhs.detailColor == rhs.detailColor
    )
}
