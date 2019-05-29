//
//  SettingsViewController.swift
//  Find It
//
//  Created by Camden Madina on 3/6/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import NVActivityIndicatorView

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    
    // IBOutlets for class
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var itemImageEditableView: UIImageView!
    @IBOutlet weak var phoneTextFieldLine: UIView!
    @IBOutlet weak var addressTextFieldLine: UIView!
    @IBOutlet weak var cityTextFieldLine: UIView!
    @IBOutlet weak var stateTextFieldLine: UIView!
    
    // Variables for class
    private var imagePicker =  UIImagePickerController()
    private var imageSelected:UIImage?
    private var activityIndicator:NVActivityIndicatorView?
    private var loadingView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup activity indicator
        setupActivityIndicator()
        
        // 2. Load user details
        loadUser()
        
        // 3. Setup image view
        setupImageView()
        
        // 4. Setup bars
        setupBars()
        
        // 5. Setup button
        setupButton()
        
        // 6. Setup text fields
        setupTextFields()
        
        // 7. Setup recognizers
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
            UserDefaults.standard.set(nil, forKey: "uid")
            self.performSegue(withIdentifier: "LogoutSegue", sender: self)
        } catch let signOutError as NSError {
            
            // Error signing out
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        
        // If the button was previously edit, change it save and update UI elements to allow edits
        if actionButton.title(for: .normal) == "Edit"{
            
            // 1. Enable the text fields
            cityTextField.isEnabled = true
            stateTextField.isEnabled = true
            phoneTextField.isEnabled = true
            addressTextField.isEnabled = true
            
            // 2. Enable the image view to be tapped and unhide indicator
            profileImageView.isUserInteractionEnabled = true
            itemImageEditableView.isHidden = false
            
            // 3. Display the lines underneath text fields
            phoneTextFieldLine.isHidden = false
            addressTextFieldLine.isHidden = false
            cityTextFieldLine.isHidden = false
            stateTextFieldLine.isHidden = false
            
            // 4. Change the button titles
            actionButton?.setTitle("Save", for: .normal)
        }else{
            DispatchQueue.global(qos: .userInitiated).async {
                
                let city = self.cityTextField.text
                let state = self.stateTextField.text
                let phone = self.phoneTextField.text
                let address = self.addressTextField.text
                
                // 1. Update values if changed
                DataService.dataService.CURRENT_USER_REF.child("city").setValue(city!)
                DataService.dataService.CURRENT_USER_REF.child("state").setValue(state!)
                DataService.dataService.CURRENT_USER_REF.child("phone").setValue(phone!)
                DataService.dataService.CURRENT_USER_REF.child("address").setValue(address!)
                
                DispatchQueue.main.async {
                    // 1. Enable the text fields
                    self.cityTextField.isEnabled = false
                    self.stateTextField.isEnabled = false
                    self.phoneTextField.isEnabled = false
                    self.addressTextField.isEnabled = false
                    
                    // 2. Enable the image view to be tapped and unhide indicator
                    self.profileImageView.isUserInteractionEnabled = false
                    self.itemImageEditableView.isHidden = true
                    
                    // 3. Display the lines underneath text fields
                    self.phoneTextFieldLine.isHidden = true
                    self.addressTextFieldLine.isHidden = true
                    self.cityTextFieldLine.isHidden = true
                    self.stateTextFieldLine.isHidden = true
                    
                    // 4. Change the button titles
                    self.actionButton?.setTitle("Edit", for: .normal)
                }
            }
        }
        //self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Image Picker Delegate methods
    func setupImageView(){
        
        // 1. Create a recognizer for image
        let tapImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddTagViewController.imageViewTapped))
        profileImageView.image = UIImage(named: "default_image_icon")
        profileImageView.isUserInteractionEnabled = false
        profileImageView.addGestureRecognizer(tapImageRecognizer)
        
        profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.masksToBounds = true
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
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        // 2. Create button that will open camera
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        
        // 3. Create button that will open gallery
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openGallery()
        }
        
        // 4. Create button that will cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
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
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            // 2. If yes, display
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            
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
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        // 1. Assign the image info to a dictionary
        let imageInfo = info as [String : AnyObject]?
        
        // 2. Set the image view to the selected image
        self.profileImageView.image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        self.imageSelected = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        
        // 3. Dismiss the picker
        picker.dismiss(animated: true, completion: nil)
        
        // 4. Perform asynchronous call to upload image
        DispatchQueue.global(qos: .userInitiated).async {
            
            // Create variables
            let image = imageInfo?[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
            let imageData = image!.jpegData(compressionQuality: 0.8)
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
        self.cityTextField.delegate = self
        self.phoneTextField.delegate = self
        self.addressTextField.delegate = self
        self.cityTextField.delegate = self
        
        self.cityTextField.isEnabled = false
        self.phoneTextField.isEnabled = false
        self.addressTextField.isEnabled = false
        self.cityTextField.isEnabled = false
    }
    
    // MARK:- Utilities for class
    func setupRecognizers(){
        
        // 1. Create a tag screen regonizer
        let screenTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(screenTapped))
        self.view.addGestureRecognizer(screenTapRecognizer)
    }
    
    @objc func screenTapped(){
        
        // 1. If screen is tapped, resign keyboard for all text fields
        self.cityTextField.resignFirstResponder()
        self.phoneTextField.resignFirstResponder()
        self.addressTextField.resignFirstResponder()
        self.cityTextField.resignFirstResponder()
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
        navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue: UIFont(name: "HalisR-Black", size: 16)!, NSAttributedString.Key.foregroundColor.rawValue: UIColor.white])
        
    }
    
    func loadUser(){
        // 1. Display loading view
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        loadingView?.backgroundColor = .black
        loadingView?.alpha = 0.7
        loadingView?.isHidden = false
        self.view.addSubview(loadingView!)
        self.activityIndicator?.startAnimating()
        
        // 2. Check for network connectivity
        guard Reachability.isConnectedToNetwork() else{
            print("Not connected to internet")
            return
        }
        
        // 3. Retrive current user details
        DataService.dataService.CURRENT_USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            if let firstName = value?["firstName"] as? String, let lastName = value?["lastName"] as? String{
                self.nameLabel.text = firstName + " " + lastName
            }
            
            if let city = value?["city"] as? String {
                self.cityTextField.text = city
            }
            
            if let state = value?["state"] as? String {
                self.stateTextField.text = state
            }
            
            if let phone = value?["phone"] as? String {
                self.phoneTextField.text = Utilities.format(phoneNumber: phone)
            }
            
            if let address = value?["address"] as? String {
                self.addressTextField.text = address
            }
            
            if let urlString = value?["profileImageURL"] as? String {
                
                if urlString != "" {
                    
                    self.profileImageView.sd_setShowActivityIndicatorView(true)
                    self.profileImageView.sd_setIndicatorStyle(.gray)
                    self.profileImageView.sd_setImage(with: URL(string: urlString), placeholderImage: UIImage(named: "default_image_icon"), options: SDWebImageOptions.progressiveDownload)

                }else{
                    self.profileImageView.image =  UIImage(named: "default_image_icon_gray")!
                }
            }
            
            self.loadingView?.isHidden = true
            self.activityIndicator?.stopAnimating()
        })
    }
    
    func setupActivityIndicator(){
        // 1. Create a frame size for activity indicator
        let height: CGFloat = 60
        let frame = CGRect(x: (self.view.frame.width - height) / 2, y: (self.view.frame.height - height) / 2, width: height, height: height)
        
        // 2. Instantiate the activity indicator
        self.activityIndicator = NVActivityIndicatorView(frame: frame, type: .squareSpin, color: UIColor.white, padding: 0)
        
        // 3. Add it to view
        self.view.addSubview(self.activityIndicator!)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
