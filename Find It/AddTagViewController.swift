//
//  AddTagViewController.swift
//  Settings
//
//  Created by Camden Madina on 3/2/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase

class AddTagViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    // Declare IBOutlets
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemDescriptionTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    
    //Declare Variables
    private var imagePicker =  UIImagePickerController()
    private var imageSelected: UIImage?
    private var imageInfo: [String: AnyObject]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // 1. Setup text fields
        setupTextFields()
        
        // 2. Setup button
        setupButton()
        
        // 3. Setup image view
        setupImageView()
        
        // 4. Setup bars
        setupBars()
    }
    
    // MARK:- IBActions
    @IBAction func cancelButtonPressed(_ sender: Any) {
        // 1. Return to previous screen
        self.dismiss(animated: true, completion: nil)
    }
    
    //ADDD THE ANIMATION INDICATOR
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        // 1. Create local variables for each text field input
        let itemName = itemNameTextField.text
        let itemDescription = itemDescriptionTextField.text
        
        // 2. Check that fields are not empty
        guard itemName != "", itemDescription != "" else {
            present(Utilities.showErrorAlert(inDict: ["title": "Oops", "message": "You need to have details on both fields"]), animated: true, completion: nil)
            return
        }
        
        // 3. Go to next screen
        performSegue(withIdentifier: "ConfirmAddTagSegue", sender: self)
    }
    
    // MARK:- Image Picker Delegate methods
    func setupImageView(){
        
        // 1. Create a reconizer for image
        let tapImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddTagViewController.imageViewTapped))
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(tapImageRecognizer)
    }
    
    func imageViewTapped(){
        
        // 1. Check which device is being used
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS{
            self.present(Utilities.showErrorAlert(inDict: IPhoneTryUpload), animated: true, completion: nil)
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
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default)
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
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        
        // 6. Set the image picker delegates
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // 7. Display alert to user
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        
        // 1. Check that user has camera
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
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
        
        // 1. Open gallery
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // 1. Assign info to class image infor
        self.imageInfo = info as [String: AnyObject]
        self.itemImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        // 2. Return to app
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // 1. Image picker was canceled, return to app
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Button methods
    func setupButton(){
        // 1. Set the button to gray  by default and disable
        nextButton.setTitleColor(UIColor(red:0.64, green:0.64, blue:0.64, alpha:1.0), for: .disabled)
        nextButton.backgroundColor = UIColor(red:0.80, green:0.82, blue:0.82, alpha:1.0)
        nextButton.isEnabled = false
    }
    
    // MARK:- Text Field Delegate
    
    func setupTextFields(){
        
        // 1. Assign the text fields
        self.itemNameTextField.delegate = self
        self.itemDescriptionTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == itemNameTextField{
            itemDescriptionTextField.becomeFirstResponder()
        }else{
            itemDescriptionTextField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // 1. Check that text fields have text
        if itemNameTextField.text?.isEmpty == true || itemDescriptionTextField.text?.isEmpty == true {
            nextButton.setTitleColor(UIColor(red:0.64, green:0.64, blue:0.64, alpha:1.0), for: .disabled)
            nextButton.backgroundColor = UIColor(red:0.80, green:0.82, blue:0.82, alpha:1.0)
            nextButton.isEnabled = false
        }else{
            nextButton.backgroundColor = UIColor(red: 88.0/255.0, green: 163.0/255.0, blue: 232.0/255.0, alpha: 1.0)
            nextButton.setTitleColor(UIColor.white, for: .normal)
            nextButton.isEnabled = true
            
        }
    }
    
    // MARK:- Utilities for class
    func setupBars(){
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HalisR-Black", size: 16), NSForegroundColorAttributeName: UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0) ]
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConfirmAddTagSegue"{
            if let destinationViewController = segue.destination as? ConfirmAddTagViewController{
                destinationViewController.itemDescriptionText = itemDescriptionTextField.text!
                destinationViewController.itemNameText = itemNameTextField.text!
                destinationViewController.itemImage = itemImageView.image!
                destinationViewController.imageInfo = self.imageInfo
            }
        }
    }
}
