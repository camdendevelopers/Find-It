//
//  SearchTagViewController.swift
//  Find It
//
//  Created by Camden Madina on 4/6/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit

class SearchTagViewController: UIViewController {
    @IBOutlet weak var itemSearchTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

    
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        let itemIdentification = itemSearchTextField.text
        
        guard itemIdentification != "", (itemIdentification?.characters.count)! < 6 else{
            present(Utilities.showErrorAlert(inDict: ["title": "Ooops", "message": "You need to enter a valid ID"]), animated: true, completion: nil)
            return
        }
        
        //Search mechanism
        performSegue(withIdentifier: "ConfirmReportSegue", sender: self)
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
