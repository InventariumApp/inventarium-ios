//
//  infoCard.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 3/23/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import Foundation

struct infoCard {
    
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

