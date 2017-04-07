//
//  TutorialViewController.swift
//  Find It
//
//  Created by Camden Madina on 2/22/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    // Class IBOutlets
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // Class variables
    var descriptionText: String?
    var backgroundImageName: String?
    var titleText:String?
    var backgroundColor: UIColor?
    var index:Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Change description label text and image
        self.backgroundImageView.image = UIImage(named: backgroundImageName!)
        self.descriptionLabel.text = descriptionText
        self.descriptionLabel.textColor = kColor9B9B9B
        
        // 2. Change title text
        self.titleLabel.text = titleText
        self.titleLabel.textColor = kColor4A4A4A
        
        // 3. Change background image
        self.view.backgroundColor = backgroundColor
    }
}
