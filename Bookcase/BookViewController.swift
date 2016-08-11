//
//  ViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 10/05/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit

class BookViewController: UIViewController {

    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var isbnStackView: UIStackView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(toggleISBN), for: .touchUpInside)
        bookCover.addSubview(infoButton)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    func toggleISBN() {
        UIView.animate(withDuration: 0.5, animations: {
            self.isbnStackView.isHidden = !self.isbnStackView.isHidden
        })
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    func keyboardFrameChanges(notification:Notification) {
        //get keyboard height
        guard let userInfo = notification.userInfo,
            var keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey]
                as? NSValue)?.cgRectValue
            else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        guard let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double
            else { return }
        
        guard let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt
            else { return }
        
        
        //get active field frame
        var offset:CGFloat = 0
        if let firstResponder = firstResponder {
            let frFrame = self.view.convert(firstResponder.frame, from: firstResponder)
            let frMaxY = frFrame.maxY - topConstraint.constant + 5
            if frMaxY > keyboardFrame.origin.y {
                offset = frMaxY - keyboardFrame.origin.y
            }
        }
        

        
        //------------------------------------
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
    
}
extension BookViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
