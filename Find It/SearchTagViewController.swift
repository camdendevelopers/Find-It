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
    
    // IBOutlets for class
    @IBOutlet weak var itemSearchTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    // Variables for class
    var itemInfo: NSDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        // 1. Return to previous screen
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        
        // 1. Create local variable from text field
        let itemIdentification = itemSearchTextField.text
        
        // 2. Check that text field is not empty and that it is the correct lenght
        guard itemIdentification != "", (itemIdentification?.characters.count)! == 6 else{
            present(Utilities.showErrorAlert(inDict: ["title": "Ooops", "message": "You need to enter a valid ID"]), animated: true, completion: nil)
            return
        }
        
        // 3. Create a reference to search the database
        let itemsQuery = DataService.dataService.ITEM_REF.queryOrdered(byChild: "id").queryEqual(toValue: itemIdentification!)
        
        // 4. Search for item from tag
        itemsQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Extract the data from the retrieved snapshot
            if let result = snapshot.value as? NSDictionary {
                
                // Get all items from the array
                if let items = result.allValues as? [NSDictionary]{
                    
                    // Assign the item info found to the iteminfo found
                    self.itemInfo = items[0]
                    self.performSegue(withIdentifier: "ConfirmReportSegue", sender: self)
                }
            }else{
                
                // Present if no tag was found
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
