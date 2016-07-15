//
//  ViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 10/05/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var book: UIImageView!
    @IBOutlet weak var isbnStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var outerStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        book.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func handleTap(sender:UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, animations: {
            self.isbnStackView.isHidden = !self.isbnStackView.isHidden
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default().addObserver(self, selector: #selector(keyboardFrameChanges), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default().removeObserver(self)
    }
    func keyboardFrameChanges(notification:Notification) {
        //get keyboard height
        guard let userInfo = notification.userInfo,
            var keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey]
                as? NSValue)?.cgRectValue()
            else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        let offset = self.view.frame.height - keyboardFrame.origin.y
        
        scrollView.contentInset.bottom = offset
        scrollView.scrollIndicatorInsets.bottom = offset
        
        if let textView = firstResponder as? UITextView,
            textViewSuperview = textView.superview  {
            let textViewFrame = outerStackView.convert(textView.frame, from: textViewSuperview)
            scrollView.scrollRectToVisible(textViewFrame, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
