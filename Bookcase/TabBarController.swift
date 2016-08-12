//
//  TabBarController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 12/08/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit

protocol Injectable {
    func inject(data:BooksManager)
}

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    var booksManager = BooksManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        if let navController = viewControllers?.first as? UINavigationController,
            let viewController = navController.viewControllers.first as? Injectable {
            viewController.inject(data: booksManager)
        }
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let navController = viewController as? UINavigationController,
           let viewController = navController.viewControllers.first as? Injectable {
            viewController.inject(data: booksManager)
        }
        return true
    }
}
