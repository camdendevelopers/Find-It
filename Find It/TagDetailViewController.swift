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
    func changeItemStatus()
}

class TagDetailViewController: UIViewController {
    
    // IBOutlets for class
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var itemDescriptionTextField: UITextField!
    @IBOutlet weak var statusButton: UIButton!
    
    
    var itemID:String?
    var itemName:String?
    var itemDescription:String?
    var itemImage:UIImage?
    
    // Variabels for class
    var delegate: ChangeStatusProtocol?
    var itemDetails:NSDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup labels
        setupLabels()
        
        // 2. Setup navigation bars
        setupBars()
        
        // 3. Setup image view
        setupImageView()
        
        // 4. Setup button
        setupButton()
        
        // 5. Setup up recognizers
        setupRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1. Change status bar color to white for this screen only
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        // 1. Return to previous screen
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func statusButtonPressed(_ sender: Any) {
        // 1. Call the delegate of this protocol
        self.delegate?.changeItemStatus()
        
        // 2. Return to previous screen
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK:- Utilties for class
    
    func setupRecognizers(){
        
        // 1. Create a tag screen regonizer
        let screenTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagDetailViewController.screenTapped))
        self.view.addGestureRecognizer(screenTapRecognizer)
    }
    
    func screenTapped(){
        
        // 1. If screen is tapped, resign keyboard for all text fields
        self.itemNameTextField.resignFirstResponder()
        self.itemDescriptionTextField.resignFirstResponder()
    }
    
    func setupImageView(){
        // 1. Make image view rounded
        self.itemImageView.layer.cornerRadius = 5
        self.itemImageView.clipsToBounds = true
        self.itemImageView.layer.masksToBounds = true
    }
    
    func setupButton(){
        // 1. Add a radius to button to make it round
        self.statusButton.layer.cornerRadius = self.statusButton.frame.size.height / 2
        self.statusButton.clipsToBounds = true
        self.statusButton.layer.masksToBounds = true
        
        
        self.statusButton.setTitleColor(UIColor.white, for: .normal)
        self.statusButton.backgroundColor = kColorFF7D7D
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
        
        let rightButton:UIButton = UIButton()
        rightButton.setTitle("Save", for: .normal)
        rightButton.addTarget(self, action: #selector(TagDetailViewController.savePressed), for: UIControlEvents.touchUpInside)
        rightButton.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        
        let rightBarButton = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        let leftBarButton = UIBarButtonItem(customView: leftButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func backPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func savePressed(){
        //ADD EDIT TAG FUNCTIONALITY
        
        /*
        let name = self.itemNameTextField.text
        let description = self.itemDescriptionTextField.text
        
        // 1. Update values if changed
        DataService.dataService.CURRENT_USER_REF.child("email").setValue(name!)
        DataService.dataService.CURRENT_USER_REF.child("phone").setValue(description!)
        
            self.navigationController?.popViewController(animated: true)
        */
    }
}
