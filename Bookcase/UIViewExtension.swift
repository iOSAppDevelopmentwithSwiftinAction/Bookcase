//
//  UIView+FirstResponder.swift
//  Bookcase
//
//  Created by Craig Grummitt on 13/07/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit
extension UIView {
    var firstResponder:UIView? {
        if self.isFirstResponder {
            return self
        }
        for view in self.subviews {
            if let firstResponder = view.firstResponder {
                return firstResponder
            }
        }
        return nil
    }
}
extension UIViewController {
    var firstResponder:UIView? {
        return view.firstResponder
    }
}
