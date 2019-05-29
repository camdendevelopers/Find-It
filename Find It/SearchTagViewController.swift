//
//  SearchTagViewController.swift
//  Find It
//
//  Created by Camden Madina on 4/6/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase

class SearchTagViewController: UIViewController, UITextFieldDelegate {
    
    // IBOutlets for class
    @IBOutlet weak var itemSearchTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var itemSearchTextFieldBottomConstraint: NSLayoutConstraint!
    
    // Variables for class
    var itemInfo: NSDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup text fields
        setupTextFields()
        
        // 2. Setup recognizers
        setupRecognizers()
        
        // 3. Setup bars and buttons
        setupBars()
        
        // 4. Setup button
        setupButton()
        
        // 5. Initiliaze keyboard size functionality
        initializeKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1. Change status bar color to white for this screen only
        UIApplication.shared.statusBarStyle = .lightContent
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        // 1. Return to previous screen
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        
        // 1. Create local variable from text field
        let itemIdentification = itemSearchTextField.text
        
        // 2. Check that text field is not empty and that it is the correct lenght
        guard itemIdentification != "", (itemIdentification?.count)! == 6 else{
            present(Utilities.showErrorAlert(inDict: ["title": "Ooops", "message": "You need to enter a valid ID"]), animated: true, completion: nil)
            return
        }
        
        // 3. Create a reference to search the database
        let itemsQuery = DataService.dataService.ITEM_REF.queryOrdered(byChild: "id").queryEqual(toValue: itemIdentification!)
        
        // 4. Search for item from tag
        itemsQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Extract the data from the retrieved snapshot
            if let result = snapshot.value as? NSDictionary {
                
                // Get all items from the array
                if let items = result.allValues as? [NSDictionary]{
                    
                    // Assign the item info found to the iteminfo found
                    self.itemInfo = items[0]
                    self.performSegue(withIdentifier: "ConfirmReportSegue", sender: self)
                }
            }else{
                
                // Present if no tag was found
                self.present(Utilities.showErrorAlert(inDict: ["title": "Could Not Find Tag", "message": "Couldn't find a match. Try again?"]), animated: true, completion: nil)
            }
        })
    }
    
    //Methods for keyboards
    func initializeKeyboardNotifications(){
        
        // 1. Add notification obeservers that will alert app when keyboard displays
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        // 1. Check that notification dictionary is available
        if let userInfo = notification.userInfo{
            
            // 2. Obtain keyboard size and predictive search height
            if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let offset = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                
                if self.itemSearchTextField.frame.maxY > (self.view.frame.height - keyboardSize.height){
                    // 3. Animate the text fields up
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        // If no predictive search is displayed
                        if keyboardSize.height == offset.height{
                            self.itemSearchTextFieldBottomConstraint.constant = (keyboardSize.height) - (self.view.frame.height - self.nextButton.frame.origin.y) + 15
                        }else{
                            self.itemSearchTextFieldBottomConstraint.constant = (keyboardSize.height + offset.height) - (self.view.frame.height - self.nextButton.frame.origin.y) + 15
                        }
                    })
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.itemSearchTextFieldBottomConstraint.constant = 198
        }
    }
    
    // MARK:- Text Field Delegate
    
    func setupBars(){
        self.view.backgroundColor = kColorE3CC00
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
                navigationController?.navigationBar.barTintColor = kColorE3CC00
        navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue: UIFont(name: "HalisR-Black", size: 16)!, NSAttributedString.Key.foregroundColor.rawValue: UIColor.white])
        
    }
    
    func setupTextFields(){
        // 1. Set the delegates of the text fields
        self.itemSearchTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 1. If you are at top text field and hit enter, go to the next one
        if textField == itemSearchTextField{
            itemSearchTextField.resignFirstResponder()
            self.nextButtonPressed(self)
        }
        return true
    }
    
    // MARK:- Utilities for class
    func setupButton(){
        
        // 1. Add a radius to button to make it round
        self.nextButton.layer.cornerRadius = self.nextButton.frame.size.height / 2
        self.nextButton.clipsToBounds = true
        self.nextButton.layer.masksToBounds = true
    }
    
    func setupRecognizers(){
        
        // 1. Create a tag screen regonizer
        let screenTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        self.view.addGestureRecognizer(screenTapRecognizer)
    }
    
    @objc func screenTapped(){
        
        // 1. If screen is tapped, resign keyboard for all text fields
        self.itemSearchTextField.resignFirstResponder()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConfirmReportSegue"{
            if let destinationViewController = segue.destination as? ConfirmReportViewController{
                destinationViewController.itemInfo = self.itemInfo!
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
