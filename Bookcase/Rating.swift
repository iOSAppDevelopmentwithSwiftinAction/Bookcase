//
//  Rating.swift
//  Stars
//
//  Created by Craig Grummitt on 4/10/16.
//  Copyright © 2016 interactivecoconut. All rights reserved.
//

import UIKit
@IBDesignable class Rating: UIView {
    @IBInspectable var rating:Double = 3 {
        didSet {setNeedsDisplay()}
    }
    @IBInspectable var numberOfStars:Int = 5 {
        didSet {setNeedsDisplay()}
    }
    
    var stars:[Star] = []
    
    override func draw(_ rect: CGRect) {
        //remove all views
        stars.forEach { $0.removeFromSuperview() }
        stars = []
        //add stars
        for i in 0..<numberOfStars {
            let star = Star(frame: CGRect(x: CGFloat(30 * i), y: 0, width: 25, height: 25))
            star.fill = Double(i)<rating
            star.backgroundColor = UIColor.clear
            self.addSubview(star)
            stars.append(star)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        guard let star = touch.view as? Star else {return}
        guard let starIndex = stars.index(of: star) else {return}
        rating = Double(starIndex) + 1
    }
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 30 * numberOfStars, height: 25)
    }
}
