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
    
    // MARK:- IBOutlets for class
    @IBOutlet weak var itemsTableView: UITableView!
    
    // MARK:- Variables for class
    private var refreshControl: UIRefreshControl?
    private lazy var tableViewHeaderTitles = ["LOST ITEMS", "FOUND ITEMS"]
    private lazy var lostItems = [NSDictionary]()
    private lazy var foundItems = [NSDictionary]()
    
    // MARK:- Loading method calls
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
    
    // MARK:- Table View Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        
        // Returns 2
        return tableViewHeaderTitles.count
    }
 
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        // 1. Make sure there is a header to show
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        // 2. Create a small divider at the bottom of the header view fram
        let divider = UIView(frame: CGRect(x: header.frame.origin.x, y: header.frame.height - 1, width: header.frame.width, height: 1))
        divider.backgroundColor = kColorD8D8D8
        
        // 3. Modify header label text properties
        header.textLabel?.textColor = kColor4A4A4A
        header.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .left
        header.addSubview(divider)
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // 1. Switch between sections
        switch section {
        case TableViewSections.lost.rawValue:
            
            // If there are items in lost items array, return "LOST ITEMS"
            return tableViewHeaderTitles[TableViewSections.lost.rawValue]
        default:
            
            // If there are items in found items array, return "FOUND ITEMS"
            return tableViewHeaderTitles[TableViewSections.found.rawValue]
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 1. Switch between section
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
                print("Empty lists")
            }
            
            
            // 2. Create local item variable
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
            cell.itemImageView.sd_setImage(with: URL(string: itemImageUrl!), placeholderImage: UIImage(named: "default_image_icon"), options: SDWebImageOptions.cacheMemoryOnly)
        }

        return cell
    }

    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
   
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // 1. If user swipes to delete
        if editingStyle == .delete {
            
            // 2. Create local variables for the section and selected row
            let selectedSection = indexPath.section
            let selectedRow = indexPath.row
            var item:NSDictionary = [:]
            
            // 3. Retrieve item info in selected cell
            switch selectedSection {
            case TableViewSections.lost.rawValue:
                item = self.lostItems[selectedRow]
            default:
                item = self.foundItems[selectedRow]
            }
            
            // 4. Delete item from Firebase with item key
            let itemKey = item["key"] as! String
            DispatchQueue.global(qos: .userInitiated).async {
                
                DataService.dataService.ITEM_REF.child(itemKey).removeValue()
                DataService.dataService.CURRENT_USER_REF.child("items").child(itemKey).removeValue()
               
                // 5. Meanwhile in the main thread
                DispatchQueue.main.async {
                    
                    //  6. Delete the row from the data source
                    switch selectedSection {
                    case TableViewSections.lost.rawValue:
                        self.lostItems.remove(at: selectedRow)
                    default:
                        self.foundItems.remove(at: selectedRow)
                    }
                    
                    // 7 . Delete the row from the table view
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
            
            // Check the status of item and add it to appropriate data source array
            if (status == ItemStatus.lost.rawValue || status == ItemStatus.found.rawValue) && Utilities.isItemInArray(item: item, array: self.lostItems) == false{
                
                // Add it to lost items array and insert in lost section
                self.lostItems.insert(item, at: 0)
                self.itemsTableView.insertRows(at: [IndexPath(row: 0, section: TableViewSections.lost.rawValue)], with: UITableViewRowAnimation.middle)
            }else if status == ItemStatus.okay.rawValue && Utilities.isItemInArray(item: item, array: self.foundItems) == false{
                
                // Add it to lost items array and insert in lost section
                self.foundItems.insert(item, at: 0)
                self.itemsTableView.insertRows(at: [IndexPath(row: 0, section: TableViewSections.found.rawValue)], with: UITableViewRowAnimation.middle)
            }
        })
        
        // 3. Reload the table view to display fresh data
        self.itemsTableView.reloadData()
    }
    
    func setupBars(){
        
        // 1. Change navigation bar background color and make its alpha 1
        navigationController?.navigationBar.barTintColor = kColor4990E2
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HalisR-Black", size: 16)!, NSForegroundColorAttributeName: UIColor.white]
        tabBarController?.tabBar.barTintColor = UIColor.white
    }
    
    func changeItemStatus(withStatus: String) {
        if withStatus != ""{
            // 1. Check which cell was tapped
            let selectedIndex = itemsTableView.indexPathForSelectedRow
            let cell = itemsTableView.cellForRow(at: selectedIndex!) as! TagCustomTableViewCell
            
            // 2. Update that specific cell's status button
            if withStatus == ItemStatus.okay.rawValue {
                cell.statusImageView.image = UIImage(named: "okay-icon")
            }else{
                cell.statusImageView.image = UIImage(named: "lost-icon")
            }
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
        self.itemsTableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagDetailSegue"{
            self.tabBarController?.tabBar.isHidden = true
            let selectedIndex = itemsTableView.indexPathForSelectedRow!
            let selectedSection = selectedIndex.section
            let selectedRow = selectedIndex.row
            let cell = itemsTableView.cellForRow(at: selectedIndex) as! TagCustomTableViewCell

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
