//
//  AddressViewController.swift
//  Find It
//
//  Created by Camden Madina on 3/14/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase

class AddressViewController: UIViewController,UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK:- IBOutlets for class
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var cityTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stateTextFieldBottomConstraint: NSLayoutConstraint!
    
    // MARK:- Loading method calls
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup up text fields
        setupTextFields()
        
        // 2. Setup up recognizers
        setupRecognizers()
        
        // 3. Setup up button
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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK:- IBActions for class
    @IBAction func finishButtonPressed(_ sender: Any) {
        
        // 1. Create local variables for each input entered
        let address = addressTextField.text
        let city = cityTextField.text
        let state = stateTextField.text
        
        // 2. Update user with these values
        DataService.dataService.CURRENT_USER_REF.child("address").setValue(address)
        DataService.dataService.CURRENT_USER_REF.child("city").setValue(city)
        DataService.dataService.CURRENT_USER_REF.child("state").setValue(state)
        
        // 3. Create additional user values for later
        DataService.dataService.CURRENT_USER_REF.child("hasTags").setValue(false)
        DataService.dataService.CURRENT_USER_REF.child("isFirstTime").setValue(true)
        DataService.dataService.CURRENT_USER_REF.child("items").setValue(nil)
        DataService.dataService.CURRENT_USER_REF.child("reports").setValue(nil)
        DataService.dataService.CURRENT_USER_REF.child("uid").setValue(UserDefaults.standard.value(forKey: "uid") as! String)

        // 4. Go to next screen
        performSegue(withIdentifier: "RegistrationCompleteSegue", sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        // 1. Return to previous screen
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK:- Text Field Delegate Methods
    func setupTextFields(){
        
        // 1. Assign the text field delegates
        self.addressTextField.delegate = self
        self.cityTextField.delegate = self
        self.stateTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 1. If a user presses enter, focus will go to next text field
        if textField == addressTextField{
            cityTextField.becomeFirstResponder()
        }else if textField == cityTextField{
            stateTextField.becomeFirstResponder()
        }else{
            stateTextField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // 1. Disable the next button if BOTH textfields are empty
        if addressTextField.text?.isEmpty == true || cityTextField.text?.isEmpty == true || stateTextField.text?.isEmpty == true {
            self.finishButton.setTitleColor(UIColor.white, for: .disabled)
            self.finishButton.backgroundColor = UIColor.clear
            self.finishButton.isEnabled = false
            
            self.finishButton.layer.cornerRadius = self.finishButton.frame.height / 2
            self.finishButton.clipsToBounds = true
            self.finishButton.layer.masksToBounds = true
            self.finishButton.layer.borderWidth = 2
            self.finishButton.layer.borderColor = UIColor.white.cgColor
        }else{
            
            // 2. If text fields are filled out, then enable the button and change the color
            self.finishButton.backgroundColor = UIColor.white
            self.finishButton.setTitleColor(kColorFF7D7D, for: .normal)
            self.finishButton.isEnabled = true
            
            self.finishButton.layer.cornerRadius = self.finishButton.frame.height / 2
            self.finishButton.clipsToBounds = true
            self.finishButton.layer.masksToBounds = true
            self.finishButton.layer.borderWidth = 2
            self.finishButton.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func setupRecognizers(){
        
        // 1. Create a tag screen regonizer
        let screenTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddressViewController.screenTapped))
        self.view.addGestureRecognizer(screenTapRecognizer)
    }
    
    //Methods for keyboards
    func initializeKeyboardNotifications(){
        
        // 1. Add notification obeservers that will alert app when keyboard displays
        NotificationCenter.default.addObserver(self, selector: #selector(AddressViewController.keyboardWillShow(notification :)), name:NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(AddressViewController.keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    func keyboardWillShow(notification: Notification) {
        
        // 1. Check that notification dictionary is available
        if let userInfo = notification.userInfo{
            
            // 2. Obtain keyboard size and predictive search height
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let offset = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                
                if self.stateTextField.frame.maxY > (self.view.frame.height - keyboardSize.height){
                    // 3. Animate the text fields up
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        // If no predictive search is displayed
                        if keyboardSize.height == offset.height{
                            self.stateTextFieldBottomConstraint.constant = (keyboardSize.height) - (self.view.frame.height - self.finishButton.frame.origin.y) + 15
                            self.cityTextFieldBottomConstraint.constant = (keyboardSize.height) - (self.view.frame.height - self.finishButton.frame.origin.y) + 15
                        }else{
                            self.stateTextFieldBottomConstraint.constant = (keyboardSize.height + offset.height) - (self.view.frame.height - self.finishButton.frame.origin.y) + 15
                            self.cityTextFieldBottomConstraint.constant = (keyboardSize.height + offset.height) - (self.view.frame.height - self.finishButton.frame.origin.y) + 15
                        }
                    })
                }
            }
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.cityTextFieldBottomConstraint.constant = 128
            self.stateTextFieldBottomConstraint.constant = 128
        }
    }
    
    // MARK:- Utilities for class
    
    func screenTapped(){
        
        // 1. If screen is tapped, resign keyboard for all text fields
        self.addressTextField.resignFirstResponder()
        self.cityTextField.resignFirstResponder()
        self.stateTextField.resignFirstResponder()
    }
    
    func setupButton(){
        
        // 1. Set the button to gray  by default and disable
        self.finishButton.setTitleColor(UIColor.white, for: .disabled)
        self.finishButton.backgroundColor = UIColor.clear
        self.finishButton.isEnabled = false
        self.finishButton.layer.borderWidth = 2
        self.finishButton.layer.borderColor = UIColor.white.cgColor
    }
    
    // MARK:- Utilities for class
    func setupUI(){
        
        // 1. Add a radius to button to make it round
        self.finishButton.layer.cornerRadius = self.finishButton.frame.size.height / 2
        self.finishButton.clipsToBounds = true
        self.finishButton.layer.masksToBounds = true
    }
}
