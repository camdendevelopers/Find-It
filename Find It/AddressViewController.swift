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
    
    // IBOutlets for class
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var finishButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup up text fields
        setupTextFields()
        
        // 2. Setup up recognizers
        setupRecognizers()
        
        // 3. Setup up button
        setupButton()
    }
    
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
            finishButton.setTitleColor(UIColor(red:0.64, green:0.64, blue:0.64, alpha:1.0), for: .disabled)
            finishButton.backgroundColor = UIColor(red:0.80, green:0.82, blue:0.82, alpha:1.0)
            finishButton.isEnabled = false
        }else{
            
            // 2. If text fields are filled out, then enable the button and change the color
            finishButton.backgroundColor = UIColor(red: 88.0/255.0, green: 163.0/255.0, blue: 232.0/255.0, alpha: 1.0)
            finishButton.setTitleColor(UIColor.white, for: .normal)
            finishButton.isEnabled = true
        }
    }
    
    func setupRecognizers(){
        
        // 1. Create a tag screen regonizer
        let screenTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddressViewController.screenTapped))
        self.view.addGestureRecognizer(screenTapRecognizer)
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
        finishButton.setTitleColor(UIColor(red:0.64, green:0.64, blue:0.64, alpha:1.0), for: .disabled)
        finishButton.backgroundColor = UIColor(red:0.80, green:0.82, blue:0.82, alpha:1.0)
        finishButton.isEnabled = false
    }
}
