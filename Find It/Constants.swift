//
//  Constants.swift
//  Settings
//
//  Created by Camden Madina on 3/2/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import Foundation
import UIKit

//MARK:- Client Side Error Messages
let EmptyUserPasswordTextFields = ["title": "Could Not Sign In","message":"Email/password fields are empty."]
let ChangeMemberTypeInformation = ["title": "Change Member Status", "message": "You can change status by typing in a different member code."]
let EmptyEventFields = ["title": "Couldn't Create Event", "message": "Fields cannot be left blank."]
let EmptySettingFields = ["title": "Couldn't Save Info", "message": "Fields cannot be left blank."]
let EventCancelledWithFields = ["title": "Event Details Were Typed", "message": "Are you sure you want to cancel?"]
let MemberCodeChanged = ["title": "Important", "message": "Changing your member status will clear your current points. Are you sure you want to continue?"]
let InvalidMemberCode = ["title": "Error", "message": "The code you typed was incorrect. Please try again."]
let IPhoneTryUpload = ["title": "Can't Add Custom Image", "message": "Sorry, changing image is not available on this phone."]
let noNetworkConnection = ["title": "Couldn't Log You In", "message": "Your phone isn't connected to the internet, make sure you have a working connection and try again later."]

//MARK:- Firebase Error Code Messages
let FIRAuthErrorCodeInvalidCustomToken                      = 17000
let FIRAuthErrorCodeCustomTokenMismatch                     = 17002
let FIRAuthErrorCodeTooManyRequests                         = 17010
let FIRAuthErrorCodeUserDisabled = ["title": "Could Not Sign In", "message": "Error getting your information. Please try again later."]
let FIRAuthErrorCodeOperationNotAllowed = ["title": "Could Not Sign In", "message": "Error getting your information. Please try again later."]
let FIRAuthErrorCodeEmailAlreadyInUse = ["title": "Hold on a sec...", "message": "Email is already being used. Please try using a different one."]
let FIRAuthErrorCodeInvalidEmail = ["title": "Could Not Sign In", "message": "Invalid email, try again."]
let FIRAuthErrorCodeWrongPassword = ["title": "Could Not Sign In", "message": "Invalid password, try again."]
let FIRAuthErrorCodeUserNotFound = ["title": "Could Not Sign In", "message": "User with these credentials not found. Sign up and make a new account."]

let FIRAuthErrorCodeAccountExistsWithDifferentCredential    = 17012
let FIRAuthErrorCodeRequiresRecentLogin                     = 17014
let FIRAuthErrorCodeProviderAlreadyLinked                   = 17015
let FIRAuthErrorCodeNoSuchProvider                          = 17016
let FIRAuthErrorCodeInvalidUserToken                        = 17017
let FIRAuthErrorCodeNetworkError                            = 17020
let FIRAuthErrorCodeUserTokenExpired                        = 17021
let FIRAuthErrorCodeInvalidAPIKey                           = 17023
let FIRAuthErrorCodeUserMismatch                            = 17024
let FIRAuthErrorCodeCredentialAlreadyInUse                  = 17025
let FIRAuthErrorCodeWeakPassword = ["title": "Could Not Create Account", "message": "That is a weak password. Try using uppercase/lowercase/special characters."]

let FIRAuthErrorCodeAppNotAuthorized                        = 17028
let FIRAuthErrorCodeKeychainError                           = 17995
let FIRAuthErrorCodeInternalError                           = 17999

//MARK:- Firbase Error Code for Facebook Authentication
let FIRAuthErrorCodeInvalidCredential = ["title": "Could Not Sign In With Facebook", "message": "Error getting your information. Please try again later."]


//MARK:- Colors and text for tutorial
let kColor4990E2 = UIColor(red: 73.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 1.0)
let kColorFF7D7D = UIColor(red: 255.0/255.0, green: 125.0/255.0, blue: 125.0/255.0, alpha: 1.0)
let kColorE3CC00 = UIColor(red: 227.0/255.0, green: 204.0/255.0, blue: 0.0/255.0, alpha: 1.0)
let kColor87BEFE = UIColor(red: 135.0/255.0, green: 190.0/255.0, blue: 254.0/255.0, alpha: 1.0)
let kColorFDBFBF = UIColor(red: 253.0/255.0, green: 191.0/255.0, blue: 191.0/255.0, alpha: 1.0)
let kColor9B9B9B = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
let kColor4A4A4A = UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)

let titleText0 = "TAG YOUR ITEM"
let descriptionText0 = "Get a unique ID and attach it to an item, and link it in the app"

let titleText1 = "MARK LOST ITEMS"
let descriptionText1 = "When you lose an item, mark it as lost through the app"

let titleText2 = "REPORT FOUND ITEMS"
let descriptionText2 = "When you find an item, report the ID to notify the owner"

let titleText3 = "FIND LOST ITEM"
let descriptionText3 = "Get notified of the location of your lost item when it is found"


//MARK:- Enums
enum ItemStatus: String {
    case okay = "in-possesion"
    case lost = "lost"
    case found = "found"
}
