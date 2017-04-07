//
//  SearchTagViewController.swift
//  Find It
//
//  Created by Camden Madina on 4/6/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase

class SearchTagViewController: UIViewController {
    @IBOutlet weak var itemSearchTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var itemInfo: NSDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()

    
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        let itemIdentification = itemSearchTextField.text
        
        
        guard itemIdentification != "", (itemIdentification?.characters.count)! == 6 else{
            present(Utilities.showErrorAlert(inDict: ["title": "Ooops", "message": "You need to enter a valid ID"]), animated: true, completion: nil)
            return
        }
        
        let itemsQuery = DataService.dataService.ITEM_REF.queryOrdered(byChild: "id").queryEqual(toValue: itemIdentification!)
        
        itemsQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.value as? NSDictionary {
                if let items:NSArray = result.allValues as NSArray{
                    
                    self.itemInfo = items.object(at: 0) as? NSDictionary
                    self.performSegue(withIdentifier: "ConfirmReportSegue", sender: self)
                }
            }else{
                self.present(Utilities.showErrorAlert(inDict: ["title": "Could Not Find Tag", "message": "Couldn't find a match. Try again?"]), animated: true, completion: nil)
            }
        })
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConfirmReportSegue"{
            if let destinationViewController = segue.destination as? ConfirmReportViewController{
                destinationViewController.itemInfo = self.itemInfo!
            }
        }
    }
}
