//
//  PhoneViewController.swift
//  Find It
//
//  Created by Camden Madina on 4/10/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit

class PhoneViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Setup text fields
        setupTextFields()
        
        // 2. Setup recognizer
        setupRecognizers()
        
        // 3. Setup next button
        setupButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // 1. Disable the next button if BOTH textfields are empty
        if phoneTextField.text?.isEmpty == true {
            nextButton.setTitleColor(UIColor(red:0.64, green:0.64, blue:0.64, alpha:1.0), for: .disabled)
            nextButton.backgroundColor = UIColor(red:0.80, green:0.82, blue:0.82, alpha:1.0)
            nextButton.isEnabled = false
        }else{
            
            // 2. If text fields are filled out, then enable the button and change the color
            nextButton.backgroundColor = UIColor(red: 88.0/255.0, green: 163.0/255.0, blue: 232.0/255.0, alpha: 1.0)
            nextButton.setTitleColor(UIColor.white, for: .normal)
            nextButton.isEnabled = true
        }
    }
    
    func setupRecognizers(){
        
        // 1. Create a tag screen regonizer
        let screenTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhoneViewController.screenTapped))
        self.view.addGestureRecognizer(screenTapRecognizer)
    }
    
    // MARK:- Utilities for class
    
    func screenTapped(){
        
        // 1. If screen is tapped, resign keyboard for all text fields
        self.phoneTextField.resignFirstResponder()
    }
    
    func setupButton(){
        
        // 1. Set the button to gray  by default and disable
        nextButton.setTitleColor(UIColor(red:0.64, green:0.64, blue:0.64, alpha:1.0), for: .disabled)
        nextButton.backgroundColor = UIColor(red:0.80, green:0.82, blue:0.82, alpha:1.0)
        nextButton.isEnabled = false
    }
}
