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
    @IBOutlet weak var itemIdentificationLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    
    var delegate: ChangeStatusProtocol?
    var itemDetails:NSDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func statusButtonPressed(_ sender: Any) {
        self.delegate?.changeItemStatus()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func setupLabels(){
        self.title = "ID " + (itemDetails?["id"] as? String)!
        self.itemIdentificationLabel.isHidden = true
        self.itemNameLabel.text = itemDetails?["name"] as? String
        self.itemDescriptionLabel.text = itemDetails?["description"] as? String
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
