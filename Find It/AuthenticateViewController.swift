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
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var authenticateButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var facebookButton: UIButton!
    
    private var activityIndicator:NVActivityIndicatorView?
    var isSignUp:Bool?
    var isFacebookAuth:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicator()

        //Add code to check if user is already logged in to skip
        /*
        if isSignUp == true{
            performFacebookSignUp()
        }else{
            performFacebookSignIn()
        }
        */
    
        // 1. Show activity indicator while app checks for current user
        //showActivityIndicator()
        
        /*
        // 2. Perform action based on current user
        if UserDefaults.standard.value(forKey: "uid") != nil && DataService.dataService.AUTH_REF.currentUser != nil && Reachability.isConnectedToNetwork(){
            
            //There is a current user previously logged in
            self.performSegue(withIdentifier: "ToAppSegue", sender: self)
        }else{
            //No current user found
            hideActivityIndicator()
        }
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isSignUp == true{
            facebookButton.setTitle("Sign Up With Facebook", for: .normal)
            authenticateButton.setTitle("Sign Up", for: .normal)
            descriptionLabel.text = "Sign up to create tags"
        }else{
            facebookButton.setTitle("Sign In With Facebook", for: .normal)
            authenticateButton.setTitle("Sign In", for: .normal)
            descriptionLabel.text = "Sign in to access your account"
        }
    }
    
    // MARK:- IB Actions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func facebookButtonPressed(_ sender: Any) {
        isFacebookAuth = true
        
        //Show progress indicator while checking
        activityIndicator?.startAnimating()
        
        if isSignUp == true{
            performFacebookSignUp()
        }else{
            performFacebookSignIn()
        }
    }
    
    @IBAction func authenticateButtonPressed(_ sender: Any) {
        isFacebookAuth = false
        
        guard emailTextField.text != "", passwordTextField.text != "" else{
            self.present(Utilities.showErrorAlert(inDict: ["title": "Error Signing In", "message": "Make sure to fill out both fields"]), animated: true, completion: nil)
            return
        }
        
        //Show progress indicator while checking
        activityIndicator?.startAnimating()
 
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
        
        guard Reachability.isConnectedToNetwork() == true else {
            print("Internet connection FAILED")
            present(Utilities.showErrorAlert(inDict: noNetworkConnection), animated: true, completion: nil)
            return
        }
        
        guard email != "", password != "" else {
            return
        }
        
        // 4. Call Firebase server to create a user with provided information
        DataService.dataService.AUTH_REF.signIn(withEmail: email, password: password) { (user, error) in
            if let errorCode = (error as? NSError)?.code{
                
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
            if let user = user as FIRUser!{
                // 5.Allow user to enter app and set user UID to value for key in NSUserDefaults
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                UserDefaults.standard.setValue(user.uid, forKey: "uid")
                self.performSegue(withIdentifier: "ToAppSegue", sender: self)
                self.activityIndicator?.stopAnimating()
            }
        }
        
        
        //self.performSegue(withIdentifier: "ToAppSegue", sender: self)
        
    }
    
    private func performFirebaseSignUp(){
        // 1.Create local variables with text from text fields
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        guard Reachability.isConnectedToNetwork() == true else {
            print("Internet connection FAILED")
            present(Utilities.showErrorAlert(inDict: noNetworkConnection), animated: true, completion: nil)
            return
        }
        
        // 3.Check if all the entered information is valid from text fields
        guard Utilities.isValidEmail(text: email), Utilities.isValidPassword(text: password) else {
            //If initial check of text fields
            present(Utilities.showErrorAlert(inDict: ["title": "Couldn't Create Account", "message": "You entered something wrong"]), animated: true, completion: nil)
            return
        }
        
        // 4. Call Firebase server to create a user with provided information
        DataService.dataService.AUTH_REF.createUser(withEmail: email, password: password, completion: { (user, error) in
            if let errorCode = (error as? NSError)?.code{
                //Error found while creating user; will show alert view with information
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
            
            if let user = user as FIRUser! {
                //No error found and new user will be created with following information
                let newUser: [String:Any] = [
                    "provider": user.providerID as String,
                    "email": email,
                    "uid": user.uid as String,
                    "profileImageURL": ""
                ]
                
                // 5. Perform final authentication and
                DataService.dataService.createNewAccount(uid: user.uid, user: newUser)
                UserDefaults.standard.setValue(user.uid, forKey: "uid")
                self.activityIndicator?.stopAnimating()
                self.performSegue(withIdentifier: "NewUserSegue", sender: self)
            }
        })
        
        
        //self.performSegue(withIdentifier: "NewUserSegue", sender: self)
    }
    
    private func performFacebookSignIn(){
        
        DataService.dataService.FBAUTH_REF.logIn([ReadPermission.publicProfile,ReadPermission.email, ReadPermission.userFriends], viewController: self) { loginResult in
            print(loginResult)
            switch loginResult {
            case .failed(let error):
                self.activityIndicator?.stopAnimating()
                print("Facebook login failed. Error \(error)")
            case .cancelled:
                self.activityIndicator?.stopAnimating()
                print("Facebook login cancelled.")
            //case .success(let grantedPermissions, let declinedPermissions, let accessToken):
            case .success( _, _, let accessToken):
                print("Logged in!")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                    let user = user!
                    
                    if error != nil{
                        //Error was found
                        self.activityIndicator?.stopAnimating()
                        print("Login failed. \(error)")
                    }else{
                        
                        //5. Allow user to enter app and set user UID to value for key in NSUserDefaults
                        UserDefaults.standard.setValue(user.uid, forKey: "uid")
                        self.performSegue(withIdentifier: "ToAppSegue", sender: nil)
                    }
                })
            }
        }
        
        //self.performSegue(withIdentifier: "ToAppSegue", sender: nil)
    }
    
    private func performFacebookSignUp(){
        // 2.Call Firebase server to perform authentication through Facebook
        
        DataService.dataService.FBAUTH_REF.logIn([ReadPermission.publicProfile,ReadPermission.email, ReadPermission.userFriends], viewController: self) { loginResult in
            print(loginResult)
            switch loginResult {
            case .failed(let error):
                self.activityIndicator?.stopAnimating()
                print("Facebook login failed. Error \(error)")
            case .cancelled:
                self.activityIndicator?.stopAnimating()
                print("Facebook login cancelled.")
            //case .success(let grantedPermissions, let declinedPermissions, let accessToken):
            case .success( _, _, let accessToken):
                print("Logged in!")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                    if let error = error as? NSError{
                        self.activityIndicator?.stopAnimating()
                        self.present(Utilities.showErrorAlert(inDict: FIRAuthErrorCodeInvalidCredential), animated: true, completion: nil)
                        print("Login failed. \(error)")
                    }
         
                    if let user = user as FIRUser!{
                         let newUser: [String:Any] = [
                         "provider": user.providerID as String,
                         "name": user.displayName! as String,
                         "email": user.email! as String,
                         "profileImageURL": (user.photoURL?.absoluteString)!,
                         "uid": user.uid as String,
                         ]
                         
                         //let newUser = User(name: user.displayName!, email: user.email!, phone: "", address: "", profileImageURL: (user.photoURL?.absoluteString)!, isFirstTime: true, hasTags: false)
                         
                         //5. Allow user to enter app and set user UID to value for key in NSUserDefaults
                         UserDefaults.standard.setValue(user.uid, forKey: "uid")
                         DataService.dataService.createNewAccount(uid: user.uid, user: newUser)
                         self.activityIndicator?.stopAnimating()
                         
                         self.performSegue(withIdentifier: "NewUserSegue", sender: self)
                    }
                })
            }
        }
        
        //self.performSegue(withIdentifier: "NewUserSegue", sender: nil)
    }
    
    //MARK:- Utilities for class
    func setupActivityIndicator(){
        // Create a frame size for activity indicator
        let height: CGFloat = 60
        let frame = CGRect(x: (self.view.frame.width - height) / 2, y: (self.view.frame.height - height) / 2, width: height, height: height)
        
        // Instantiate the activity indicator
        self.activityIndicator = NVActivityIndicatorView(frame: frame, type: .ballTrianglePath, color: .green, padding: 0)
        
        // Add it to view
        self.view.addSubview(self.activityIndicator!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewUserSegue"{
            if let destinationViewController = segue.destination as? BasicInformationViewController{
                destinationViewController.isFacebookAuth = self.isFacebookAuth
            }
        }
    }
}
