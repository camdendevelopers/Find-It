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

class MyTagsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChangeStatusProtocol {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    // MARK:- IBOutlets for class
    @IBOutlet weak var itemsTableView: UITableView!
    
    // MARK:- Variables for class
    private lazy var lostItems: [NSDictionary] = []
    private lazy var foundItems: [NSDictionary] = []
    
    // MARK:- Loading method calls
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigation()
        getTags()
    }
    
    // MARK:- Table View Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
 
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }

        header.textLabel?.textColor = kColor4A4A4A
        header.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 12)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .left

        let divider = UIView()
        divider.backgroundColor = kColorD8D8D8
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        header.addSubview(divider)

        divider.leadingAnchor.constraint(equalTo: header.leadingAnchor).isActive = true
        divider.trailingAnchor.constraint(equalTo: header.trailingAnchor).isActive = true
        divider.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "LOST ITEMS" : "FOUND ITEMS"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? lostItems.count : foundItems.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return lostItems.isEmpty ? 0 : UITableView.automaticDimension
        default:
            return foundItems.isEmpty ? 0 : UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) as! TagCustomTableViewCell
        let row = indexPath.row
        let section = indexPath.section
        
        var item: NSDictionary = [:]

        switch section {
        case 0:
            item = lostItems[row]
        default:
            item = foundItems[row]
        }


        // 2. Create local item variable
        let itemID = item["id"] as? String
        let itemName = item["name"] as? String
        let itemStatus = item["status"] as? String
        let itemImageUrl = item["itemImageURL"] as? String

        // Update cell name and id labels
        cell.itemIdentificationLabel.text = itemID
        cell.itemNameLabel.text = itemName

        // Add a radius to image
        cell.itemImageView.layer.cornerRadius = cell.itemImageView.frame.size.height / 2
        cell.itemImageView.clipsToBounds = true
        cell.itemImageView.layer.masksToBounds = true

        // Check if cell is lost or found, and update the status button
        if itemStatus == ItemStatus.okay.rawValue {
            cell.statusImageView.image = UIImage(named: "okay-icon")
        } else if itemStatus == ItemStatus.found.rawValue {
            cell.statusImageView.image = UIImage(named: "warning-icon")
        } else {
            cell.statusImageView.image = UIImage(named: "lost-icon")
        }

        cell.itemImageView.sd_setShowActivityIndicatorView(true)
        cell.itemImageView.sd_setIndicatorStyle(.gray)
        cell.itemImageView.sd_setImage(with: URL(string: itemImageUrl!), placeholderImage: UIImage(named: "default_image_icon"), options: SDWebImageOptions.cacheMemoryOnly)

        return cell
    }

    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // 1. If user swipes to delete
        if editingStyle == .delete {
            
            // 2. Create local variables for the section and selected row
            let selectedSection = indexPath.section
            let selectedRow = indexPath.row
            var item:NSDictionary = [:]
            
            // 3. Retrieve item info in selected cell
            switch selectedSection {
            case 0:
                item = lostItems[selectedRow]
            default:
                item = foundItems[selectedRow]
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
                    case 0:
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
    func getTags() {
        // 1. Empty out array before fetching new ones
        lostItems.removeAll()
        foundItems.removeAll()
        
        // 2. Call Firebase to retrieve all user's tag and add them to the table view
        DataService.dataService.CURRENT_USER_REF.child("items").observe(.childAdded, with: { (snapshot) in
            // Create item
            let item = snapshot.value as! NSDictionary
            let status = item["status"] as! String
            
            // Check the status of item and add it to appropriate data source array
            if (status == ItemStatus.lost.rawValue || status == ItemStatus.found.rawValue) && Utilities.isItemInArray(item: item, array: self.lostItems) == false{
                
                // Add it to lost items array and insert in lost section
                self.lostItems.insert(item, at: 0)
                self.itemsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .middle)
            } else if status == ItemStatus.okay.rawValue && Utilities.isItemInArray(item: item, array: self.foundItems) == false {
                
                // Add it to lost items array and insert in lost section
                self.foundItems.insert(item, at: 0)
                self.itemsTableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .middle)
            }
        })
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.barTintColor = kColor4990E2
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "HalisR-Black", size: 16)!, .foregroundColor: UIColor.white]
        tabBarController?.tabBar.barTintColor = .white
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
    
    func setupTableView() {
        itemsTableView.delegate = self
        itemsTableView.dataSource = self

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefresh), for: .valueChanged)
        itemsTableView.insertSubview(refreshControl, at: 0)
    }
    
    @objc func didRefresh(refreshControl: UIRefreshControl) {
        getTags()
        itemsTableView.reloadData()
        refreshControl.endRefreshing()
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
            case 0:
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
