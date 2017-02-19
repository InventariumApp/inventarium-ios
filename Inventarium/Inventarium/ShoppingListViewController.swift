//
//  ShoppingListViewController.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 2/13/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import UIKit
import Firebase
import MGSwipeTableCell

class ShoppingListViewController: GroceryListTableViewController, MGSwipeTableCellDelegate {
    var items: [GroceryItem] = []
    var currentUser:User!

    //let ref = FIRDatabase.database().reference(withPath: "shopping-items")
    // NEED AN INIT THAT PROVIDES USER AND THEN ADDS EMAIL TO THE REF
    var ref:FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(MGSwipeTableCell.self, forCellReuseIdentifier: "cell")

        ref = FIRDatabase.database().reference(withPath: "lists/\(currentUser!.email)/shopping-list")
        tableView.allowsMultipleSelectionDuringEditing = false
        
        //.value listens for all types of changes to the data in your Firebase database—add, removed, and changed
        ref.observe(.value, with: { snapshot in
            // Store the latest version of the data
            var newItems: [GroceryItem] = []
            
            // Using children, loop through the grocery items.
            for item in snapshot.children {
                // Use second GroceryItem init that takes a FIRDataSnapshot
                let groceryItem = GroceryItem(snapshot: item as! FIRDataSnapshot)
                // Add items to local array
                newItems.append(groceryItem)
            }
            
            // Reassign items to the new items array
            self.items = newItems
            self.tableView.reloadData()
        })


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: UITableView Delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "ItemCell"
        let groceryItem = items[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MGSwipeTableCell
        
        cell.textLabel!.text = groceryItem.name
        cell.detailTextLabel!.text = String(groceryItem.count)
        cell.delegate = self //optional
        
        //configure left buttons
        cell.leftButtons = [MGSwipeButton(title: "Delete", backgroundColor: .red),
                             MGSwipeButton(title: "More",backgroundColor: .lightGray)]
        cell.leftSwipeSettings.transition = .drag
//        cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named:"check.png"), backgroundColor: .green),
//                            MGSwipeButton(title: "", icon: UIImage(named:"fav.png"), backgroundColor: .blue)]
//        cell.leftSwipeSettings.transition = .drag
//        
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: .red),
                             MGSwipeButton(title: "More",backgroundColor: .lightGray)]
        cell.rightSwipeSettings.transition = .drag
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the item from the items list
            let groceryItem = items[indexPath.row]
            // Remove the item from firebase
            groceryItem.ref?.removeValue()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        var groceryItem = items[indexPath.row]
        let toggledCompletion = !groceryItem.completed
        
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        groceryItem.completed = toggledCompletion
        tableView.reloadData()
    }
    
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.textColor = UIColor.gray
        }
    }
    
    public func addItemToList(list: String, item: GroceryItem) {
        let listPath:String = "lists/\(currentUser.email)/shopping-list"
        let ref = FIRDatabase.database().reference(withPath: listPath)
        //Create a child reference
        let groceryItemRef = ref.child(String(item.name).lowercased())
        //Save data to the database.
        groceryItemRef.setValue(item.toAnyObject())
    }
}
