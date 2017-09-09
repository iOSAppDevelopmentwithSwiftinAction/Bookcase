//
//  Books2.swift
//  PlayJSON
//
//  Created by Craig Grummitt on 9/9/17.
//  Copyright © 2017 InteractiveCoconut. All rights reserved.
//

import Foundation
struct ServerResponse:Decodable {
  var book:Book
  
  enum CodingKeys: String, CodingKey {
    case items
  }
  enum ItemKeys: String, CodingKey {
    case volumeInfo
  }
  enum VolumeKeys: String, CodingKey {
    case title
    case authors
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    var items = try values.nestedUnkeyedContainer(forKey: .items)
    var books:[Book] = []
    while !items.isAtEnd {
      let item = try items.nestedContainer(
        keyedBy: ItemKeys.self)
      //Get title and author here
      let volumeInfo = try item.nestedContainer(
        keyedBy:VolumeKeys.self, forKey: .volumeInfo)
      let title = try volumeInfo.decode(String.self, forKey:.title)
      let authors:[String] = try volumeInfo.decode([String].self, forKey:.authors)
      let author = authors.joined(separator: ",")
      let book = Book(title: title, author: author, rating: 0, isbn: "0", notes: "")
      books.append(book)
    }
    book = books[0]
  }
}

