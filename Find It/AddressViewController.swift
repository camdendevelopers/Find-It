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
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var finishButton: UIButton!
    
    private var currentUserID:String?
    private var currentUser: FIRDatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup up text fields
        setupTextFields()
        
        // 2. Setup up recognizers
        setupRecognizers()
        
        // 3. Setup up button
        setupButton()
        
        // 4. Load users
        loadUser()
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        
        let address = addressTextField.text
        let city = cityTextField.text
        let state = stateTextField.text
        
        currentUser?.child("address").setValue(address)
        currentUser?.child("city").setValue(city)
        currentUser?.child("state").setValue(state)
        currentUser?.child("hasTags").setValue(true)
        currentUser?.child("isFirstTime").setValue(false)
        currentUser?.child("items").setValue(nil)
        
        performSegue(withIdentifier: "RegistrationCompleteSegue", sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK:- Text Field Delegate Methods
    func setupTextFields(){
        self.addressTextField.delegate = self
        self.cityTextField.delegate = self
        self.stateTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
        
        // Disable the next button if BOTH textfields are empty
        if addressTextField.text?.isEmpty == true || cityTextField.text?.isEmpty == true || stateTextField.text?.isEmpty == true {
            finishButton.setTitleColor(UIColor(red:0.64, green:0.64, blue:0.64, alpha:1.0), for: .disabled)
            finishButton.backgroundColor = UIColor(red:0.80, green:0.82, blue:0.82, alpha:1.0)
            finishButton.isEnabled = false
        }else{
            finishButton.backgroundColor = UIColor(red: 88.0/255.0, green: 163.0/255.0, blue: 232.0/255.0, alpha: 1.0)
            finishButton.setTitleColor(UIColor.white, for: .normal)
            finishButton.isEnabled = true
        }
    }
    
    func setupRecognizers(){
        let screenTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddressViewController.screenTapped))
        self.view.addGestureRecognizer(screenTapRecognizer)
    }
    
    // MARK:- Utilities for class
    func loadUser(){
        guard Reachability.isConnectedToNetwork() else{
            print("Not connected to internet")
            return
        }
        
        self.currentUserID = DataService.dataService.AUTH_REF.currentUser?.uid
        self.currentUser = DataService.dataService.USER_REF.child(currentUserID!)
    }
    
    func screenTapped(){
        addressTextField.resignFirstResponder()
        cityTextField.resignFirstResponder()
        stateTextField.resignFirstResponder()
    }
    
    func setupButton(){
        // 1. Set the button to gray  by default and disable
        finishButton.setTitleColor(UIColor(red:0.64, green:0.64, blue:0.64, alpha:1.0), for: .disabled)
        finishButton.backgroundColor = UIColor(red:0.80, green:0.82, blue:0.82, alpha:1.0)
        finishButton.isEnabled = false
    }
}
