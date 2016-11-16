//
//  UIImageColorDetectionTests.swift
//  Bookcase
//
//  Created by Craig Grummitt on 14/11/16.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import XCTest
import UIImageColors
class UIImageColorDetectionTests: XCTestCase {
    
    var image:UIImage!
    
    override func setUp() {
        super.setUp()
        image = UIImage(named: "book")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func testColorDetection() {
        self.measure {
            _ = self.image.getColors()
        }
    }
}
