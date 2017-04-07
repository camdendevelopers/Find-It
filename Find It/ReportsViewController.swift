//
//  ReportsViewController.swift
//  Find It
//
//  Created by Camden Madina on 2/21/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase

class ReportsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var reportsTableView: UITableView!
    
    private var currentUserID:String?
    private var currentUser: FIRDatabaseReference?
    var reports = [NSDictionary]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUser()
        
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath) as! ReportCustomTableViewCell
        let row = indexPath.row
        
        if reports.count != 0{
            let report = reports[row]
            let ownerID = report["owner-id"] as? String
            let itemID = report["id"] as? String
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                let itemImageReference = DataService.dataService.STORAGE.reference(withPath: "\(ownerID!)/\(itemID!).jpg")
                itemImageReference.downloadURL(completion: { (url, error) in
                    if let error = error{
                        print("Error downloading: \(error)")
                        return
                    }else{
                        //let bal = NSData(contentsOf: url!)
                        //let data = NSData(contentsOf: (url?.absoluteURL)!)
                        let data = NSData(contentsOf: url!)
                        cell.itemImageView.image = UIImage(data: data! as Data)
                    }
                })
                
                DispatchQueue.main.async {
                    cell.itemIdentificationLabel.text = report["id"] as? String
                    cell.itemNameLabel.text = report["name"] as? String
                    
                    cell.itemImageView.layer.cornerRadius = cell.itemImageView.frame.size.height / 2
                    cell.itemImageView.clipsToBounds = true
                    cell.itemImageView.layer.masksToBounds = true
                }
            }
        }
        
        return cell
    }
    
    
    
    func setupTableView(){
        reportsTableView.dataSource = self
        reportsTableView.delegate = self
        
        self.currentUser?.child("reports").observe(.childAdded, with: { (snapshot) in
            let report = snapshot.value as! NSDictionary
            self.reports.insert(report, at: 0)
            self.reportsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.top)
        })
    }
    
    func loadUser(){
        self.currentUserID = DataService.dataService.AUTH_REF.currentUser?.uid
        self.currentUser = DataService.dataService.USER_REF.child(currentUserID!)
    }
}
