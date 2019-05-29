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
    var STORAGE = FIRStorage.storage()
    var STORAGE_REF = FIRStorage.storage().reference()
    var BASE_REF = FIRDatabase.database().reference()
    var USER_REF = FIRDatabase.database().reference().child("users")
    var ITEM_REF = FIRDatabase.database().reference().child("items")
    var REPORT_REF = FIRDatabase.database().reference().child("reports")
    var AUTH_REF = FIRAuth.auth()!
    var FBAUTH_REF = LoginManager()
    
    var CURRENT_USER_REF:FIRDatabaseReference{
        let userID = UserDefaults.standard.value(forKey: "uid") as! String
        let currentUser = USER_REF.child(userID)
        return currentUser
    }
    
    func createNewAccount(uid: String, user: [String:Any]) {
        USER_REF.child(uid).setValue(user)
    }
}
