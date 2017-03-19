//
//  ConfirmAddTagViewController.swift
//  Settings
//
//  Created by Camden Madina on 3/2/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit

class ConfirmAddTagViewController: UIViewController {
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var itemAddedImageView: UIImageView!
    
    var itemNameText:String?
    var itemDescriptionText:String?
    var itemImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemImageView.image = itemImage!
        self.itemNameLabel.text = itemNameText!
        self.itemDescriptionLabel.text = itemDescriptionText!
        self.successView.isHidden = true
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        self.successView.isHidden = false
        //self.navigationController?.popViewController(animated: true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
