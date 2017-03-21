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
    
    // Class variables
    var descriptionText: String?
    var backgroundColor: UIColor?
    var backgroundImageName: String?
    var index:Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = descriptionText!
        self.view.backgroundColor = backgroundColor
        self.backgroundImageView.image = UIImage(named: backgroundImageName!)
    }
}
