//
//  ViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 10/05/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit

class BookViewController: UIViewController {

    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var isbnStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(toggleISBN), for: .touchUpInside)
        bookCover.addSubview(infoButton)
    }
    @objc func toggleISBN() {
        UIView.animate(withDuration: 0.5, animations: {
            self.isbnStackView.isHidden = !self.isbnStackView.isHidden
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

