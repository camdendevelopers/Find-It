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
    
    // IBOutlets for class
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var itemAddedImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    // Variables for class
    private var activityIndicator:NVActivityIndicatorView?
    
    var itemNameText:String?
    var itemDescriptionText:String?
    var itemImage:UIImage?
    var imageInfo:[String : AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup activity indicator
        setupActivityIndicator()
    
        // 2. Update UI
        loadUI()
        
        // 3. Setup bars and buttons
        setupBars()
        
        // 4. Setup button
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1. Change status bar color to white for this screen only
        UIApplication.shared.statusBarStyle = .lightContent
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
        
        // 1. Block user interaction and show indicator
        self.view.isUserInteractionEnabled = false
        self.activityIndicator?.startAnimating()
        
        // 2. Create local variables for item information
        let key = DataService.dataService.ITEM_REF.childByAutoId().key
        let itemName = itemNameLabel.text
        let itemDescription = itemDescriptionLabel.text
        var itemID = ShortCodeGenerator.getCode(length: 6)
        
        // 3. Check database to make sure no duplicate tags, else create new one
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
        
        // 4. Perform asynchronous call to upload image and tag
        DispatchQueue.global(qos: .userInitiated).async {
            
            // Create variables
            let image = self.imageInfo?[UIImagePickerControllerOriginalImage] as? UIImage
            let imageData = UIImageJPEGRepresentation(image!, 0.8)
            let metadata = FIRStorageMetadata()
            let imagePath = FIRAuth.auth()!.currentUser!.uid + "/\(itemID).jpg"
            metadata.contentType = "image/jpeg"
            let userID = UserDefaults.standard.value(forKey: "uid") as! String
            
            // Update it to storage
            DataService.dataService.STORAGE_REF.child(imagePath).put(imageData!, metadata: metadata) { (metadata, error) in
                if error != nil {
                    return
                }else{
                    let imageURL = (metadata?.downloadURL()?.absoluteString)!
                    let item = ["status": "in-possesion", "id": itemID, "name": itemName!, "description": itemDescription!, "itemImageURL": imageURL, "itemOwner": userID]
                    let childUpdates = ["/items/\(key)": item,
                                        "/users/\(userID)/items/\(key)/": item]
                    
                    DataService.dataService.BASE_REF.updateChildValues(childUpdates)
                }
            }
            
            // 5. Meanwhile in the main thread
            DispatchQueue.main.async {
                // Enable user iteraction
                self.successView.isHidden = false
                self.view.isUserInteractionEnabled = true
                self.activityIndicator?.stopAnimating()
                sleep(3)
                
                // 4. Once image is uploaded, return to tag controller
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }

    func loadUI(){
        
        // 1. Make image view rounded
        self.itemImageView.layer.cornerRadius = 5
        self.itemImageView.clipsToBounds = true
        self.itemImageView.layer.masksToBounds = true
        
        // 2. Update UI with users details from previous page
        self.itemImageView.image = self.imageInfo?[UIImagePickerControllerOriginalImage] as? UIImage
        self.itemNameLabel.text = itemNameText!
        self.itemDescriptionLabel.text = itemDescriptionText!
        self.successView.isHidden = true
    }
    
    //MARK:- Utilities for class
    
    func setupButton(){
        
        // 1. Add a radius to button to make it round
        self.saveButton.layer.cornerRadius = self.saveButton.frame.size.height / 2
        self.saveButton.clipsToBounds = true
        self.saveButton.layer.masksToBounds = true
    }
    
    func setupActivityIndicator(){
        // 1. Create a frame size for activity indicator
        let height: CGFloat = 60
        let frame = CGRect(x: (self.view.frame.width - height) / 2, y: (self.view.frame.height - height) / 2, width: height, height: height)
        
        // 2. Instantiate the activity indicator
        self.activityIndicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotatePulse, color: kColor4990E2, padding: 0)
        
        // 3. Add it to view
        self.view.addSubview(self.activityIndicator!)
    }
    
    func setupBars(){
        let leftButton:UIButton = UIButton()
        leftButton.setImage(UIImage(named: "backward-icon-white") , for: .normal)
        leftButton.addTarget(self, action: #selector(ConfirmAddTagViewController.backPressed), for: UIControlEvents.touchUpInside)
        leftButton.imageView?.contentMode = .scaleAspectFit
        leftButton.frame = CGRect(x: 0, y: 0, width: 83, height: 30)
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        let barButton = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = barButton
        
        navigationController?.navigationBar.barTintColor = kColor4990E2
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HalisR-Black", size: 16)!, NSForegroundColorAttributeName: UIColor.white]
        
    }
    
    func backPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
}
