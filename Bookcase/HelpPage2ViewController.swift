//
//  HelpPage2ViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 3/11/16.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit

class HelpPage2ViewController: UIViewController {
    
    lazy var parts:[UIView] = {
        return [InstructionFactory.image(named:"onboardingCross.png"),
                InstructionFactory.heading(text: "Add a book"),
                InstructionFactory.body(text: "Add the books in your bookcase to the Bookcase app. Add the title, author, notes, and take photos of the cover art of your books.", width: self.view.frame.width),
                ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ContentLayoutMachine.verticalLayout(to: view, views: parts)
    }
}
