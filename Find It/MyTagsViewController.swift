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
            let itemID = item["id"] as? String
            let status = item["status"] as? String
            //let itemImageURLString = item["itemImageURL"] as? String
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                let itemImageReference = DataService.dataService.STORAGE.reference(withPath: "\(self.currentUserID!)/\(itemID!).jpg")
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
                    cell.itemIdentificationLabel.text = item["id"] as? String
                    cell.itemNameLabel.text = item["name"] as? String
                    
                    cell.itemImageView.layer.cornerRadius = cell.itemImageView.frame.size.height / 2
                    cell.itemImageView.clipsToBounds = true
                    cell.itemImageView.layer.masksToBounds = true
       
                    if status == "in-possesion" {
                        cell.statusImageView.image = UIImage(named: "okay-icon")
                    }else{
                        cell.statusImageView.image = UIImage(named: "lost-icon")
                    }
                }
            }
        }
        
        return cell
    }
    
    func changeItemStatus() {
        //print("PROTOCOL WORKS")
        let selectedIndex = itemsTableView.indexPathForSelectedRow
        let cell = itemsTableView.cellForRow(at: selectedIndex!) as! TagCustomTableViewCell
        
        cell.statusImageView.image = UIImage(named: "lost-icon")
        
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
                destinationViewController.currentUserID = self.currentUserID!
            }
        }
    }
}
