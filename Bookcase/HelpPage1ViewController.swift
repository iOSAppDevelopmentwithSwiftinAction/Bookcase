//
//  HelpPage1ViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 3/11/16.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit

class HelpPage1ViewController: UIViewController {
    lazy var parts:[UIView] = {
        return [InstructionFactory.image(named:"onboardingBook.png"),
                InstructionFactory.heading(text: "Keep track of your books"),
                InstructionFactory.body(text: "Use the Bookcase app to keep a record of the books in your actual bookcase!", width: self.view.frame.width),
                ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ContentLayoutMachine.verticalLayout(to: view, views: parts)
    }
}
