//
//  HelpPage3ViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 3/11/16.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit

class HelpPage3ViewController: UIViewController {
    lazy var parts:[UIView] = {
        return [InstructionFactory.image(named:"onboardingBarcode.png"),
                InstructionFactory.heading(text: "Scan the book barcode"),
                InstructionFactory.body(text: "Scan your book's barcode to automatically extract the title, author, ISBN and cover art of your book!", width: self.view.frame.width),
                ]
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        ContentLayoutMachine.verticalLayout(to: view, views: parts)
    }
}
