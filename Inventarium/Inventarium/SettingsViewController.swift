//
//  SettingsViewController.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 3/21/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import UIKit
import Firebase

/*
 * SettingsViewController handles the settings page where users can log out of the app
 */
class SettingsViewController: UITableViewController {

    @IBAction func logoutButtonClicked(_ sender: UIButton) {
        logout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.6078431373, green: 0.3294117647, blue: 0.7254901961, alpha: 1)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func logout() {
        try! FIRAuth.auth()!.signOut()
    }

}
