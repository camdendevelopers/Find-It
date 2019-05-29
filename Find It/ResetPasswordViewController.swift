//
//  ResetPasswordViewController.swift
//  Find It
//
//  Created by Camden Madina on 5/13/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {
    
    // MARK:_ IBOutlets for class
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendResetPasswordEmailButton: UIButton!
    @IBOutlet weak var emailTextFieldBottomConstraint: NSLayoutConstraint!
    
    // MARK:- Variables for class
    var activityIndicator:NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Setup text fields
        setupTextFields()
        
        // 2. Setup UI
        setupUI()
        
        // 3. Initiliaze keyboard size functionality
        initializeKeyboardNotifications()
        
        // 4. Setup recognizers
        setupRecognizers()
        
        // 5. Setup activity indicator
        setupActivityIndicator()
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func sendResetPasswordEmailButtonPressed(_ sender: Any) {
        // 1. Start running activity indicator
        self.activityIndicator?.startAnimating()
        
        // 2. Create local variables of text fields text
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 3. Check if textfields are empty
        guard email != ""else {
            self.present(Utilities.showErrorAlert(inDict: EmptyTextFields), animated: true, completion: nil)
            return
        }
        
        // 4. Send request to send reset password link
        DataService.dataService.AUTH_REF.sendPasswordReset(withEmail: email!) { (error) in
            
            if let error = error{
                print(error.localizedDescription)
                self.activityIndicator?.stopAnimating()
                self.present(Utilities.showErrorAlert(inDict: AuthenticationError), animated: true, completion: nil)
            }else{
                self.activityIndicator?.stopAnimating()
                self.present(Utilities.showErrorAlert(inDict: ResetInstructionsSent), animated: true, completion: { 
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
    func setupTextFields(){
        // 1. Set the delegates of the text fields
        self.emailTextField.delegate = self
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.sendResetPasswordEmailButtonPressed(self)
        
        return true
    }
    // MARK:- Utilities for class
    func setupRecognizers(){
        
        // 1. Create a tag screen regonizer
        let screenTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        self.view.addGestureRecognizer(screenTapRecognizer)
    }
    
    @objc func screenTapped() {
        
        // 1. If screen is tapped, resign keyboard for all text fields
        self.emailTextField.resignFirstResponder()
    }
    
    func setupUI(){
        
        // 1. Add a radius to button to make it round
        self.sendResetPasswordEmailButton.layer.cornerRadius = self.sendResetPasswordEmailButton.frame.size.height / 2
        self.sendResetPasswordEmailButton.clipsToBounds = true
        self.sendResetPasswordEmailButton.layer.masksToBounds = true
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
                
                if self.emailTextField.frame.maxY > (self.view.frame.height - keyboardSize.height){
                    // 3. Animate the text fields up
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        // If no predictive search is displayed
                        if keyboardSize.height == offset.height{
                            self.emailTextFieldBottomConstraint.constant = (keyboardSize.height) - (self.view.frame.height - self.sendResetPasswordEmailButton.frame.origin.y) + 15
                        }else{
                            self.emailTextFieldBottomConstraint.constant = (keyboardSize.height + offset.height) - (self.view.frame.height - self.sendResetPasswordEmailButton.frame.origin.y) + 15
                        }
                    })
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.emailTextFieldBottomConstraint.constant = 180
        }
    }
    
    func setupActivityIndicator(){
        // 1. Create a frame for the indicator
        let height: CGFloat = 60
        let frame = CGRect(x: (self.view.frame.width - height) / 2, y: (self.view.frame.height - height) / 2, width: height, height: height)
        
        // 2. Instantiate indicator
        self.activityIndicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotatePulse, color: UIColor.white, padding: 0)
        
        // 3. Add indicator to view
        self.view.addSubview(self.activityIndicator!)
    }
}
