//
//  InstructionFactory.swift
//  Bookcase
//
//  Created by Craig Grummitt on 3/11/16.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit
struct InstructionFactory {
    static func heading(text:String)->UILabel {
        let view = UILabel()
        view.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
        view.textColor = UIColor.white
        view.textAlignment = .center
        view.text = text
        view.numberOfLines = 1
        view.sizeToFit()
        return view
    }
    static func body(text:String,width:CGFloat)->UILabel {
        let view = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        view.textColor = UIColor.white
        view.textAlignment = .center
        view.text = text
        view.numberOfLines = 0
        return view
    }
    static func image(named name:String)->UIImageView {
        guard let image = UIImage(named: name) else {return UIImageView()}
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        view.contentMode = .scaleAspectFit
        view.image = image
        view.layer.masksToBounds = false;
        view.layer.shadowOffset = CGSize(width:-15, height:20);
        view.layer.shadowRadius = 5;
        view.layer.shadowOpacity = 0.3;
        return view
    }
}
