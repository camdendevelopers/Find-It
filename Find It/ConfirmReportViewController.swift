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
    @IBOutlet weak var itemIdentificationLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!

    var itemNameText:String?
    var itemDescriptionText:String?
    var itemImage:UIImage?
    var imageInfo:[String : AnyObject]?
    
    var itemInfo: NSDictionary?
    
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

    @IBAction func reportButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func loadUser(){
        self.currentUserID = DataService.dataService.AUTH_REF.currentUser?.uid
        self.currentUser = DataService.dataService.USER_REF.child(currentUserID!)
    }
    
    func loadUI(){
        //self.itemImageView.image = self.imageInfo?[UIImagePickerControllerOriginalImage] as? UIImage
        self.itemIdentificationLabel.text = itemInfo?.value(forKey: "id") as? String
        self.itemNameLabel.text = itemInfo?.value(forKey: "name") as? String
        self.itemDescriptionLabel.text = itemInfo?.value(forKey: "description") as? String
        //self.successView.isHidden = true
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
