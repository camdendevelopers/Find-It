//
//  MyitemsViewController.swift
//  Find It
//
//  Created by Camden Madina on 2/21/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class MyTagsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChangeStatusProtocol{
    
    // IBOutlets for class
    @IBOutlet weak var itemsTableView: UITableView!
    
    // Variables for class
    //private var currentUserID:String?
    //private var currentUser: FIRDatabaseReference?
    private var didLoad:Bool = false
    private var items = [NSDictionary]()
    
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) as! TagCustomTableViewCell
        let row = indexPath.row
        
        // 1. Check if there are items on the list
        if items.count != 0 {
            
            // 2. Create local item variable
            let item = items[row]
            let itemID = item["id"] as? String
            let itemName = item["name"] as? String
            let itemStatus = item["status"] as? String
            let itemImageUrl = item["itemImageURL"] as? String
            
            // Update cell name and id labels
            cell.itemIdentificationLabel.text = itemID!
            cell.itemNameLabel.text = itemName!
            
            // Add a radius to image
            cell.itemImageView.layer.cornerRadius = cell.itemImageView.frame.size.height / 2
            cell.itemImageView.clipsToBounds = true
            cell.itemImageView.layer.masksToBounds = true
            
            // Check if cell is lost or found, and update the status button
            if itemStatus == "in-possesion" {
                cell.statusImageView.image = UIImage(named: "okay-icon")
            }else{
                cell.statusImageView.image = UIImage(named: "lost-icon")
            }
            
            cell.itemImageView.sd_setShowActivityIndicatorView(true)
            cell.itemImageView.sd_setIndicatorStyle(.gray)
            cell.itemImageView.sd_setImage(with: URL(string: itemImageUrl!), placeholderImage: UIImage(named: "default_image_icon"), options: SDWebImageOptions.scaleDownLargeImages)
        }
        
        return cell
    }
    
    // MARK:- Utilities for class
    
    func loadProfileImage(withURLString string:String, completion: (_ image: Data) -> Void){
        if let url = URL(string: string) {
            if let data = NSData(contentsOf: url) as Data?{
                completion(data)
            }
        }
    }
    
    func setupBars(){
        navigationController?.navigationBar.barTintColor = kColor4990E2
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HalisR-Black", size: 16)!, NSForegroundColorAttributeName: UIColor.white]
        tabBarController?.tabBar.barTintColor = UIColor.white
    }
    
    func changeItemStatus() {
        
        // 1. Check which cell was tapped
        let selectedIndex = itemsTableView.indexPathForSelectedRow
        let cell = itemsTableView.cellForRow(at: selectedIndex!) as! TagCustomTableViewCell
        
        // 2. Update that specific cell's status button
        cell.statusImageView.image = UIImage(named: "lost-icon")
    }
    
    func setupTableView(){
        
        // 1. Assign the table view delegates
        self.itemsTableView.delegate = self
        self.itemsTableView.dataSource = self
        
        // 2. Call Firebase to retrieve all user's tag and add them to the table view
        DataService.dataService.CURRENT_USER_REF.child("items").observe(.childAdded, with: { (snapshot) in
            
            // Create item
            let item = snapshot.value as! NSDictionary
            
            
            // Add item to list
            self.items.insert(item, at: 0)
            
            // Add item to table view
            self.itemsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.top)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagDetailSegue"{
            let selectedIndex = itemsTableView.indexPathForSelectedRow!
            let selectedRow = selectedIndex.row
            let cell = itemsTableView.cellForRow(at: selectedIndex) as! TagCustomTableViewCell
            let item = self.items[selectedRow]
            self.tabBarController?.tabBar.isHidden = true
            
            if let destinationViewController = segue.destination as? TagDetailViewController{
                
                //destinationViewController.itemDetails = self.items[selectedRow!]
                destinationViewController.delegate = self
                destinationViewController.itemID = item["id"] as? String
                destinationViewController.itemName = item["name"] as? String
                destinationViewController.itemImage = cell.itemImageView.image
                destinationViewController.itemDescription = item["description"] as? String
            }
        }
    }
}
