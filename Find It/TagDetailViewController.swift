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
    var currentUserID: String?

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
        let itemID = itemDetails?["id"] as? String
        //let status = itemDetails?["status"] as? String
        let itemName = itemDetails?["name"] as? String
        let itemDescription = itemDetails?["description"] as? String
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let itemImageReference = DataService.dataService.STORAGE.reference(withPath: "\(self.currentUserID!)/\(itemID!).jpg")
            itemImageReference.downloadURL(completion: { (url, error) in
                if let error = error{
                    print("Error downloading: \(error)")
                    return
                }else{
                    //let bal = NSData(contentsOf: url!)
                    //let data = NSData(contentsOf: (url?.absoluteURL)!)
                    let data = NSData(contentsOf: url!)
                    self.itemImageView.image = UIImage(data: data! as Data)
                }
            })
            
            DispatchQueue.main.async {
                self.title = "ID " + itemID!
                self.itemIdentificationLabel.isHidden = true
                self.itemNameLabel.text = itemName!
                self.itemDescriptionLabel.text = itemDescription!
                self.itemImageView.layer.cornerRadius = self.itemImageView.frame.size.height / 2
                self.itemImageView.clipsToBounds = true
                self.itemImageView.layer.masksToBounds = true
                
            }
        }
        
    }
}
