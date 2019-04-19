//
//  ViewController.swift
//  Bookcase
//
//  Created by Craig Grummitt on 10/05/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit
import AVFoundation
import UIImageColors

protocol BookViewControllerDelegate {
  func saveBook(_ book:Book)
}

private let isbnKey = "ISBN"

class BookViewController: UIViewController {
  
  @IBOutlet weak var bookCover: UIImageView!
  @IBOutlet weak var isbnStackView: UIStackView!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var outerStackView: UIStackView!
  
  @IBOutlet weak var starRatings: Rating!
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var authorTextField: UITextField!
  @IBOutlet weak var isbnTextField: UITextField!
  @IBOutlet weak var notesTextView: UITextView!
  @IBOutlet weak var saveButton: UIBarButtonItem!
  @IBOutlet weak var cameraButton: UIBarButtonItem!
  @IBOutlet weak var galleryButton: UIBarButtonItem!
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var authorLabel: UILabel!
  @IBOutlet weak var isbnLabel: UILabel!
  @IBOutlet weak var notesLabel: UILabel!
  
  var delegate:BookViewControllerDelegate?
  var book:Book?
  var coverToSave:UIImage?
  var barcodeAudio: AVAudioPlayer!
  var detailColor:UIColor?
  var booksService:BooksService = GoogleBooksService()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let infoButton = UIButton(type: .infoLight)
    infoButton.addTarget(self, action: #selector(toggleISBN), for: .touchUpInside)
    bookCover.addSubview(infoButton)
    
    if let book = book {
      navigationItem.title = "Edit book"
      bookCover.image = book.cover
      if book.hasCoverImage {
        coverToSave = book.cover
      }
      starRatings.rating = book.rating
      titleTextField.text = book.title
      authorTextField.text = book.author
      isbnTextField.text = book.isbn
      notesTextView.text = book.notes
      drawColorsToView(backgroundColor: book.backgroundColor, primaryColor: book.primaryColor)
    }
    saveButton.isEnabled = !titleTextField.text!.isEmpty
    isbnStackView.isHidden = UserDefaults.standard.bool(forKey: isbnKey)
    if !UIImagePickerController.isSourceTypeAvailable(.camera) {
      cameraButton.isEnabled = false
    }
  }
  
  
  @IBAction func titleDidChange(_ sender: AnyObject) {
    saveButton.isEnabled = !titleTextField.text!.isEmpty
  }
  
  @objc func toggleISBN() {
    UIView.animate(withDuration: 0.5, animations: {
      self.isbnStackView.isHidden = !self.isbnStackView.isHidden
    })
    UserDefaults.standard.set(isbnStackView.isHidden, forKey: isbnKey)
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanges), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
  }
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    NotificationCenter.default.removeObserver(self)
    booksService.cancel()
  }
  @objc func keyboardFrameChanges(notification:Notification) {
    //get keyboard height
    guard let userInfo = notification.userInfo,
      var keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]
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
  //MARK:Actions
  @IBAction func touchCancel(_ sender: AnyObject) {
    dismissMe()
  }
  @IBAction func touchSave(_ sender: AnyObject) {
    var backgroundColor = UIColor.white
    var primaryColor = UIColor.black
    var detailColor = UIColor.black
    if let book = book {
      backgroundColor = book.backgroundColor
      primaryColor = book.primaryColor
      detailColor = book.detailColor
    }
    let bookToSave = Book(title: titleTextField.text!,
                          author: authorTextField.text!,
                          rating: starRatings.rating,
                          isbn: isbnTextField.text!,
                          notes: notesTextView.text!,
                          cover: coverToSave,
                          backgroundColor: backgroundColor,
                          primaryColor: primaryColor,
                          detailColor: detailColor
    )
    delegate?.saveBook(bookToSave)
    dismissMe()
  }
  @IBAction func takePhoto(_ sender: AnyObject) {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .camera
    present(imagePicker, animated: true, completion: nil)
    
    imagePicker.delegate = self
  }
  @IBAction func getPhotoFromLibrary(_ sender: AnyObject) {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = .photoLibrary
    
    //Display in popover
    imagePicker.modalPresentationStyle = .popover
    imagePicker.popoverPresentationController?.barButtonItem = galleryButton
    
    present(imagePicker, animated: true, completion: nil)
    
    imagePicker.delegate = self
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
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let navigationController = segue.destination as? UINavigationController,
      let barcodeViewController = navigationController.topViewController as? BarcodeViewController {
      barcodeViewController.delegate = self
    }
  }
  //MARK:Colors
  func receiveColors(colors:UIImageColors?) {
    let colors = colors ?? UIImageColors(background: .white, primary: .black, secondary: .black, detail: .black)
    detailColor = colors.detail
    book?.detailColor = colors.detail
    book?.primaryColor = colors.primary
    book?.backgroundColor = colors.background
    drawColorsToView(backgroundColor: colors.background, primaryColor: colors.primary)
  }
  func drawColorsToView(backgroundColor:UIColor,primaryColor:UIColor) {
    UIView.animate(withDuration: 1) {
      self.view.backgroundColor = backgroundColor
      self.titleLabel.textColor = primaryColor
      self.authorLabel.textColor = primaryColor
      self.isbnLabel.textColor = primaryColor
      self.notesLabel.textColor = primaryColor
      self.notesTextView.textColor = primaryColor
    }
  }
  //MARK:Image
  func receiveImage(image:UIImage) {
    bookCover.image = image
    coverToSave = image
    DispatchQueue.global().async {
      let colors = image.getColors()
      DispatchQueue.main.async {
        self.receiveColors(colors:colors)
      }
    }
  }
  //MARK:Sound
  func playBarcodeSound() {
    guard let url = Bundle.main.url(forResource: "scanner", withExtension:"aiff") else {return}
    //play Sound
    barcodeAudio = try? AVAudioPlayer(contentsOf: url)
    barcodeAudio?.play()
  }
}
extension BookViewController:UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
extension BookViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    dismiss(animated: true, completion: nil)
    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      receiveImage(image: image)
    }
  }
  func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
    return UIInterfaceOrientation.landscapeLeft
  }
}
extension BookViewController:BarcodeViewControllerDelegate {
  func foundBarcode(barcode:String) {
    isbnTextField.text = barcode
    playBarcodeSound()
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    booksService.getBook(with: barcode) { (scannedBook, error) in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      if error != nil {
        //deal with error
        return
      } else if let scannedBook = scannedBook {
        self.bookCover.image = scannedBook.cover
        self.coverToSave = scannedBook.cover
        self.titleTextField.text = scannedBook.title
        self.authorTextField.text = scannedBook.author
        self.saveButton.isEnabled = true
      } else {
        //deal with no error, no book!
      }
    }
  }
}
