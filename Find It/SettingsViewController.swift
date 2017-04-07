//
//  SettingsViewController.swift
//  Find It
//
//  Created by Camden Madina on 3/6/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase
import FacebookLogin

class SettingsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    private var currentUserID:String?
    private var currentUser: FIRDatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUser()
    }
  
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try DataService.dataService.AUTH_REF.signOut()
            self.performSegue(withIdentifier: "LogoutSegue", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    // MARK:- Utilities for class
    func loadUser(){
        guard Reachability.isConnectedToNetwork() else{
            print("Not connected to internet")
            return
        }
        
        self.currentUserID = DataService.dataService.AUTH_REF.currentUser?.uid
        self.currentUser = DataService.dataService.USER_REF.child(currentUserID!)
        
        self.currentUser?.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            if let name = value?["name"] as? String {
                self.nameLabel.text = name
            }
            if let email = value?["email"] as? String {
                self.emailTextField.text = email
            }
            if let phone = value?["phone"] as? String {
                self.phoneTextField.text = Utilities.format(phoneNumber: phone)
            }
            if let address = value?["address"] as? String {
                self.addressTextField.text = address
            }
            if let urlString = value?["profileImageURL"] as? String {
                if urlString != "" {
                    self.loadProfileImage(withURLString: urlString, completion: { (data) in
                        self.profileImageView.image = UIImage(data: data)
                    })
                }else{
                    self.profileImageView.image =  UIImage(named: "default_image_icon")!
                }
            }
        })
    }
    
    func loadProfileImage(withURLString string:String, completion: (_ image: Data) -> Void){
        if let url = URL(string: string) {
            if let data = NSData(contentsOf: url) as Data?{
                completion(data)
            }
        }
        
    
        /*
        let url = NSURL(string: string)
        let data = NSData(contentsOf: url! as URL)
        //self.profileImageView.image = UIImage(data: data! as Data)!
        completion(data as! Data)
 */
    }

}
