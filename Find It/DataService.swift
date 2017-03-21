//
//  DataService.swift
//  Find It
//
//  Created by Camden Madina on 3/7/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FacebookCore
import FacebookLogin

class DataService {
    static let dataService = DataService()
    var STORAGE_REF = FIRStorage.storage().reference()
    var BASE_REF = FIRDatabase.database().reference()
    var USER_REF = FIRDatabase.database().reference().child("users")
    var ITEM_REF = FIRDatabase.database().reference().child("items")
    var REPORT_REF = FIRDatabase.database().reference().child("reports")
    var AUTH_REF = FIRAuth.auth()!
    var FBAUTH_REF = LoginManager()
    
    func createNewAccount(uid: String, user: [String:Any]) {
        // A User is born.
        USER_REF.child(uid).setValue(user)
    }
    
    func createNewTag(tag: Dictionary<String, AnyObject>) {
        // Save the Tag
        // ITEM_REF is the parent of the new Tag: "tags".
        // childByAutoId() saves the joke and gives it its own ID.
        
        let firebaseNewTag = ITEM_REF.childByAutoId()
        
        // setValue() saves to Firebase.
        firebaseNewTag.setValue(tag)
    }
    
    func createNewReport(report: Dictionary<String, AnyObject>){
        // Save the Event
        // REPORT_REF is the parent of the new Post: "reports".
        // childByAutoId() saves the joke and gives it its own ID.
        
        let firebaseNewReport = REPORT_REF.childByAutoId()
        
        // setValue() saves to Firebase.
        firebaseNewReport.setValue(report)
    }
}
