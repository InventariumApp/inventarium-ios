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
import SafariServices

class ShoppingListViewController: GroceryListTableViewController, MGSwipeTableCellDelegate, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
    var items: [GroceryItem] = []
    var currentUser:User!
    var selectedGroceryItem:GroceryItem!

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var infoCard: UIView!
    @IBOutlet weak var infoCardItemName: UILabel!
    @IBOutlet weak var infoCardButton: UIButton!

    //let ref = FIRDatabase.database().reference(withPath: "shopping-items")
    // NEED AN INIT THAT PROVIDES USER AND THEN ADDS EMAIL TO THE REF
    var ref:FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(MGSwipeTableCell.self, forCellReuseIdentifier: "cell")
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        ref = FIRDatabase.database().reference(withPath: "lists/\(currentUser!.email)/shopping-list")
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.tableFooterView = UIView(frame: .zero)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: UITableView Delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "ItemCell"
        let groceryItem = items[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MGSwipeTableCell
        
        cell.textLabel!.text = groceryItem.name
        cell.detailTextLabel!.text = String(groceryItem.count)
        cell.delegate = self //optional
        
        //configure left buttons
        cell.leftButtons = [MGSwipeButton(title: "Move To Pantry", backgroundColor: .green, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.onMoveToPantryClicked(indexPath)
            return true
            })]
        cell.leftSwipeSettings.transition = .drag
        
        cell.leftExpansion.fillOnTrigger = true
        cell.leftExpansion.buttonIndex = 0
        cell.leftExpansion.threshold = 1.5
        
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: .red, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.onDeleteClicked(indexPath)
            return true
        })]
        
        cell.rightSwipeSettings.transition = .drag
        cell.rightExpansion.fillOnTrigger = true
        cell.rightExpansion.buttonIndex = 0
        cell.rightExpansion.threshold = 1.5

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the item from the items list
            let groceryItem = items[indexPath.row]
            // Remove the item from firebase
            groceryItem.ref?.removeValue()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        var groceryItem = items[indexPath.row]
        selectedGroceryItem = groceryItem
        infoCardItemName.text = groceryItem.name
        makeInfoCardAppear()
        print(groceryItem.getAmazonLink())
        tableView.reloadData()
    }
    
    func makeInfoCardAppear() {
        //infoCard.center = CGPoint(x: 187.5, y: 450)
        infoCard.center = CGPoint(x: 187.5, y: 600)
        infoCard.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.infoCard.center.y = 450
        }, completion: nil)
    }

    func onDeleteClicked(_ index: IndexPath) {
        // Get the item from the items list
        let groceryItem = items[index.row]
        // Remove the item from firebase
        groceryItem.ref?.removeValue()
    }
    
    func onMoveToPantryClicked(_ index: IndexPath) {
        let groceryItem = items[index.row]
        // Remove the item from firebase
        let listPath:String = "lists/\(currentUser.email)/pantry-list"
        let ref = FIRDatabase.database().reference(withPath: listPath)
        let groceryItemRef = ref.child(String(groceryItem.name).lowercased())
        groceryItem.ref?.removeValue()
        groceryItemRef.setValue(groceryItem.toAnyObject())
        addItemToHistory(item: groceryItem)
    }
    
    func addItemToHistory(item:GroceryItem) {
        let userPath:String = "lists/\(currentUser.email)"
        let ref = FIRDatabase.database().reference(withPath: userPath)
        let itemRef = ref.child(byAppendingPath: "item-history")
        let thisItemRef = itemRef.child(byAppendingPath: String(item.name).lowercased())
        let timeRef = thisItemRef.childByAutoId
        timeRef().setValue(FIRServerValue.timestamp())
    }

    
    public func addItemToList(list: String, item: GroceryItem) {
        let listPath:String = "lists/\(currentUser.email)/shopping-list"
        let ref = FIRDatabase.database().reference(withPath: listPath)
        //Create a child reference
        let groceryItemRef = ref.child(String(item.name).lowercased())
        //Save data to the database.
        groceryItemRef.setValue(item.toAnyObject())
    }
    
    // Attempting to fix the UITableViewWrapperView issue (list being offset)
    func fixTableViewInsets() {
        let zContentInsets = UIEdgeInsets.zero
        tableView.contentInset = zContentInsets
        tableView.scrollIndicatorInsets = zContentInsets
    }
    
    func loadAmazonPage(_ web_url: String) {
        let vc = SFSafariViewController(url: URL(string: web_url)!)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
        //present(vc, animated: true)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // Stuff run after safari is closed
        self.tableView.reloadData()
    }
    
    @IBAction func purchaseButtonClicked(_ sender: Any) {
        loadAmazonPage(selectedGroceryItem.getAmazonLink())
    }
    
    @IBAction func panInfoBox(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        if (sender.view!.center.y > 600) {
            sender.view?.isHidden = true
        }
        if (sender.view!.center.y > 450 || translation.y > 0) {
            sender.view!.center = CGPoint(x: sender.view!.center.x, y: sender.view!.center.y + translation.y)
            sender.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        fixTableViewInsets()
    }
}
