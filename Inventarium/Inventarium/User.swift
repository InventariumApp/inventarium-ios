//
//  User.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 2/9/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    let uid: String
    let email: String
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!.replacingOccurrences(of: ".", with: ",", options: .literal, range: nil)
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email.replacingOccurrences(of: ".", with: ",", options: .literal, range: nil)
    }
    
}

