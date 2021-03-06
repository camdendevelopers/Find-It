//
//  BasicInformationViewController.swift
//  Find It
//
//  Created by Camden Madina on 3/14/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FirebaseAuth

class BasicInformationViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARL:- IBOutlets for class
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var lastNameTextFieldBottomConstraint: NSLayoutConstraint!
    // MARK:- Variables for class
    private var imagePicker =  UIImagePickerController()
    private var imageSelected: UIImage?
    
    var isFacebookAuth:Bool?
    
    // MARK:- Loading method calls
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup text fields
        setupTextFields()
        
        // 2. Setup image view
        setupImageView()
        
        // 3. Setup UI
        setupUI()
        
        // 4. Initiliaze keyboard size functionality
        initializeKeyboardNotifications()
        
        // 5. Setup recognizers
        setupRecognizers()
        
        // 6. If Facebook sign up load user information
        loadUser()
    
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
    
    // MARK:- IBActions for class
    @IBAction func nextButtonPressed(_ sender: Any) {
        // 1. Create local variables of text fields text
        let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 2. Check if textfields are empty
        guard firstName != "", lastName != "" else {
            self.present(Utilities.showErrorAlert(inDict: EmptyTextFields), animated: true, completion: nil)
            return
        }
        
        // 3. Update current user's values
        DataService.dataService.CURRENT_USER_REF.child("firstName").setValue(firstName)
        DataService.dataService.CURRENT_USER_REF.child("lastName").setValue(lastName)
        
        // 4. Go to next screen
        performSegue(withIdentifier: "ToPhoneSegue", sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        // 1. Return to previous screen
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func loadUser(){
        
        // 1. Check if there is a network connection
        guard Reachability.isConnectedToNetwork() else{
            self.present(Utilities.showErrorAlert(inDict: NoNetworkConnection), animated: true, completion: nil)
            return
        }

        // 2. Get current user's information
        DataService.dataService.CURRENT_USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            // 4. If they are facbook users, they have default information
            if self.isFacebookAuth! {
                let urlString = value?["profileImageURL"] as? String
                let name = (value?["firstName"] as? String)?.components(separatedBy: " ")
    
                let firstName = name?.first!
                let lastName = name?.last!
                
                self.firstNameTextField.text = firstName!
                self.lastNameTextField.text = lastName!
                
                self.profileImageView.sd_setShowActivityIndicatorView(true)
                self.profileImageView.sd_setIndicatorStyle(.gray)
                self.profileImageView.sd_setImage(with: URL(string: urlString!), placeholderImage: UIImage(named: "default_image_icon"), options: SDWebImageOptions.progressiveDownload)
            } else {
                
                // 5. If not, they must provide all information
                self.profileImageView.image =  UIImage(named: "default_image_icon")!
            }
        })
    }
    
    // MARK:- Image Picker Delegate methods
    func setupImageView(){
        
        // 1. Create a recognizer for image
        let tapImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        profileImageView.image = UIImage(named: "default_image_icon")
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapImageRecognizer)
        
        profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.masksToBounds = true
    }
    
    @objc func imageViewTapped() {
        
        // 1. Check which ilastName is currently being displayed
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            present(Utilities.showErrorAlert(inDict: IPhoneTryUpload), animated: true, completion: nil)
            
        }else{
            showAlertView()
        }
    }
    
    func showAlertView(){
        
        // 1. Create alert to be displayed
        let alert:UIAlertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
        // 2. Create button that will open camera
        let cameraAction = UIAlertAction(title: "Camera", style: .default)
        {
            UIAlertAction in
            self.openCamera()
        }
        
        // 3. Create button that will open gallery
        let galleryAction = UIAlertAction(title: "Gallery", style: .default)
        {
            UIAlertAction in
            self.openGallery()
        }
        
        // 4. Create button that will cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
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
            self.present(Utilities.showErrorAlert(inDict: NoCameraAvailable), animated: true, completion: nil)
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
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 1. If you are at top text field and hit enter, go to the next one
        if textField == firstNameTextField{
            lastNameTextField.becomeFirstResponder()
        }else{
            lastNameTextField.resignFirstResponder()
            self.nextButtonPressed(self)
        }
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
        self.firstNameTextField.resignFirstResponder()
        self.lastNameTextField.resignFirstResponder()
    }
    
    func setupUI(){
        
        // 1. Add a radius to button to make it round
        self.nextButton.layer.cornerRadius = self.nextButton.frame.size.height / 2
        self.nextButton.clipsToBounds = true
        self.nextButton.layer.masksToBounds = true
    }
    
    //Methods for keyboards
    func initializeKeyboardNotifications(){
        
        // 1. Add notification obeservers that will alert app when keyboard displays
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        // 1. Check that notification dictionary is available
        if let userInfo = notification.userInfo{
            
            // 2. Obtain keyboard size and predictive search height
            if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let offset = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                
                if self.lastNameTextField.frame.maxY > (self.view.frame.height - keyboardSize.height){
                    // 3. Animate the text fields up
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        // If no predictive search is displayed
                        if keyboardSize.height == offset.height{
                            self.lastNameTextFieldBottomConstraint.constant = (keyboardSize.height) - (self.view.frame.height - self.nextButton.frame.origin.y) + 15
                        }else{
                            self.lastNameTextFieldBottomConstraint.constant = (keyboardSize.height + offset.height) - (self.view.frame.height - self.nextButton.frame.origin.y) + 15
                        }
                    })
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.lastNameTextFieldBottomConstraint.constant = 120
        }
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
