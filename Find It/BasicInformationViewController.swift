//
//  BasicInformationViewController.swift
//  Find It
//
//  Created by Camden Madina on 3/14/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class BasicInformationViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // IBOutlets for class
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    // Variables for class
    private var imagePicker =  UIImagePickerController()
    private var imageInfo: [String : AnyObject]?
    private var imageSelected: UIImage?
    
    private var currentUserID:String?
    private var currentUser: FIRDatabaseReference?
    
    var isFacebookAuth:Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup text fields
        setupTextFields()
        
        // 2. Setup image view
        setupImageView()
        
        // 3. Load user to edit
        loadUser()
        
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        // 1. Create local variables of text fields text
        let name = nameTextField.text
        let phone = phoneTextField.text
        
        // 2. Check if textfields are empty
        guard name != "", phone != "" else {
            present(Utilities.showErrorAlert(inDict: ["title": "Oops", "message": "You need to have details on both fields"]), animated: true, completion: nil)
            return
        }
        
        // 3. Update current user's values
        currentUser?.child("name").setValue(name)
        currentUser?.child("phone").setValue(phone)
        
        // 4. Go to next screen
        performSegue(withIdentifier: "ToAddressSegue", sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        // 1. Return to previous screen
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func loadUser(){
        
        // 1. Check if there is a network connection
        guard Reachability.isConnectedToNetwork() else{
            print("Not connected to internet")
            return
        }
        
        // 2. Get current user's information
        self.currentUserID = DataService.dataService.AUTH_REF.currentUser?.uid
        self.currentUser = DataService.dataService.USER_REF.child(currentUserID!)
        
        // 3. Get current user's information
        self.currentUser?.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            // 4. If they are facbook users, they have default information
            if self.isFacebookAuth! {
                let urlString = value?["profileImageURL"] as? String
                let name = value?["name"] as? String
                
                self.nameTextField.text = name!
                DispatchQueue.main.async(execute: {
                    let url = NSURL(string: urlString!)
                    let data = NSData(contentsOf: url! as URL)
                    self.profileImageView.image = UIImage(data: data! as Data)!
                })
            }else{
                
                // 5. If not, they must provide all information
                self.profileImageView.image =  UIImage(named: "default_image_icon")!
            }
        })
    }
    
    // MARK:- Image Picker Delegate methods
    func setupImageView(){
        
        // 1. Create a recognizer for image
        let tapImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddTagViewController.imageViewTapped))
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
        self.imageInfo = info as [String : AnyObject]?
        
        // 2. Set the image view to the selected image
        self.profileImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.imageSelected = info[UIImagePickerControllerEditedImage] as? UIImage
        
        // 3. Dismiss the picker
        picker.dismiss(animated: true, completion: nil)
        
        // 4. Upload image
        //uploadImage(imageInfo!)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 1. User cancelled, return to app
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK:- Text Field Delegate
    
    func setupTextFields(){
        // 1. Set the delegates of the text fields
        self.nameTextField.delegate = self
        self.phoneTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 1. If you are at top text field and hit enter, go to the next one
        if textField == nameTextField{
            phoneTextField.becomeFirstResponder()
        }else{
            phoneTextField.resignFirstResponder()
        }
        return true
    }
}
