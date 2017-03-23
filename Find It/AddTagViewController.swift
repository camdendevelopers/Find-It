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
    }
    
    // MARK:- IBActions
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //ADDD THE ANIMATION INDICATOR
    @IBAction func nextButtonPressed(_ sender: Any) {
        let itemName = itemNameTextField.text
        let itemDescription = itemDescriptionTextField.text
        
        guard itemName != "", itemDescription != "" else {
            present(Utilities.showErrorAlert(inDict: ["title": "Oops", "message": "You need to have details on both fields"]), animated: true, completion: nil)
            return
        }
        
        performSegue(withIdentifier: "ConfirmAddTagSegue", sender: self)
    }
    
    // MARK:- Image Picker Delegate methods
    func setupImageView(){
        let tapImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddTagViewController.imageViewTapped))
        itemImageView.isUserInteractionEnabled = true
        itemImageView.addGestureRecognizer(tapImageRecognizer)
    }
    
    func imageViewTapped(){
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS{
            self.present(Utilities.showErrorAlert(inDict: IPhoneTryUpload), animated: true, completion: nil)
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
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.imageInfo = info as [String: AnyObject]
        self.itemImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        picker.dismiss(animated: true, completion: nil)
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
    
    // MARK:- Button methods
    func setupButton(){
        // 1. Set the button to gray  by default and disable
        nextButton.setTitleColor(UIColor(red:0.64, green:0.64, blue:0.64, alpha:1.0), for: .disabled)
        nextButton.backgroundColor = UIColor(red:0.80, green:0.82, blue:0.82, alpha:1.0)
        nextButton.isEnabled = false
    }
    
    // MARK:- Text Field Delegate
    
    func setupTextFields(){
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
        
        // Disable the next button if BOTH textfields are empty
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

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
