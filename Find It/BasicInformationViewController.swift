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
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    //var imageURL:String = ""
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
        performSegue(withIdentifier: "ToAddressSegue", sender: self)
        
        let name = nameTextField.text
        let phone = phoneTextField.text
        
        guard name != "", phone != "" else {
            present(Utilities.showErrorAlert(inDict: ["title": "Oops", "message": "You need to have details on both fields"]), animated: true, completion: nil)
            return
        }
        
        currentUser?.child("name").setValue(name)
        currentUser?.child("phone").setValue(phone)

    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func loadUser(){
        
        guard Reachability.isConnectedToNetwork() else{
            print("Not connected to internet")
            return
        }
        
        self.currentUserID = DataService.dataService.AUTH_REF.currentUser?.uid
        self.currentUser = DataService.dataService.USER_REF.child(currentUserID!)
        
        self.currentUser?.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
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
                self.profileImageView.image =  UIImage(named: "default_image_icon")!
            }
        })
    }
    
    // MARK:- Image Picker Delegate methods
    func setupImageView(){
        let tapImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddTagViewController.imageViewTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapImageRecognizer)
    }
    
    func imageViewTapped(){
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS{
            present(Utilities.showErrorAlert(inDict: IPhoneTryUpload), animated: true, completion: nil)
        }else{
            showAlertView()
        }
    }
    
    func showAlertView (){
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self .present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Warning", message: "You don't have a camera", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery(){
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageInfo = info as [String : AnyObject]?
        picker.dismiss(animated: true, completion: nil)
        profileImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        imageSelected = info[UIImagePickerControllerEditedImage] as? UIImage
        
        //uploadImage(imageInfo!)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image picker canceled")
        picker.dismiss(animated: true, completion: nil)
    }
    
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        resizeImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    // MARK:- Text Field Delegate
    
    func setupTextFields(){
        self.nameTextField.delegate = self
        self.phoneTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField{
            phoneTextField.becomeFirstResponder()
        }else{
            phoneTextField.resignFirstResponder()
        }
        return true
    }
}
