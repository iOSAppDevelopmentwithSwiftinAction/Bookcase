//
//  ViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 10/05/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit

protocol BookViewControllerDelegate {
    func saveBook(book:Book)
}

class BookViewController: UIViewController {

    @IBOutlet weak var bookCover: UIImageView!
    @IBOutlet weak var isbnStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var outerStackView: UIStackView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var isbnTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var delegate:BookViewControllerDelegate?
    var book:Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(toggleISBN), for: .touchUpInside)
        bookCover.addSubview(infoButton)
        
        if let book = book {
            navigationItem.title = "Edit book"
            bookCover.image = book.cover
            titleTextField.text = book.title
            authorTextField.text = book.author
            isbnTextField.text = book.isbn
            notesTextView.text = book.notes
        }
        saveButton.isEnabled = !titleTextField.text!.isEmpty
    }

    @IBAction func titleDidChange(_ sender: AnyObject) {
        saveButton.isEnabled = !titleTextField.text!.isEmpty
    }
    
    func toggleISBN() {
        UIView.animate(withDuration: 0.5, animations: {
            self.isbnStackView.isHidden = !self.isbnStackView.isHidden
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanges), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
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

        let offset = self.view.frame.height - keyboardFrame.origin.y
        
        scrollView.contentInset.bottom = offset
        scrollView.scrollIndicatorInsets.bottom = offset
        
        if let textView = firstResponder as? UITextView,
            let textViewSuperview = textView.superview  {
            let textViewFrame = outerStackView.convert(textView.frame, from: textViewSuperview)
            scrollView.scrollRectToVisible(textViewFrame, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func touchCancel(_ sender: AnyObject) {
        dismissMe()
    }
    @IBAction func touchSave(_ sender: AnyObject) {
        let bookToSave = Book(title: titleTextField.text!,
                              author: authorTextField.text!,
                              rating: 3,
                              isbn: isbnTextField.text!,
                              notes: notesTextView.text!
        )
        delegate?.saveBook(book: bookToSave)
        dismissMe()
    }
    func dismissMe() {
        if presentingViewController != nil {
            //was presented via modal segue
            dismiss(animated: true, completion: nil)
        } else {
            //was pushed onto navigation stack
            navigationController!.popViewController(animated: true)
        }
    }
}
extension BookViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
