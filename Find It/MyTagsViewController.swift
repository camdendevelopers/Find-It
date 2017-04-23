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
    private var didLoad:Bool = false
    private var items = [NSDictionary]()
    private var refreshControl: UIRefreshControl?
    
    private let tableViewHeaderTitles = ["LOST ITEMS", "FOUND ITEMS"]
    private var lostItems = [NSDictionary]()
    private var foundItems = [NSDictionary]()
    
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
    
    override func didReceiveMemoryWarning() {
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewHeaderTitles.count
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case TableViewSections.lost.rawValue:
            return tableViewHeaderTitles[TableViewSections.lost.rawValue]
        default:
            return tableViewHeaderTitles[TableViewSections.found.rawValue]
        }
    }
 
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = kColor4A4A4A
        header.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
        //header.textLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .left
    }
 
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case TableViewSections.lost.rawValue:
            return self.lostItems.count
        case TableViewSections.found.rawValue:
            return self.foundItems.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) as! TagCustomTableViewCell
        let row = indexPath.row
        
        // 1. Check if there are items on the list
        if lostItems.count != 0 || foundItems.count != 0 {
            var item:NSDictionary = [:]
            
            switch indexPath.section {
            case TableViewSections.lost.rawValue:
                item = lostItems[row]
            case TableViewSections.found.rawValue:
                item = foundItems[row]
            default:
                print("FUCK")
            }
            
            
            // 2. Create local item variable
            //let item = items[row]
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
            if itemStatus == ItemStatus.okay.rawValue {
                cell.statusImageView.image = UIImage(named: "okay-icon")
            }else if itemStatus == ItemStatus.found.rawValue{
                cell.statusImageView.image = UIImage(named: "warning-icon")
            }else{
                cell.statusImageView.image = UIImage(named: "lost-icon")
            }
            
            cell.itemImageView.sd_setShowActivityIndicatorView(true)
            cell.itemImageView.sd_setIndicatorStyle(.gray)
            cell.itemImageView.sd_setImage(with: URL(string: itemImageUrl!), placeholderImage: UIImage(named: "default_image_icon"), options: SDWebImageOptions.scaleDownLargeImages)
 
        }

        return cell
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedSection = indexPath.section
            let selectedRow = indexPath.row
            var item:NSDictionary = [:]
            
            switch selectedSection {
            case TableViewSections.lost.rawValue:
                item = self.lostItems[selectedRow]
            default:
                item = self.foundItems[selectedRow]
            }
            
            let itemKey = item["key"] as! String
            DispatchQueue.global(qos: .userInitiated).async {
                
                DataService.dataService.ITEM_REF.child(itemKey).removeValue()
                DataService.dataService.CURRENT_USER_REF.child("items").child(itemKey).removeValue()
               
                // 5. Meanwhile in the main thread
                DispatchQueue.main.async {
                    
                    // Delete the row from the data source
                    switch selectedSection {
                    case TableViewSections.lost.rawValue:
                        self.lostItems.remove(at: selectedRow)
                    default:
                        self.foundItems.remove(at: selectedRow)
                    }
                    
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    // MARK:- Utilities for class
    
    func getTags(){
        // 1. Empty out array before fetching new ones
        self.lostItems = []
        self.foundItems = []
        
        
        // 2. Call Firebase to retrieve all user's tag and add them to the table view
        DataService.dataService.CURRENT_USER_REF.child("items").observe(.childAdded, with: { (snapshot) in
            
            // Create item
            let item = snapshot.value as! NSDictionary
            let status = item["status"] as! String
            
            if status == ItemStatus.lost.rawValue && self.isItemInArray(item: item, array: self.lostItems) == false{
                self.lostItems.insert(item, at: 0)
                self.itemsTableView.insertRows(at: [IndexPath(row: 0, section: TableViewSections.lost.rawValue)], with: UITableViewRowAnimation.middle)
            }else if status == ItemStatus.okay.rawValue && self.isItemInArray(item: item, array: self.foundItems) == false{
                self.foundItems.insert(item, at: 0)
                self.itemsTableView.insertRows(at: [IndexPath(row: 0, section: TableViewSections.found.rawValue)], with: UITableViewRowAnimation.middle)
            }
        })
        self.itemsTableView.reloadData()
 
    }
    
    private func isItemInArray(item: NSDictionary, array: [NSDictionary]) -> Bool{
        var result:Bool = false
        
        for dict in array{
            if item == dict{
                result = true
            }
        }
        
        return result
    }
    
    func setupBars(){
        navigationController?.navigationBar.barTintColor = kColor4990E2
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HalisR-Black", size: 16)!, NSForegroundColorAttributeName: UIColor.white]
        tabBarController?.tabBar.barTintColor = UIColor.white
    }
    
    func changeItemStatus(withStatus: String) {
        
        // 1. Check which cell was tapped
        let selectedIndex = itemsTableView.indexPathForSelectedRow
        let cell = itemsTableView.cellForRow(at: selectedIndex!) as! TagCustomTableViewCell
        
        // 2. Update that specific cell's status button
        if withStatus == ItemStatus.okay.rawValue {
            cell.statusImageView.image = UIImage(named: "okay-icon")
        }else{
            cell.statusImageView.image = UIImage(named: "lost-icon")
        }
        
        // 3. Reload data to update values visually
        self.getTags()
    }
    
    func setupTableView(){
        
        // 1. Assign the table view delegates
        self.itemsTableView.delegate = self
        self.itemsTableView.dataSource = self
        
        // 2. Setup refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(MyTagsViewController.didRefresh), for: .valueChanged)
        itemsTableView.insertSubview(refreshControl!, at: 0)
        
        // 3. Retrive tags from Firebase
        self.getTags()
    }
    
    func didRefresh(refreshControl: UIRefreshControl){
        self.getTags()
        self.refreshControl?.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagDetailSegue"{
            self.tabBarController?.tabBar.isHidden = true
            let selectedIndex = itemsTableView.indexPathForSelectedRow!
            let selectedSection = selectedIndex.section
            let selectedRow = selectedIndex.row
            let cell = itemsTableView.cellForRow(at: selectedIndex) as! TagCustomTableViewCell
            //let item = self.items[selectedRow]
            var item:NSDictionary = [:]
            
            switch selectedSection {
            case TableViewSections.lost.rawValue:
                item = self.lostItems[selectedRow]
            default:
                item = self.foundItems[selectedRow]
            }
            
            if let destinationViewController = segue.destination as? TagDetailViewController{
                
                destinationViewController.delegate = self
                destinationViewController.itemID = item["id"] as? String
                destinationViewController.itemName = item["name"] as? String
                destinationViewController.itemImage = cell.itemImageView.image
                destinationViewController.itemDescription = item["description"] as? String
                destinationViewController.key = item["key"] as? String
                destinationViewController.itemStatus = item["status"] as? String
            }
        }
    }
}
