//
//  NewItemTableViewController.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 2/24/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import UIKit

//https://www.raywenderlich.com/113772/uisearchcontroller-tutorial
//http://www.matthewhsingleton.com/blog/2016/5/26/predictive-text-table-view-swift-version-of-ray-wenderlich
class NewItemTableViewController: UITableViewController {
    @IBOutlet weak var itemNameTextField: UISearchBar!

    @IBOutlet weak var countTextField: UITextField!
    
    var item:GroceryItem?
    var prefilledItemName:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countTextField.text = "1"
        if (prefilledItemName != nil) {
            itemNameTextField.text = prefilledItemName
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // If the user taps the first cell, bring up the text field
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            itemNameTextField.becomeFirstResponder()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewItem" {
            item = GroceryItem(name: itemNameTextField.text!, addedByUser: "mike", count: Int(countTextField.text!)!)
        }
    }
}
