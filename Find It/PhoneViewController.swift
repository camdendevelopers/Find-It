//
//  PhoneViewController.swift
//  Find It
//
//  Created by Camden Madina on 4/10/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit

class PhoneViewController: UIViewController, UITextFieldDelegate {
    
    // MARK:- IBOutlets for class
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var phoneTextFieldBottomConstraint: NSLayoutConstraint!
    
    // MARK:- Loading method calls
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Setup text fields
        setupTextFields()
        
        // 2. Setup recognizer
        setupRecognizers()
        
        // 3. Setup next button
        setupButton()
        
        // 4. Setup UI
        setupUI()
        
        // 5. Initiliaze keyboard size functionality
        initializeKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1. Change status bar color to white for this screen only
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 1. Change status bar color back to white when moving away from screen
        UIApplication.shared.statusBarStyle = .default
        
        // 2. Remove observers for keyboard
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK:- IBActions for class
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        // 1. Create local variables of text fields text
        let phone = phoneTextField.text
        
        // 2. Check if textfields are empty
        guard phone != "" else {
            present(Utilities.showErrorAlert(inDict: ["title": "Oops", "message": "You need to have details on all fields"]), animated: true, completion: nil)
            return
        }
        
        // 3. Update current user's values
        DataService.dataService.CURRENT_USER_REF.child("phone").setValue(phone)
        
        // 4. Go to next screen
        performSegue(withIdentifier: "ToAddressSegue", sender: self)
    }
    
    // MARK:- Text Field Delegate
    
    func setupTextFields(){
        // 1. Set the delegates of the text fields
        self.phoneTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 1. If you are at top text field and hit enter, go to the next one
        if textField == phoneTextField{
            phoneTextField.resignFirstResponder()
            self.nextButtonPressed(self)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // 1. Disable the next button if BOTH textfields are empty
        if phoneTextField.text?.isEmpty == true {
            // 1. Set the button to gray  by default and disable
            self.nextButton.setTitleColor(UIColor.white, for: .disabled)
            self.nextButton.backgroundColor = UIColor.clear
            self.nextButton.isEnabled = false
            
            self.nextButton.layer.cornerRadius = self.nextButton.frame.height / 2
            self.nextButton.clipsToBounds = true
            self.nextButton.layer.masksToBounds = true
            self.nextButton.layer.borderWidth = 2
            self.nextButton.layer.borderColor = UIColor.white.cgColor
        }else{
            
            // 2. If text fields are filled out, then enable the button and change the color
            self.nextButton.backgroundColor = UIColor.white
            self.nextButton.setTitleColor(kColorFF7D7D, for: .normal)
            self.nextButton.isEnabled = true
            
            self.nextButton.layer.cornerRadius = self.nextButton.frame.height / 2
            self.nextButton.clipsToBounds = true
            self.nextButton.layer.masksToBounds = true
            self.nextButton.layer.borderWidth = 2
            self.nextButton.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func setupRecognizers(){
        
        // 1. Create a tag screen regonizer
        let screenTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhoneViewController.screenTapped))
        self.view.addGestureRecognizer(screenTapRecognizer)
    }
    
    //Methods for keyboards
    func initializeKeyboardNotifications(){
        
        // 1. Add notification obeservers that will alert app when keyboard displays
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: view.window)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        // 1. Check that notification dictionary is available
        if let userInfo = notification.userInfo{
            
            // 2. Obtain keyboard size and predictive search height
            if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let offset = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                
                if self.phoneTextField.frame.maxY > (self.view.frame.height - keyboardSize.height){
                    // 3. Animate the text fields up
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        // If no predictive search is displayed
                        if keyboardSize.height == offset.height{
                            self.phoneTextFieldBottomConstraint.constant = (keyboardSize.height) - (self.view.frame.height - self.nextButton.frame.origin.y) + 15
                        }else{
                            self.phoneTextFieldBottomConstraint.constant = (keyboardSize.height + offset.height) - (self.view.frame.height - self.nextButton.frame.origin.y) + 15
                        }
                    })
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.phoneTextFieldBottomConstraint.constant = 204
        }
    }
    
    // MARK:- Utilities for class
    func setupUI(){
        
        // 1. Add a radius to button to make it round
        self.nextButton.layer.cornerRadius = self.nextButton.frame.size.height / 2
        self.nextButton.clipsToBounds = true
        self.nextButton.layer.masksToBounds = true
    }
    
    @objc func screenTapped() {
        
        // 1. If screen is tapped, resign keyboard for all text fields
        self.phoneTextField.resignFirstResponder()
    }
    
    func setupButton(){
        
        // 1. Set the button to gray  by default and disable
        self.nextButton.setTitleColor(UIColor.white, for: .disabled)
        self.nextButton.backgroundColor = UIColor.clear
        self.nextButton.isEnabled = false
        
        self.nextButton.layer.cornerRadius = self.nextButton.frame.height / 2
        self.nextButton.clipsToBounds = true
        self.nextButton.layer.masksToBounds = true
        self.nextButton.layer.borderWidth = 2
        self.nextButton.layer.borderColor = UIColor.white.cgColor
    }
}
