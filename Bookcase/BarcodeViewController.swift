//
//  BarcodeViewController.swift
//  BookCase
//
//  Created by Craig Grummitt on 6/05/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit
import AVFoundation

protocol BarcodeViewControllerDelegate {
    func foundBarcode(barcode:String)
}

class BarcodeViewController: UIViewController {
    var delegate:BarcodeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func touchCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
}
