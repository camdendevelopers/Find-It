//
//  ReportsViewController.swift
//  Find It
//
//  Created by Camden Madina on 2/21/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ReportsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // IBOutlets for class
    @IBOutlet weak var reportsTableView: UITableView!
    
    // Variables for class
    private var reports = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup table view
        setupTableView()
        
        // 2. Setup navigation bar and tab bar
        setupBars()
    }
    
    // MARK:- Table view delegate methods
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
            let item = report["item"] as? NSDictionary
            let itemID = item?["id"] as? String
            let itemName = item?["name"] as? String
            let itemImageURL = item?["itemImageURL"] as? String
            
            cell.itemIdentificationLabel.text = itemID!
            cell.itemNameLabel.text = itemName!
            
            cell.itemImageView.layer.cornerRadius = cell.itemImageView.frame.size.height / 2
            cell.itemImageView.clipsToBounds = true
            cell.itemImageView.layer.masksToBounds = true
            
            cell.itemImageView.sd_setShowActivityIndicatorView(true)
            cell.itemImageView.sd_setIndicatorStyle(.gray)
            cell.itemImageView.sd_setImage(with: URL(string: itemImageURL!), placeholderImage: UIImage(named: "default_image_icon"), options: SDWebImageOptions.scaleDownLargeImages)
        }
        
        return cell
    }
    
    // MARK:- Utilities for class
    
    func setupBars(){
        navigationController?.navigationBar.barTintColor = kColorE3CC00
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HalisR-Black", size: 16)!, NSForegroundColorAttributeName: UIColor.white]
        tabBarController?.tabBar.barTintColor = UIColor.white
    }
    
    func setupTableView(){
        reportsTableView.dataSource = self
        reportsTableView.delegate = self
        
        DataService.dataService.CURRENT_USER_REF.child("reports").observe(.childAdded, with: { (snapshot) in
            let report = snapshot.value as! NSDictionary
            self.reports.insert(report, at: 0)
            self.reportsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.top)
        })
    }
}
