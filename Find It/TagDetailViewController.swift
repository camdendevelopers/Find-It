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
    var itemStatus:String?
    var key:String?
    
    // Variabels for class
    var delegate: ChangeStatusProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup labels
        setupLabels()
        
        // 2. Setup image view
        setupImageView()
        
        // 3. Setup button
        setupButton()
        
        // 4. Setup up recognizers
        setupRecognizers()
        
        // 5. Setup bars
        setupBars()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1. Change status bar color to white for this screen only
        UIApplication.shared.statusBarStyle = .lightContent
        
        // 2. Setup button if status has changed
        setupButton()
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
        }else{
            DataService.dataService.ITEM_REF.child(key!).child("status").setValue(ItemStatus.okay.rawValue)
            DataService.dataService.CURRENT_USER_REF.child("items").child(key!).child("status").setValue(ItemStatus.okay.rawValue)
            self.delegate?.changeItemStatus(withStatus: ItemStatus.okay.rawValue)
        }
        
        
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
        
        if itemStatus! == ItemStatus.okay.rawValue{
            self.statusButton.setTitle("REPORT AS LOST", for: .normal)
            self.statusButton.setTitleColor(UIColor.white, for: .normal)
            self.statusButton.backgroundColor = kColorFF7D7D
        }else{
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
        
        let rightButton:UIButton = UIButton()
        rightButton.setTitle("Save", for: .normal)
        rightButton.addTarget(self, action: #selector(TagDetailViewController.savePressed), for: UIControlEvents.touchUpInside)
        rightButton.frame = CGRect(x: 0, y: 0, width: 83, height: 30)
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
        let name = self.itemNameTextField.text
        let description = self.itemDescriptionTextField.text
        
        // 1. Update values if changed
        DataService.dataService.ITEM_REF.child(key!).child("name").setValue(name!)
        DataService.dataService.ITEM_REF.child(key!).child("description").setValue(description!)
        
        self.navigationController?.popViewController(animated: true)
        
    }
}
