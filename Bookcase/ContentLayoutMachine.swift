//
//  ContentLayoutMachine.swift
//  Bookcase
//
//  Created by Craig Grummitt on 3/11/16.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit
struct ContentLayoutMachine {
    static let margin:CGFloat = 20
    static func verticalLayout(to rootView:UIView,views:[UIView]) {
        rootView.backgroundColor = appBlue
        var constraints:[NSLayoutConstraint] = []
        var previousView:UIView?
        var heightTally:CGFloat = 0
        for view in views {
            rootView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            if let previousView = previousView {
                constraints += [view.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: margin) ]
            }
            constraints += [view.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: margin),
                            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: margin)]
            heightTally += view.frame.height + margin
            previousView = view
        }
        let topMargin = (rootView.frame.height - heightTally - margin) / 2
        constraints += [views.first!.topAnchor.constraint(equalTo: rootView.topAnchor, constant: topMargin)]
        NSLayoutConstraint.activate(constraints)
        
    }
}

