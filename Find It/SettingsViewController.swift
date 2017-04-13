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
import SDWebImage

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    
    // IBOutlets for class
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var logoutButton: UIButton!
    
    // Variables for class
    private var imagePicker =  UIImagePickerController()
    private var imageSelected: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Load user details
        loadUser()
        
        // 2. Setup image view
        setupImageView()
        
        // 3. Setup bars
        setupBars()
        
        // 4. Setup button
        setupButton()
        
        // 5. Setup text fields
        setupTextFields()
        
        // 6. Setup recognizers
        setupRecognizers()
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
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        // 1. Attempt to sign out
        do {
            try DataService.dataService.AUTH_REF.signOut()
            
            // Return to main screen
            self.performSegue(withIdentifier: "LogoutSegue", sender: self)
        } catch let signOutError as NSError {
            
            // Error signing out
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let email = self.emailTextField.text
        let phone = self.phoneTextField.text
        let address = self.addressTextField.text
        
        // 1. Update values if changed
        DataService.dataService.CURRENT_USER_REF.child("email").setValue(email!)
        DataService.dataService.CURRENT_USER_REF.child("phone").setValue(phone!)
        DataService.dataService.CURRENT_USER_REF.child("address").setValue(address!)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Image Picker Delegate methods
    func setupImageView(){
        
        // 1. Create a recognizer for image
        let tapImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddTagViewController.imageViewTapped))
        profileImageView.image = UIImage(named: "default_image_icon")
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapImageRecognizer)
    }
    
    func imageViewTapped(){
        
        // 1. Check which iphone is currently being displayed
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS{
            present(Utilities.showErrorAlert(inDict: IPhoneTryUpload), animated: true, completion: nil)
        }else{
            showAlertView()
        }
    }
    
    func showAlertView (){
        
        // 1. Create alert to be displayed
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        // 2. Create button that will open camera
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        
        // 3. Create button that will open gallery
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openGallery()
        }
        
        // 4. Create button that will cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
        }
        
        // 5.  Add the actions
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        // 6. Set the image picker delegates
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        
        // 7. Display alert to user
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        
        // 1. Check that user has camera
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            // 2. If yes, display
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            
            self .present(imagePicker, animated: true, completion: nil)
        }else{
            // 3. If not, alert user
            let alert = UIAlertController(title: "Warning", message: "You don't have a camera", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery(){
        // 1. Display users library
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 1. Assign the image info to a dictionary
        let imageInfo = info as [String : AnyObject]?
        
        // 2. Set the image view to the selected image
        self.profileImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.imageSelected = info[UIImagePickerControllerEditedImage] as? UIImage
        
        // 3. Dismiss the picker
        picker.dismiss(animated: true, completion: nil)
        
        // 4. Perform asynchronous call to upload image
        DispatchQueue.global(qos: .userInitiated).async {
            
            // Create variables
            let image = imageInfo?[UIImagePickerControllerOriginalImage] as? UIImage
            let imageData = UIImageJPEGRepresentation(image!, 0.8)
            let metadata = FIRStorageMetadata()
            let imagePath = FIRAuth.auth()!.currentUser!.uid + ".jpg"
            metadata.contentType = "image/jpeg"
            
            // Update it to storage
            DataService.dataService.STORAGE_REF.child(imagePath).put(imageData!, metadata: metadata) { (metadata, error) in
                if error != nil {
                    return
                }else{
                    let imageURL = (metadata?.downloadURL()?.absoluteString)!
                    DataService.dataService.CURRENT_USER_REF.child("profileImageURL").setValue(imageURL)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 1. User cancelled, return to app
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Text Field Delegate
    
    func setupTextFields(){
        // 1. Set the delegates of the text fields
        self.emailTextField.delegate = self
        self.phoneTextField.delegate = self
        self.addressTextField.delegate = self
    }
    
    // MARK:- Utilities for class
    func setupRecognizers(){
        
        // 1. Create a tag screen regonizer
        let screenTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.screenTapped))
        self.view.addGestureRecognizer(screenTapRecognizer)
    }
    
    func screenTapped(){
        
        // 1. If screen is tapped, resign keyboard for all text fields
        self.emailTextField.resignFirstResponder()
        self.phoneTextField.resignFirstResponder()
        self.addressTextField.resignFirstResponder()
    }
    
    func setupButton(){
        // 1. Add a radius to button to make it round
        self.logoutButton.layer.cornerRadius = self.logoutButton.frame.size.height / 2
        self.logoutButton.clipsToBounds = true
        self.logoutButton.layer.masksToBounds = true
        
        
        self.logoutButton.setTitleColor(kColorFF7D7D, for: .normal)
        self.logoutButton.backgroundColor = UIColor.clear
        self.logoutButton.layer.borderWidth = 2
        self.logoutButton.layer.borderColor = kColorFF7D7D.cgColor
    }
    
    func setupBars(){
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        
        navigationController?.navigationBar.barTintColor = kColorFF7D7D
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HalisR-Black", size: 16)!, NSForegroundColorAttributeName: UIColor.white]
        
    }
    
    func loadUser(){
        
        // 1. Check for network connectivity
        guard Reachability.isConnectedToNetwork() else{
            print("Not connected to internet")
            return
        }
        
        // 2. Retrive current user details
        DataService.dataService.CURRENT_USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            if let firstName = value?["firstName"] as? String, let lastName = value?["lastName"] as? String{
                self.nameLabel.text = firstName + " " + lastName
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
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
                self.profileImageView.clipsToBounds = true
                self.profileImageView.layer.masksToBounds = true
                
                if urlString != "" {
                    
                    self.profileImageView.sd_setShowActivityIndicatorView(true)
                    self.profileImageView.sd_setIndicatorStyle(.gray)
                    self.profileImageView.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "default_image_icon"), options: SDWebImageOptions.progressiveDownload)

                }else{
                    self.profileImageView.image =  UIImage(named: "default_image_icon_gray")!
                }
            }
        })
    }
}
