//
//  ViewController.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 2/9/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import UIKit

class GroceryListTableViewController: UITableViewController {
    var items: [GroceryItem] = []
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        
        user = User(uid: "Fake", email: "mer95@case.edu")
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let groceryItem = items[indexPath.row]
        
        cell.textLabel?.text = groceryItem.name
        cell.detailTextLabel?.text = groceryItem.addedByUser
        
        toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.reloadData()
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
    
    // MARK: Add Item
    @IBAction func addButtonDidTouch(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Grocery Item",
                                      message: "Add an Item",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in
                                        let textField = alert.textFields![0]
                                        let groceryItem = GroceryItem(name: textField.text!,
                                                                      addedByUser: self.user.email,
                                                                      completed: false)
                                        self.items.append(groceryItem)
                                        self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
