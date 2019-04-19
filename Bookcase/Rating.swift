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
        didSet {setNeedsLayout()}
    }
    var stars:[Star] = []
    
    let numberOfStars = 5

    override func layoutSubviews() {
        self.backgroundColor = UIColor.clear
        if stars.count == 0 {
            //add stars
            for i in 0..<numberOfStars {
                let star = Star(frame: CGRect(x: CGFloat(30 * i), y: 0, width: 25, height: 25))
                star.backgroundColor = UIColor.clear
                self.addSubview(star)
                stars.append(star)
            }
        }
        for (i,star) in stars.enumerated() {
            star.fill = Double(i)<rating
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        guard let star = touch.view as? Star else {return}
        guard let starIndex = stars.firstIndex(of: star) else {return}
        rating = Double(starIndex) + 1
    }
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 30 * numberOfStars, height: 25)
    }
}
