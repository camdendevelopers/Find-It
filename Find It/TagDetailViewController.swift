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
    @IBOutlet weak var itemIdentificationLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    
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
    
    func setupLabels(){
        // Assign variables to text fields
        self.title = "ID " + itemID!
        self.itemNameLabel.text = itemName!
        self.itemDescriptionLabel.text = itemDescription!
        self.itemIdentificationLabel.isHidden = true
        self.itemImageView.image = itemImage!
        self.itemImageView.layer.cornerRadius = self.itemImageView.frame.size.height / 2
        self.itemImageView.clipsToBounds = true
        self.itemImageView.layer.masksToBounds = true
    }
}
