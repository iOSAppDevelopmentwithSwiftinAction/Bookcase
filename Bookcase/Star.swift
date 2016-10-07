//
//  Star.swift
//  Stars
//
//  Created by Craig Grummitt on 4/10/16.
//  Copyright © 2016 interactivecoconut. All rights reserved.
//

import UIKit
@IBDesignable class Star: UIView {
    @IBInspectable var fill:Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    let star = CAShapeLayer()
    override func draw(_ rect: CGRect) {
        star.path = getStarPath().cgPath
        if fill {
            star.fillColor = UIColor.orange.cgColor
        } else {
            star.fillColor = UIColor.clear.cgColor
            star.strokeColor = UIColor.orange.cgColor
        }
        self.layer.addSublayer(star)
    }
    func getStarPath()->UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 12, y: 1.2))
        path.addLine(to: CGPoint(x: 15.4, y: 8.4))
        path.addLine(to: CGPoint(x: 23, y: 9.6))
        path.addLine(to: CGPoint(x: 17.5, y: 15.2))
        path.addLine(to: CGPoint(x: 18.8, y: 23.2))
        path.addLine(to: CGPoint(x: 12, y: 19.4))
        path.addLine(to: CGPoint(x: 5.2, y: 23.2))
        path.addLine(to: CGPoint(x: 6.5, y: 15.2))
        path.addLine(to: CGPoint(x: 1, y: 9.6))
        path.addLine(to: CGPoint(x: 8.6, y: 8.4))
        path.close()
        return path
    }
}
