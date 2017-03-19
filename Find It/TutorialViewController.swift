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
    
    // Class variables
    var descriptionText: String?
    var backgroundColor: UIColor?
    var index:Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.text = descriptionText!
        self.view.backgroundColor = backgroundColor
    }
}
