//
//  TabBarController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 4/4/17.
//  Copyright © 2017 Craig Grummitt. All rights reserved.
//

import UIKit

protocol Injectable {
  func inject(data: BooksManager)
}


class TabBarController: UITabBarController {
  var booksManager = BooksManager()
  override func viewDidLoad() {
    super.viewDidLoad()
    for navController in viewControllers! {
      if let navController = navController as? UINavigationController,
        let viewController = navController.viewControllers.first as? Injectable {
        viewController.inject(data: booksManager)
      }
    }
  }
}
