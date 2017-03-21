//
//  MyitemsViewController.swift
//  Find It
//
//  Created by Camden Madina on 2/21/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import UIKit
import Firebase

class MyTagsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChangeStatusProtocol{
    
    
    @IBOutlet weak var itemsTableView: UITableView!
    
    private var currentUserID:String?
    private var currentUser: FIRDatabaseReference?
    private var didLoad:Bool = false
    
    var items = [NSDictionary]()
    
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
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) as! TagCustomTableViewCell
        let row = indexPath.row
        
        if items.count != 0 {
            let item = items[row]
            let status = item["status"] as? String
            
            cell.itemIdentificationLabel.text = item["id"] as? String
            cell.itemNameLabel.text = item["name"] as? String
            
            if status == "in-possesion" {
                cell.statusImageView.image = UIImage(named: "okay-status-icon")
            }else{
                cell.statusImageView.image = UIImage(named: "lost-status-icon")
            }
        }
        
        return cell
    }
    
    func changeItemStatus() {
        //print("PROTOCOL WORKS")
        let selectedIndex = itemsTableView.indexPathForSelectedRow
        let cell = itemsTableView.cellForRow(at: selectedIndex!) as! TagCustomTableViewCell
        
        cell.statusImageView.image = UIImage(named: "lost-status-icon")
        
        //self.currentUser?.child("address").setValue(address)
    }
    
    func loadUser(){
        self.currentUserID = DataService.dataService.AUTH_REF.currentUser?.uid
        self.currentUser = DataService.dataService.USER_REF.child(currentUserID!)
    }
    
    func setupTableView(){
        self.itemsTableView.delegate = self
        self.itemsTableView.dataSource = self
        
        
        self.currentUser?.child("items").observe(.childAdded, with: { (snapshot) in
            let item = snapshot.value as! NSDictionary
            self.items.insert(item, at: 0)
            self.itemsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.top)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagDetailSegue"{
            let selectedRow = itemsTableView.indexPathForSelectedRow?.row
            if let destinationViewController = segue.destination as? TagDetailViewController{
                destinationViewController.itemDetails = self.items[selectedRow!]
                destinationViewController.delegate = self
            }
        }
    }
}
