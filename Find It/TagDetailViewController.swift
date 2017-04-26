//
//  TagDetailViewController.swift
//  Find It
//
//  Created by Camden Madina on 3/15/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase

protocol ChangeStatusProtocol {
    func changeItemStatus(withStatus: String)
}

class TagDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // IBOutlets for class
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemDescriptionTextField: UITextField!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var itemDescriptionTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemNameTextFieldLine: UIView!
    @IBOutlet weak var itemDescriptionTextFieldLine: UIView!
    @IBOutlet weak var itemStatusNotificationView: UIView!
    @IBOutlet weak var itemStatusNotificationViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemImageEditableView: UIImageView!
    @IBOutlet weak var itemStatusNotificationViewLabel: UILabel!
    
    
    private var rightButton: UIButton?
    private var imageInfo: [String: AnyObject]?
    private lazy var imagePicker = UIImagePickerController()
    private lazy var changedImaged = false
    
    var itemID:String?
    var itemName:String?
    var itemDescription:String?
    var itemImage:UIImage?
    var itemStatus:String?
    var key:String?
    var phone:String?
    
    // Variabels for class
    var delegate: ChangeStatusProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup labels
        setupLabels()
        
        // 2. Setup image view
        setupImageView()
        
        // 3. Setup button
        setupUI()
        
        // 4. Setup up recognizers
        setupRecognizers()
        
        // 5. Setup bars
        setupBars()
        
        // 6. Setup text fields
        setupTextFields()
        
        // 7. Initiliaze keyboard size functionality
        initializeKeyboardNotifications()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1. Change status bar color to white for this screen only
        UIApplication.shared.statusBarStyle = .lightContent
        
        // 2. Setup button if status has changed
        setupUI()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        // 1. Return to previous screen
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func statusButtonPressed(_ sender: Any) {
        
        // 1. Call the delegate of this protocol
        if itemStatus == ItemStatus.okay.rawValue{
            DataService.dataService.ITEM_REF.child(key!).child("status").setValue(ItemStatus.lost.rawValue)
            DataService.dataService.CURRENT_USER_REF.child("items").child(key!).child("status").setValue(ItemStatus.lost.rawValue)
            self.delegate?.changeItemStatus(withStatus: ItemStatus.lost.rawValue)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                
                self.itemStatusNotificationViewTopConstraint.constant += self.itemStatusNotificationView.frame.height
                self.view.layoutIfNeeded()
                
            }, completion: { (Bool) in
                _ = self.navigationController?.popViewController(animated: true)
            })
            
        }else if itemStatus == ItemStatus.found.rawValue{
            
            DataService.dataService.CURRENT_USER_REF.child("items").child(self.key!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if let report = value?["report"] as? NSDictionary{
                    if let reportCreatorID = report["createdBy"] as? String, let reportKey = report["key"] as? String{
                        
                        DataService.dataService.REPORT_REF.child(reportKey).child("status").setValue("found")
                        DataService.dataService.USER_REF.child(reportCreatorID).child("reports").child(reportKey).child("status").setValue("found")
                    }
                }
            })
            
            DataService.dataService.ITEM_REF.child(key!).child("status").setValue(ItemStatus.okay.rawValue)
            DataService.dataService.CURRENT_USER_REF.child("items").child(key!).child("status").setValue(ItemStatus.okay.rawValue)
            DataService.dataService.CURRENT_USER_REF.child("items").child(key!).child("report").removeValue()
            
            self.delegate?.changeItemStatus(withStatus: ItemStatus.okay.rawValue)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            
                self.itemStatusNotificationViewTopConstraint.constant -= self.itemStatusNotificationView.frame.height
                self.view.layoutIfNeeded()
            }, completion: { (Bool) in
                _ = self.navigationController?.popViewController(animated: true)
            })
            
        }else{
            
            DataService.dataService.ITEM_REF.child(key!).child("status").setValue(ItemStatus.okay.rawValue)
            DataService.dataService.CURRENT_USER_REF.child("items").child(key!).child("status").setValue(ItemStatus.okay.rawValue)
            self.delegate?.changeItemStatus(withStatus: ItemStatus.okay.rawValue)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
    
                self.itemStatusNotificationViewTopConstraint.constant -= self.itemStatusNotificationView.frame.height
                self.view.layoutIfNeeded()
            }, completion: { (Bool) in
                _ = self.navigationController?.popViewController(animated: true)
            })
        }

    }
    
    // MARK:- Image Picker Delegate methods
    func setupImageView(){
        
        // 1. Make image view rounded
        self.itemImageView.layer.cornerRadius = 5
        self.itemImageView.clipsToBounds = true
        self.itemImageView.layer.masksToBounds = true
        
        // 2. Create a reconizer for image
        let tapImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagDetailViewController.imageViewTapped))
        itemImageView.isUserInteractionEnabled = false
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
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker, animated: true, completion: nil)
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
        
        // 1. Assign info to class image info
        self.imageInfo = info as [String: AnyObject]
        self.itemImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.changedImaged = true
        
        // 2. Return to app
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // 1. Image picker was canceled, return to app
        picker.dismiss(animated: true, completion: nil)
    }

    
    //Methods for keyboards
    func initializeKeyboardNotifications(){
        
        // 1. Add notification obeservers that will alert app when keyboard displays
        NotificationCenter.default.addObserver(self, selector: #selector(TagDetailViewController.keyboardWillShow(notification :)), name:NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(TagDetailViewController.keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    func keyboardWillShow(notification: Notification) {
        
        // 1. Check that notification dictionary is available
        if let userInfo = notification.userInfo{
            
            // 2. Obtain keyboard size and predictive search height
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let offset = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                
                if self.itemDescriptionTextField.frame.maxY > (self.view.frame.height - keyboardSize.height){
                    // 3. Animate the text fields up
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        // If no predictive search is displayed
                        if keyboardSize.height == offset.height{
                            self.itemDescriptionTextFieldBottomConstraint.constant = (keyboardSize.height) - (self.view.frame.height - self.statusButton.frame.origin.y) + 15
                        }else{
                            self.itemDescriptionTextFieldBottomConstraint.constant = (keyboardSize.height + offset.height) - (self.view.frame.height - self.statusButton.frame.origin.y) + 15
                        }
                    })
                }
            }
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.itemDescriptionTextFieldBottomConstraint.constant = 100
        }
    }
    
    // MARK:- Utilties for class
    
    func setupRecognizers(){
        
        // 1. Create a tag screen regonizer
        let screenTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagDetailViewController.screenTapped))
        self.view.addGestureRecognizer(screenTapRecognizer)
        
        let itemStatusNotificationViewRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagDetailViewController.itemStatusNotificationViewPressed))
        self.view.addGestureRecognizer(itemStatusNotificationViewRecognizer)
    }
    
    func itemStatusNotificationViewPressed(){
        if let url = URL(string: "tel://\(self.phone!)") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
    
    func screenTapped(){
        
        // 1. If screen is tapped, resign keyboard for all text fields
        self.itemNameTextField.resignFirstResponder()
        self.itemDescriptionTextField.resignFirstResponder()
    }
    
    func setupUI(){
        // 1. Add a radius to button to make it round
        self.statusButton.layer.cornerRadius = self.statusButton.frame.size.height / 2
        self.statusButton.clipsToBounds = true
        self.statusButton.layer.masksToBounds = true
        
        if itemStatus! == ItemStatus.okay.rawValue{
            self.itemStatusNotificationViewTopConstraint.constant = -self.itemStatusNotificationView.frame.height
            
            self.statusButton.setTitle("REPORT AS LOST", for: .normal)
            self.statusButton.setTitleColor(UIColor.white, for: .normal)
            self.statusButton.backgroundColor = kColorFF7D7D
            
        }else if itemStatus! == ItemStatus.found.rawValue{
            self.itemStatusNotificationViewTopConstraint.constant = 0
            self.itemStatusNotificationView.backgroundColor = kColorE3CC00
            
            
            DataService.dataService.CURRENT_USER_REF.child("items").child(self.key!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if let report = value?["report"] as? NSDictionary{
                    if let reportCreatorID = report["createdBy"] as? String{
                        
                        DataService.dataService.USER_REF.child(reportCreatorID).observeSingleEvent(of: .value, with: { (snapshot) in
                            let reportOwner = snapshot.value as? NSDictionary
                            
                            if let firstName = reportOwner?["firstName"] as? String{
                                self.phone = reportOwner?["phone"] as? String
                                
                                self.itemStatusNotificationViewLabel.text = "\(firstName) has found your item.\nContact \(firstName) at \(Utilities.format(phoneNumber: self.phone!)!)"
                            }
                        })
                    }
                }
            })
    
            self.statusButton.setTitle("REPORT AS FOUND", for: .normal)
            self.statusButton.setTitleColor(UIColor.white, for: .normal)
            self.statusButton.backgroundColor = kColor4990E2
            
        }else{
            self.itemStatusNotificationViewTopConstraint.constant = 0
            self.itemStatusNotificationView.backgroundColor = kColorFF7D7D
            self.itemStatusNotificationViewLabel.text = "You've marked this item as lost."
            
            self.statusButton.setTitle("REPORT AS FOUND", for: .normal)
            self.statusButton.setTitleColor(UIColor.white, for: .normal)
            self.statusButton.backgroundColor = kColor4990E2
            
        }
    }
    
    func setupLabels(){
        // Assign variables to text fields
        self.title = "ID " + itemID!
        self.itemNameTextField.text = itemName!
        self.itemDescriptionTextField.text = itemDescription!
        self.itemImageView.image = itemImage!
        self.itemImageView.layer.cornerRadius = self.itemImageView.frame.size.height / 2
        self.itemImageView.clipsToBounds = true
        self.itemImageView.layer.masksToBounds = true
    }
    
    func setupBars(){
        let leftButton:UIButton = UIButton()
        leftButton.setImage(UIImage(named: "backward-icon-white") , for: .normal)
        leftButton.addTarget(self, action: #selector(TagDetailViewController.backPressed), for: UIControlEvents.touchUpInside)
        leftButton.imageView?.contentMode = .scaleAspectFit
        leftButton.frame = CGRect(x: 0, y: 0, width: 83, height: 30)
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        rightButton = UIButton()
        rightButton?.setTitle("Edit", for: .normal)
        rightButton?.addTarget(self, action: #selector(TagDetailViewController.actionButtonPressed), for: UIControlEvents.touchUpInside)
        rightButton?.frame = CGRect(x: 0, y: 0, width: 83, height: 30)
        rightButton?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        
        let rightBarButton = UIBarButtonItem(customView: rightButton!)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func setupTextFields(){
        itemNameTextField.isEnabled = false
        itemDescriptionTextField.isEnabled = false
        
        
        itemNameTextFieldLine.isHidden = true
        itemDescriptionTextFieldLine.isHidden = true
    }
    
    func backPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func actionButtonPressed(){
        
        // If the button was previously edit, change it save and update UI elements to allow edits
        if rightButton?.title(for: .normal) == "Edit"{
            
            // 1. Enable the text fields
            itemNameTextField.isEnabled = true
            itemDescriptionTextField.isEnabled = true
            
            // 2. Enable the image view to be tapped and unhide indicator
            itemImageView.isUserInteractionEnabled = true
            itemImageEditableView.isHidden = false
            
            // 3. Display the lines underneath text fields
            itemNameTextFieldLine.isHidden = false
            itemDescriptionTextFieldLine.isHidden = false
            
            // 4. Change the button titles
            rightButton?.setTitle("Save", for: .normal)
        }else if rightButton?.title(for: .normal) == "Save"{
            
            // 4. Perform asynchronous call to upload image and tag
            DispatchQueue.global(qos: .userInitiated).async {
                
                let name = self.itemNameTextField.text
                let description = self.itemDescriptionTextField.text
                
                if self.changedImaged == true {
                    let image = self.imageInfo?[UIImagePickerControllerOriginalImage] as? UIImage
                    let imageData = UIImageJPEGRepresentation(image!, 0.8)
                    let metadata = FIRStorageMetadata()
                    let imagePath = FIRAuth.auth()!.currentUser!.uid + "/\(self.itemID!).jpg"
                    metadata.contentType = "image/jpeg"
                    
                    // Update it to storage
                    DataService.dataService.STORAGE_REF.child(imagePath).put(imageData!, metadata: metadata) { (metadata, error) in
                        if error != nil {
                            return
                        }else{
                            let imageURL = (metadata?.downloadURL()?.absoluteString)!
                            
                            DataService.dataService.ITEM_REF.child(self.key!).child("name").setValue(name!)
                            DataService.dataService.ITEM_REF.child(self.key!).child("description").setValue(description!)
                            DataService.dataService.ITEM_REF.child(self.key!).child("itemImageURL").setValue(imageURL)
                            
                            DataService.dataService.CURRENT_USER_REF.child("items").child(self.key!).child("name").setValue(name!)
                            DataService.dataService.CURRENT_USER_REF.child("items").child(self.key!).child("description").setValue(description!)
                            DataService.dataService.CURRENT_USER_REF.child("items").child(self.key!).child("itemImageURL").setValue(imageURL)
                            
                            self.changedImaged = false
                        }
                    }
                }else{
                    DataService.dataService.ITEM_REF.child(self.key!).child("name").setValue(name!)
                    DataService.dataService.ITEM_REF.child(self.key!).child("description").setValue(description!)
                    
                    DataService.dataService.CURRENT_USER_REF.child("items").child(self.key!).child("name").setValue(name!)
                    DataService.dataService.CURRENT_USER_REF.child("items").child(self.key!).child("description").setValue(description!)
                }
                
                self.delegate?.changeItemStatus(withStatus: "")
                // 5. Meanwhile in the main thread
                DispatchQueue.main.async {
                    
                    // 1. Disable the text fields
                    self.itemNameTextField.isEnabled = false
                    self.itemDescriptionTextField.isEnabled = false
                    
                    // 2. Disable the image view to be tapped
                    self.itemImageView.isUserInteractionEnabled = false
                    self.itemImageEditableView.isHidden = true
                    
                    // 3. Hide the lines underneath text fields
                    self.itemNameTextFieldLine.isHidden = true
                    self.itemDescriptionTextFieldLine.isHidden = true
                    
                    // 4. Change the button titles
                    self.rightButton?.setTitle("Edit", for: .normal)
                }
            }
        }
    }
}
