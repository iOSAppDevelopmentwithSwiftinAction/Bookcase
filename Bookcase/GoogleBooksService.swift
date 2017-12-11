//
//  BooksService.swift
//  Bookcase
//
//  Created by Craig Grummitt on 13/10/16.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol BooksService {
    func getBook(with barcode:String, completionHandler: @escaping (Book?, Error?) -> Void)
    func cancel()
}

class GoogleBooksService:NSObject, BooksService, URLSessionDelegate {
    let googleUrl = "https://www.googleapis.com/books/v1/volumes"
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
    }()
    var task:URLSessionTask?
    func getBook(with barcode:String, completionHandler: @escaping (Book?, Error?) -> Void) {
        
        //generate url
        guard var components = URLComponents(string: googleUrl) else {return}
        components.queryItems = [URLQueryItem(name: "q", value: barcode)]
        guard let url = components.url else {return}
        //generate request
        let request = URLRequest(url: url)
        
        task = session.dataTask(with: request) { (data, response, error) in
            if let error=error {
                completionHandler(nil, error)
            }
            guard let data = data else { return }
            self.parseSwiftyJSON(data: data, barcode:barcode, completionHandler: completionHandler)
        }
        task?.resume()
        
    }
    func cancel() {
        task?.cancel()
    }
    //Parsing with JSONSerialization - replaced with SwiftyJSON method
    private func parseJSON(data:Data, completionHandler: @escaping (Book?, Error?) -> Void) {
      do {
        if let dataAsJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any],
          let items = dataAsJSON["items"] as? [Any],
          let volume = items[0] as? [String:Any],
          let volumeInfo = volume["volumeInfo"] as? [String:Any],
          let title = volumeInfo["title"] as? String,
          let authors = volumeInfo["authors"] as? [String] {
          let book = Book(title: title,
                          author: authors.joined(separator: ","),
                          rating: 0, isbn: "0", notes: "")
          completionHandler(book,nil)
        } else {
          completionHandler(nil, nil)
        }
      } catch let error as NSError {
        completionHandler(nil, error)
        return
      }
    }
    //Parsing with SwiftyJSON
    private func parseSwiftyJSON(data:Data, barcode:String, completionHandler: @escaping (Book?, Error?) -> Void) {
        do {
            let dataAsJSON = try JSON(data: data)
            //loop through items (books)
            for item in dataAsJSON["items"].arrayValue {
                //loop through industry identifiers
                for id in item["volumeInfo"]["industryIdentifiers"].arrayValue {
                    //check id is the ISBN we're looking for
                    if id["type"].string == "ISBN_13",
                        id["identifier"].string == barcode,
                        let title = item["volumeInfo"]["title"].string,
                        let authors = item["volumeInfo"]["authors"].array?.map({$0.string}) as? [String],
                        let thumbnailURL = item["volumeInfo"]["imageLinks"]["thumbnail"].string {
                        let book = Book(title: title,
                                        author: authors.joined(separator: ","),
                                        rating: 0, isbn: "0", notes: "")
                        loadCover(book: book,
                                  thumbnailURL: thumbnailURL,
                                  completionHandler: completionHandler)
                        return
                    }
                }
            }
            completionHandler(nil, nil)
        } catch let error as NSError {
            completionHandler(nil, error)
            return
        }
    }
    //Download book cover image
    func loadCover(book:Book,thumbnailURL:String, completionHandler: @escaping (Book?, Error?) -> Void) {
        var book = book
        guard let url = URL(string: thumbnailURL) else {return}
        task = session.downloadTask(with: url) { (tempURL, response, error) in
            if let tempURL = tempURL,
                let data = try? Data(contentsOf: tempURL),
                let image = UIImage(data: data) {
                book.cover = image
            }
            completionHandler(book,error)
        }
        task?.resume()
    }
}

