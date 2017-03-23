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
    var titleText:String?
    var backgroundColor: UIColor?
    var backgroundImageName: String?
    var index:Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundImageView.image = UIImage(named: backgroundImageName!)
        self.descriptionLabel.text = descriptionText
        //self.descriptionLabel.font = UIFont(name: "HalisR-Light", size: 12)
        self.descriptionLabel.textColor = kColor9B9B9B
        
        self.titleLabel.text = titleText
        //self.titleLabel.font = UIFont(name: "HalisR-Black", size: 20)
        self.titleLabel.textColor = kColor4A4A4A
        
    
        self.view.backgroundColor = backgroundColor
        
    }
}
