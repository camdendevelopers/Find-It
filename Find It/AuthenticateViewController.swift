//
//  AuthenticateViewController.swift
//  Find It
//
//  Created by Camden Madina on 2/21/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import FacebookCore
import NVActivityIndicatorView

class AuthenticateViewController: UIViewController {
    
    // IBOutlets for class
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var authenticateButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var emailDescriptionLabel: UILabel!
    @IBOutlet weak var passwordDescriptionLabel: UILabel!
    
    // Variables for class
    var activityIndicator:NVActivityIndicatorView?
    var isSignUp:Bool?
    var isFacebookAuth:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1. Setup activity indicator 
        self.setupActivityIndicator()
        
        // 2. Show activity indicator while app checks for current user
        self.activityIndicator?.startAnimating()
        
        // 3. Setup UI
        setupUI()
        
        
        // 4. Perform action based on current user
        if UserDefaults.standard.value(forKey: "uid") != nil && DataService.dataService.AUTH_REF.currentUser != nil && Reachability.isConnectedToNetwork(){
            
            //There is a current user previously logged in
            self.performSegue(withIdentifier: "ToAppSegue", sender: self)
        }else{
            //No current user found
            self.activityIndicator?.stopAnimating()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 1. Change status bar color to white for this screen only
        UIApplication.shared.statusBarStyle = .lightContent
        
        // 2. Update UI depending on if user is signing up or signing in
        if isSignUp == true{
            facebookButton.setTitle("SIGN UP WITH FB", for: .normal)
            authenticateButton.setTitle("SIGN UP", for: .normal)
            descriptionLabel.text = "Sign up"
            
            self.view.backgroundColor = kColorFF7D7D
            self.authenticateButton.setTitleColor(kColorFF7D7D, for: .normal)
            self.facebookButton.setTitleColor(kColorFF7D7D, for: .normal)
            self.emailDescriptionLabel.textColor = kColorFDBFBF
            self.passwordDescriptionLabel.textColor = kColorFDBFBF
        }else{
            facebookButton.setTitle("LOG IN WITH FB", for: .normal)
            authenticateButton.setTitle("LOG IN", for: .normal)
            descriptionLabel.text = "Log in"
            
            self.view.backgroundColor = kColor4990E2
            self.authenticateButton.setTitleColor(kColor4990E2, for: .normal)
            self.facebookButton.setTitleColor(kColor4990E2, for: .normal)
            self.emailDescriptionLabel.textColor = kColor87BEFE
            self.passwordDescriptionLabel.textColor = kColor87BEFE
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 1. Change status bar color back to white when moving away from screen
        UIApplication.shared.statusBarStyle = .default
    }
    
    // MARK:- IB Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        // 1. Return to previous screen
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func facebookButtonPressed(_ sender: Any) {
        
        // 1. Set this flag to prepare app to register user through Facebook
        self.isFacebookAuth = true
        
        // 2. Start animating the indicator while authentication happens
        activityIndicator?.startAnimating()
        
        // 3. Perform authentication based on user selction
        if isSignUp == true{
            performFacebookSignUp()
        }else{
            performFacebookSignIn()
        }
    }
    
    @IBAction func authenticateButtonPressed(_ sender: Any) {
        
        // 1. Set this flag to prepare app to register user through Email
        self.isFacebookAuth = false
        
        // 2. Check that user has entered text in text fields
        guard emailTextField.text != "", passwordTextField.text != "" else{
            self.present(Utilities.showErrorAlert(inDict: ["title": "Error Signing In", "message": "Make sure to fill out both fields"]), animated: true, completion: nil)
            return
        }
        
        // 3. Show progress indicator while checking
        activityIndicator?.startAnimating()
 
        // 4. Perform Firebase authentication depending on user selction
        if isSignUp == true{
            performFirebaseSignUp()
        }else{
            performFirebaseSignIn()
        }
    }
    
    // Mark:- Authentication class methods
    private func performFirebaseSignIn(){
        
        // 1.Create local variables with text from text fields
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        // 2. Check there is network connection
        guard Reachability.isConnectedToNetwork() == true else {
            print("Internet connection FAILED")
            present(Utilities.showErrorAlert(inDict: noNetworkConnection), animated: true, completion: nil)
            return
        }
        
        // 4. Check that user has entered text in both text fields
        guard email != "", password != "" else {
            return
        }
        
        // 4. Call Firebase server to create a user with provided information
        DataService.dataService.AUTH_REF.signIn(withEmail: email, password: password) { (user, error) in
            
            // 5. Check if error exists
            if let errorCode = (error as NSError?)?.code{
                
                self.activityIndicator?.stopAnimating()
                
                if errorCode == 17005{
                    self.present(Utilities.showErrorAlert(inDict: FIRAuthErrorCodeUserDisabled), animated: true, completion: nil)
                } else if errorCode == 17006{
                    self.present(Utilities.showErrorAlert(inDict: FIRAuthErrorCodeOperationNotAllowed), animated: true, completion: nil)
                } else if errorCode == 17008{
                    self.present(Utilities.showErrorAlert(inDict: FIRAuthErrorCodeInvalidEmail), animated: true, completion: nil)
                } else if errorCode == 17009{
                    self.present(Utilities.showErrorAlert(inDict: FIRAuthErrorCodeWrongPassword), animated: true, completion: nil)
                }else if errorCode == 17011{
                    self.present(Utilities.showErrorAlert(inDict: FIRAuthErrorCodeUserNotFound), animated: true, completion: nil)
                }else{
                    print(errorCode)
                }
                
            }
            
            // 6. If no error, sign in user
            if let user = user as FIRUser!{
                // 5.Allow user to enter app and set user UID to value for key in NSUserDefaults
                
                // Reset text fields
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                
                // Update user defaults
                UserDefaults.standard.setValue(user.uid, forKey: "uid")
                
                // Go to next screen
                self.performSegue(withIdentifier: "ToAppSegue", sender: self)
                self.activityIndicator?.stopAnimating()
            }
        }
    }
    
    private func performFirebaseSignUp(){
        // 1.Create local variables with text from text fields
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        // 2. Check there is network connection
        guard Reachability.isConnectedToNetwork() == true else {
            print("Internet connection FAILED")
            present(Utilities.showErrorAlert(inDict: noNetworkConnection), animated: true, completion: nil)
            return
        }
        
        // 3.Check if all the entered information is valid from text fields

        guard email != "", password != "" else {
            self.activityIndicator?.stopAnimating()
            present(Utilities.showErrorAlert(inDict: ["title": "Couldn't Create Account", "message": "You entered something wrong"]), animated: true, completion: nil)
            return
        }
        
        // 4. Call Firebase server to create a user with provided information
        DataService.dataService.AUTH_REF.createUser(withEmail: email, password: password, completion: { (user, error) in
            if let errorCode = (error as NSError?)?.code{
                // 5. Error found while creating user; will show alert view with information
                self.activityIndicator?.stopAnimating()
                
                if errorCode == 17005{
                    self.present(Utilities.showErrorAlert(inDict: FIRAuthErrorCodeUserDisabled), animated: true, completion: nil)
                } else if errorCode == 17006{
                    self.present(Utilities.showErrorAlert(inDict: FIRAuthErrorCodeOperationNotAllowed), animated: true, completion: nil)
                } else if errorCode == 17007 {
                    self.present(Utilities.showErrorAlert(inDict: FIRAuthErrorCodeEmailAlreadyInUse), animated: true, completion: nil)
                } else if errorCode == 17008{
                    self.present(Utilities.showErrorAlert(inDict: FIRAuthErrorCodeInvalidEmail), animated: true, completion: nil)
                } else if errorCode == 17026{
                    self.present(Utilities.showErrorAlert(inDict: FIRAuthErrorCodeWeakPassword), animated: true, completion: nil)
                }else{
                    print(errorCode)
                }
            }
            
            // 6. No error, create user
            if let user = user as FIRUser! {
                let newUser: [String:Any] = [
                    "provider": user.providerID as String,
                    "email": email,
                    "uid": user.uid as String,
                    "profileImageURL": ""
                ]
                
                // 7. Add account to Firebase database
                DataService.dataService.createNewAccount(uid: user.uid, user: newUser)
                
                // Update user defaults
                UserDefaults.standard.setValue(user.uid, forKey: "uid")
                
                // Go to next screen
                self.performSegue(withIdentifier: "NewUserSegue", sender: self)
                self.activityIndicator?.stopAnimating()
            }
        })
    }
    
    private func performFacebookSignIn(){
        // 1. Perform Facebook authentication
        DataService.dataService.FBAUTH_REF.logIn([ReadPermission.publicProfile,ReadPermission.email, ReadPermission.userFriends], viewController: self) { loginResult in
            print(loginResult)
            switch loginResult {
            case .failed(let error):
                self.activityIndicator?.stopAnimating()
                print("Facebook login failed. Error \(error)")
            case .cancelled:
                self.activityIndicator?.stopAnimating()
                print("Facebook login cancelled.")
            case .success( _, _, let accessToken):
                print("Logged in!")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                self.activityIndicator?.stopAnimating()
                // 2. Sign in user
                DataService.dataService.AUTH_REF.signIn(with: credential, completion: { (user, error) in
                    let user = user!
                    
                    if let error = error{
                        print("Login failed. \(error)")
                    }else{
                        
                        UserDefaults.standard.setValue(user.uid, forKey: "uid")
                        self.performSegue(withIdentifier: "ToAppSegue", sender: nil)
                    }
                })
            }
        }
        
        //self.performSegue(withIdentifier: "ToAppSegue", sender: nil)
    }
    
    private func performFacebookSignUp(){
        // 1. Call Firebase server to perform authentication through Facebook
        
        DataService.dataService.FBAUTH_REF.logIn([ReadPermission.publicProfile,ReadPermission.email, ReadPermission.userFriends], viewController: self) { loginResult in
            switch loginResult {
                
            case .failed(let error):
                self.activityIndicator?.stopAnimating()
                print("Facebook login failed. Error \(error)")
            case .cancelled:
                self.activityIndicator?.stopAnimating()
                print("Facebook login cancelled.")
            case .success( _, _, let accessToken):
                
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                self.activityIndicator?.stopAnimating()
                
                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                    if let error = error{
                        
                        self.present(Utilities.showErrorAlert(inDict: FIRAuthErrorCodeInvalidCredential), animated: true, completion: nil)
                        print("Login failed. \(error)")
                    }
                    
                    // 2. No error, create user
                    if let user = user as FIRUser!{
                         let newUser: [String:Any] = [
                         "provider": user.providerID as String,
                         "firstName": user.displayName! as String,
                         "email": user.email! as String,
                         "profileImageURL": (user.photoURL?.absoluteString)!,
                         "uid": user.uid as String,
                         ]
                        
                         DataService.dataService.createNewAccount(uid: user.uid, user: newUser)
                        
                         //3. Update user defaults and go to next screen
                         UserDefaults.standard.setValue(user.uid, forKey: "uid")
                        self.performSegue(withIdentifier: "NewUserSegue", sender: self)
                    }
                })
            }
        }
    }
    
    //MARK:- Utilities for class
    func setupActivityIndicator(){
        // 1. Create a frame for the indicator
        let height: CGFloat = 60
        let frame = CGRect(x: (self.view.frame.width - height) / 2, y: (self.view.frame.height - height) / 2, width: height, height: height)
        
        // 2. Instantiate indicator
        self.activityIndicator = NVActivityIndicatorView(frame: frame, type: .ballTrianglePath, color: UIColor(red: 255.0/255.0, green: 125.0/255.0, blue: 125.0/255.0, alpha: 1.0), padding: 0)
        
        // 3. Add indicator to view
        self.view.addSubview(self.activityIndicator!)
    }
    
    func setupUI(){
        
        // 1. Add a radius to button to make it round
        self.authenticateButton.layer.cornerRadius = self.authenticateButton.frame.size.height / 2
        self.authenticateButton.clipsToBounds = true
        self.authenticateButton.layer.masksToBounds = true
        
        self.facebookButton.layer.cornerRadius = self.facebookButton.frame.size.height / 2
        self.facebookButton.clipsToBounds = true
        self.facebookButton.layer.masksToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewUserSegue"{
            if let destinationViewController = segue.destination as? BasicInformationViewController{
                destinationViewController.isFacebookAuth = self.isFacebookAuth
            }
        }
    }
}
