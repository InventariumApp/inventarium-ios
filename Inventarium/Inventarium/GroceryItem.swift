//
//  GroceryItem.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 2/9/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import Foundation
import Firebase

struct GroceryItem {
    
    let key: String
    let name: String
    let addedByUser: String
    let ref: FIRDatabaseReference?
    var count: Int
    
    init(name: String, addedByUser: String, count: Int, key: String = "") {
        self.key = key
        self.count = count
        self.name = name
        self.addedByUser = addedByUser
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        count = snapshotValue["count"] as! Int
        addedByUser = snapshotValue["addedByUser"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "count": count,
            "addedByUser": addedByUser,
        ]
    }
    
    func getAmazonLink() -> String {
        let cleanedName = self.name.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        return "https://www.amazon.com/s/ref=nb_sb_noss_1?url=search-alias%3Daps&field-keywords=\(cleanedName)"
    }
    
}

