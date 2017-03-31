//
//  ConfirmAddTagViewController.swift
//  Settings
//
//  Created by Camden Madina on 3/2/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView


class ConfirmAddTagViewController: UIViewController {
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var itemAddedImageView: UIImageView!
    
    var itemNameText:String?
    var itemDescriptionText:String?
    var itemImage:UIImage?
    var imageInfo:[String : AnyObject]?
    
    private var currentUserID:String?
    private var currentUser: FIRDatabaseReference?
    
    private var activityIndicator:NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicator()
        
        loadUser()
        
        loadUI()
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        /*
         let imageUrl          = self.imageInfo?[UIImagePickerControllerReferenceURL] as! NSURL
         let imageName         = imageUrl.lastPathComponent
         let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
         let photoURL          = NSURL(fileURLWithPath: documentDirectory)
         let localPath         = photoURL.appendingPathComponent(imageName!)
         let image             = self.imageInfo?[UIImagePickerControllerOriginalImage]as! UIImage
         let data              = UIImagePNGRepresentation(image)
         */
        
        // Block user iteraction
        self.view.isUserInteractionEnabled = false
        self.activityIndicator?.startAnimating()
        
        // 1. Create local variables for item information
        let key = DataService.dataService.ITEM_REF.childByAutoId().key
        let itemName = itemNameLabel.text
        let itemDescription = itemDescriptionLabel.text
        var itemID = ShortCodeGenerator.getCode(length: 6)
        
        // 2. Check database to make sure no duplicate tags, else create new one
        DataService.dataService.ITEM_REF.observe(.value, with: { (snapshot) in
            if let databaseItems = snapshot.value as? [NSDictionary]{
                for databaseItem in databaseItems{
                    let databaseItemIDString = databaseItem["id"] as! String
                    
                    if itemID == databaseItemIDString {
                        itemID = ShortCodeGenerator.getCode(length: 6)
                    }
                }
            }
        })
        
        // 3. Perform asynchronous call to upload image and tag
        DispatchQueue.global(qos: .userInitiated).async {
            var image = self.imageInfo?[UIImagePickerControllerOriginalImage] as? UIImage
            
            if image == nil{
                image = UIImage(named: "add-image-placeholder")
            }
        
            let imageData = UIImageJPEGRepresentation(image!, 0.8)
            let metadata = FIRStorageMetadata()
            let imagePath = FIRAuth.auth()!.currentUser!.uid + "/\(itemID).jpg"
            metadata.contentType = "image/jpeg"
            
            
            DataService.dataService.STORAGE_REF.child(imagePath).put(imageData!, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error uploading: \(error)")
                    return
                }else{
                    print("SUCCES")
                    let imageURL = (metadata?.downloadURL()?.absoluteString)!
                    let item = ["status": "in-possesion", "id": itemID, "name": itemName!, "description": itemDescription!, "itemImageURL": imageURL]
                    let childUpdates = ["/items/\(key)": item,
                                        "/users/\(self.currentUserID!)/items/\(key)/": item]
                    
                    DataService.dataService.BASE_REF.updateChildValues(childUpdates)
                }
            }
            
            DispatchQueue.main.async {
                // Enable user iteraction
                self.successView.isHidden = false
                self.view.isUserInteractionEnabled = true
                self.activityIndicator?.stopAnimating()
                sleep(2)
                
                // 4. Once image is uploaded, return to tag controller
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func loadUser(){
        self.currentUserID = DataService.dataService.AUTH_REF.currentUser?.uid
        self.currentUser = DataService.dataService.USER_REF.child(currentUserID!)
    }
    
    func loadUI(){
        self.itemImageView.image = self.imageInfo?[UIImagePickerControllerOriginalImage] as? UIImage
        self.itemNameLabel.text = itemNameText!
        self.itemDescriptionLabel.text = itemDescriptionText!
        self.successView.isHidden = true
    }
    
    //MARK:- Utilities for class
    func setupActivityIndicator(){
        // Create a frame size for activity indicator
        let height: CGFloat = 60
        let frame = CGRect(x: (self.view.frame.width - height) / 2, y: (self.view.frame.height - height) / 2, width: height, height: height)
        
        // Instantiate the activity indicator
        self.activityIndicator = NVActivityIndicatorView(frame: frame, type: .ballTrianglePath, color: UIColor(red: 255.0/255.0, green: 125.0/255.0, blue: 125.0/255.0, alpha: 1.0), padding: 0)
        
        // Add it to view
        self.view.addSubview(self.activityIndicator!)
    }
}
