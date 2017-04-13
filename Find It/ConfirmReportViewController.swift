//
//  ConfirmReportViewController.swift
//  Find It
//
//  Created by Camden Madina on 4/6/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class ConfirmReportViewController: UIViewController {
    
    // IBOutlets for class
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var tagReportedImageView: UIImageView!
    
    // Variables for class
    private var activityIndicator:NVActivityIndicatorView?
    var itemInfo: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup activity indicator
        setupActivityIndicator()
        
        // 2. Load UI with information
        loadUI()
        
        // 3. Setup bars and buttons
        setupBars()
        
        // 4. Setup image view
        setupImageView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1. Change status bar color to white for this screen only
        UIApplication.shared.statusBarStyle = .lightContent
    }

    @IBAction func reportButtonPressed(_ sender: Any) {
        // 1. Block user interaction and show indicator
        self.view.isUserInteractionEnabled = false
        self.activityIndicator?.startAnimating()
        
        // 2. Create asynchronous call to Firebase to create a report
        DispatchQueue.global(qos: .userInitiated).async {
            let key = DataService.dataService.REPORT_REF.childByAutoId().key
            let currentUserID = UserDefaults.standard.value(forKey: "uid") as! String
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy hh:mm:ss +zzzz"
            let dateString = dateFormatter.string(from: date)
            
            
            let report:[String:Any] = ["item": self.itemInfo!, "status": "lost", "createdBy": currentUserID, "createdAt": dateString]
            let childUpdates = ["/reports/\(key)": report,
                                "/users/\(currentUserID)/reports/\(key)/": report]
            
            DataService.dataService.BASE_REF.updateChildValues(childUpdates)
            
            // 3. Meanwhile in the main thread
            DispatchQueue.main.async {
                // Enable user iteraction
                self.successView.isHidden = false
                self.tagReportedImageView.isHidden = false
                self.view.isUserInteractionEnabled = true
                self.activityIndicator?.stopAnimating()
                sleep(3)
                
                // 4. Once image is uploaded, return to tag controller
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func loadUI(){
        // 1. Block user interaction while item info loads
        self.view.isUserInteractionEnabled = false
        self.activityIndicator?.startAnimating()
        self.successView.isHidden = false
        self.tagReportedImageView.isHidden = true
        
        // 2. Create local variables from information
        let foundItemName = itemInfo?["name"] as? String
        let foundItemDescription = itemInfo?["description"] as? String
        let foundItemID = itemInfo?["id"] as? String
        let foundItemOwnerID = itemInfo?["itemOwner"] as? String
        
        // 3. Create Firebase reference for item image
        let itemImageReference = DataService.dataService.STORAGE.reference(withPath: "\(foundItemOwnerID!)/\(foundItemID!).jpg")
        
        // 4. Call Firebase to get item's image url
        itemImageReference.downloadURL(completion: { (url, error) in
            if let error = error{
                print("Error downloading: \(error)")
                return
            }else{
                
                // 5. User item's url to download image
                let data = NSData(contentsOf: url!)
                self.itemImageView.image = UIImage(data: data! as Data)
                self.itemNameLabel.text = foundItemName!
                self.itemDescriptionLabel.text = foundItemDescription!
                self.activityIndicator?.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.successView.isHidden = true
                self.tagReportedImageView.isHidden = true
            }
        })
    }
    
    //MARK:- Utilities for class
    func setupImageView(){
        // 1. Make image view rounded
        self.itemImageView.layer.cornerRadius = 5
        self.itemImageView.clipsToBounds = true
        self.itemImageView.layer.masksToBounds = true
    }
    
    func setupBars(){
        
        let leftButton:UIButton = UIButton()
        leftButton.setImage(UIImage(named: "backward-icon-white") , for: .normal)
        leftButton.imageView?.contentMode = .scaleAspectFit
        leftButton.addTarget(self, action: #selector(ConfirmReportViewController.backPressed), for: UIControlEvents.touchUpInside)
        leftButton.frame = CGRect(x: 0, y: 0, width: 83, height: 30)
        leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
        let barButton = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = barButton
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.barTintColor = kColorE3CC00
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HalisR-Black", size: 16)!, NSForegroundColorAttributeName: UIColor.white]
        
    }
    
    func backPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupActivityIndicator(){
        // 1. Create a frame size for activity indicator
        let height: CGFloat = 60
        let frame = CGRect(x: (self.view.frame.width - height) / 2, y: (self.view.frame.height - height) / 2, width: height, height: height)
        
        // 2. Instantiate the activity indicator
        self.activityIndicator = NVActivityIndicatorView(frame: frame, type: .orbit, color: UIColor.white, padding: 0)
        
        // 3. Add it to view
        self.view.addSubview(self.activityIndicator!)
    }
}
