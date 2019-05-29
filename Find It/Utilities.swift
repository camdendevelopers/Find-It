//
//  Utilities.swift
//  Settings
//
//  Created by Camden Madina on 3/2/17.
//  Copyright © 2017 Camden Developers. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class Utilities{
    
    //Method that shows any errors encountered view UIAlertController
    class func showErrorAlert (inDict: [String:String]) -> UIAlertController{
        let title = inDict["title"]
        let msg = inDict["message"]
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        return alert
    }
    
    class func isValidEmail(string:String) -> Bool{
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: string)
        return result
    }
    
    class func isValidPassword(string: String) -> Bool{
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z_0-9\\-_,;.:#+*?=!§$%&/()@]+$", options: .caseInsensitive)
            if(regex.firstMatch(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.count)) != nil){
                
                if(string.count>=6 && string.count<=20){
                    return true
                }else{
                    return false
                }
            }else{
                return false
            }
        } catch {
            return false
        }
    }
    
    class func format(phoneNumber sourcePhoneNumber: String) -> String?{
        
        // Remove any character that is not a number
        let numbersOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let length = numbersOnly.count
        let hasLeadingOne = numbersOnly.hasPrefix("1")
        
        // Check for supported phone number length
        guard length == 7 || length == 10 || (length == 11 && hasLeadingOne) else {
            return nil
        }
        
        let hasAreaCode = (length >= 10)
        var sourceIndex = 0
        
        // Leading 1
        var leadingOne = ""
        if hasLeadingOne {
            leadingOne = "1 "
            sourceIndex += 1
        }
        
        // Area code
        var areaCode = ""
        if hasAreaCode {
            let areaCodeLength = 3
            guard let areaCodeSubstring = numbersOnly.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
                return nil
            }
            areaCode = String(format: "(%@) ", areaCodeSubstring)
            sourceIndex += areaCodeLength
        }
        
        // Prefix, 3 characters
        let prefixLength = 3
        guard let prefix = numbersOnly.substring(start: sourceIndex, offsetBy: prefixLength) else {
            return nil
        }
        sourceIndex += prefixLength
        
        // Suffix, 4 characters
        let suffixLength = 4
        guard let suffix = numbersOnly.substring(start: sourceIndex, offsetBy: suffixLength) else {
            return nil
        }
        
        return leadingOne + areaCode + prefix + "-" + suffix
    }
    
    class func formatTimestamp(time: String) -> String{
        let formatter = DateFormatter()
        formatter.timeStyle = .full
        formatter.dateStyle = .full
        let date = formatter.date(from: time)
        let now = Date()
        let elapsed = now.timeIntervalSince(date!)
        
        let minutes = floor(elapsed / 60)
        let hours = floor(elapsed / (60*60))
        let days = floor(elapsed / ((60*60)*24))
        let weeks = floor(elapsed / ((60*60)*24*7))
        let months = floor(elapsed / ((60*60)*24*7*4))
        
        if minutes <= 60 {
            return ("\(Int(minutes))m")
        }else if hours <= 24 && hours >= 1{
            return ("\(Int(hours))h")
        }else if days <= 31 && days >= 1{
            return ("\(Int(days))d")
        }
        else if weeks <= 4 && weeks >= 1{
            return ("\(Int(weeks))w")
        }
        else if months <= 12 && months >= 1 {
            return ("\(Int(months))mon")
        }
        
        return ""
    }
    
    class func isItemInArray(item: NSDictionary, array: [NSDictionary]) -> Bool{
        var result:Bool = false
        
        for dict in array{
            if item == dict{
                result = true
            }
        }
        
        return result
    }
}

//MARK:- Class extensions
extension String{
    
    // Returns true if the string has at least one character in common with matchCharacters.
    func containsCharactersIn(matchCharacters: String) -> Bool{
        let characterSet = NSCharacterSet(charactersIn: matchCharacters)
        return self.rangeOfCharacter(from: characterSet as CharacterSet) != nil
    }
    
    // Returns true if the string contains only characters found in matchCharacters.
    func containsOnlyCharactersIn(matchCharacters: String) -> Bool{
        let disallowedCharacterSet = NSCharacterSet(charactersIn: matchCharacters).inverted
        return self.rangeOfCharacter(from: disallowedCharacterSet as CharacterSet) != nil
    }
    
    // Returns true if the string has no characters in common with matchCharacters.
    func doesNotContainCharactersIn(matchCharacters: String) -> Bool{
        let characterSet = NSCharacterSet(charactersIn: matchCharacters)
        return self.rangeOfCharacter(from: characterSet as CharacterSet) != nil
    }

    func isNumeric() -> Bool{
        let scanner = Scanner(string: self)
        scanner.locale = NSLocale.current
        return scanner.scanDecimal(nil) && scanner.isAtEnd
    }
}

extension String.CharacterView{
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        
        return String(self[substringStartIndex ..< substringEndIndex])
    }
}

//MARK:- Enums
enum ItemStatus: String {
    case okay = "in-possesion"
    case lost = "lost"
    case found = "found"
}

enum TableViewSections: Int {
    case lost = 0
    case found = 1
}

enum UIUserInterfaceIdiom : Int {
    case Unspecified
    case Phone
    case Pad
}

//MARK:- Structs

struct ScreenSize{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct StatusBar{
    static let HEIGHT = UIApplication.shared.statusBarFrame.height
    static let WIDTH = UIApplication.shared.statusBarFrame.width
}

struct DeviceType{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}

struct Reachability {
    static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

struct ShortCodeGenerator {
    private static let numbers = "1234567890".split(separator: ",")
    private static let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split(separator: ",")
    
    static func getCode(length: Int) -> String{
        var code = ""
        
        for index in 0 ..< length {
            
            if index < (length / 2){
                let randomLetter = Int(arc4random_uniform(UInt32(letters.count)))
                code.append(String(letters[randomLetter]))
            } else {
                let randomNumber = Int(arc4random_uniform(UInt32(numbers.count)))
                code.append(String(numbers[randomNumber]))
            }
        }
        return code
    }
}
