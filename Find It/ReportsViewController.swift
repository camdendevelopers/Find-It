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
    private var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup table view
        setupTableView()
        
        // 2. Setup navigation bar and tab bar
        setupBars()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1. Change status bar color to white for this screen only
        UIApplication.shared.statusBarStyle = .lightContent
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
        
        
        let report = reports[row]
        let createdAt = report["createdAt"] as? String
        let item = report["item"] as? NSDictionary
        let itemID = item?["id"] as? String
        let itemName = item?["name"] as? String
        let itemImageURL = item?["itemImageURL"] as? String
        let reportStatus = report["status"] as? String
        
        DispatchQueue.global(qos: .userInitiated).async {
            cell.reportedAtLabel.text = Utilities.formatTimestamp(time: createdAt!)
            
            DispatchQueue.main.async {
                cell.itemIdentificationLabel.text = itemID!
                cell.itemNameLabel.text = itemName!
                
                if reportStatus! == "lost"{
                    cell.reportStatusLabel.text = "REPORTED"
                    cell.reportStatusLabel.backgroundColor = kColorFF7D7D
                }else{
                    cell.reportStatusLabel.text = "RETURNED"
                    cell.reportStatusLabel.backgroundColor = kColor4990E2
                }
                
                cell.reportStatusLabel.layer.cornerRadius = 2
                cell.reportStatusLabel.clipsToBounds = true
                cell.reportStatusLabel.layer.masksToBounds = true
                
                cell.itemImageView.layer.cornerRadius = cell.itemImageView.frame.size.height / 2
                cell.itemImageView.clipsToBounds = true
                cell.itemImageView.layer.masksToBounds = true
                
                cell.itemImageView.sd_setShowActivityIndicatorView(true)
                cell.itemImageView.sd_setIndicatorStyle(.gray)
                cell.itemImageView.sd_setImage(with: URL(string: itemImageURL!), placeholderImage: UIImage(named: "default_image_icon"), options: SDWebImageOptions.cacheMemoryOnly)
            }
        }
        return cell
    }
    
    // MARK:- Utilities for class
    
    func getReports(){
        
        // 1. Empty out report array before fetching new one
        self.reports = []
        
        // 2. Call Firebase to retrive all user's tag and add them to the table view
        DataService.dataService.CURRENT_USER_REF.child("reports").observe(.childAdded, with: { (snapshot) in
            let report = snapshot.value as! NSDictionary
            
            if Utilities.isItemInArray(item: report, array: self.reports) == false {
                self.reports.insert(report, at: 0)
                self.reportsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.middle)
            }
        })
    }
    
    @objc func didRefresh(refreshControl: UIRefreshControl) {
        self.getReports()
        self.reportsTableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func setupBars(){
        navigationController?.navigationBar.barTintColor = kColorE3CC00
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.font.rawValue: UIFont(name: "HalisR-Black", size: 16)!, NSAttributedString.Key.foregroundColor.rawValue: UIColor.white])
        tabBarController?.tabBar.barTintColor = UIColor.white
    }
    
    func setupTableView(){
        // 1. Assign the table view delegate
        reportsTableView.dataSource = self
        reportsTableView.delegate = self
        
        // 2. Setup refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
        reportsTableView.insertSubview(refreshControl!, at: 0)
        
        // 3. Retrive reports from Firebase
        self.getReports()
        
        
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
