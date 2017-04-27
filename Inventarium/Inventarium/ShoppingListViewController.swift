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
import Hero

/*
 * ShoppingListViewController presents the items in a users grocery list
 */
class ShoppingListViewController: GroceryListTableViewController, MGSwipeTableCellDelegate, UITableViewDelegate, UITableViewDataSource {
    var items: [GroceryItem] = []
    var currentUser:User!
    var selectedGroceryItem:GroceryItem!
    var selectedCell:UITableViewCell!

    @IBOutlet var tableView: UITableView!
    
    var animator: UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var snapBehavior : UISnapBehavior!

    var ref:FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        //HeroDebugPlugin.isEnabled = true
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
        
        animator = UIDynamicAnimator(referenceView: view)
        heroModalAnimationType = .selectBy(presenting:.none, dismissing:.fade)
        
        

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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MGSwipeTableCell
        
        cell.textLabel!.text = groceryItem.name.capitalized
        cell.detailTextLabel!.text = String(groceryItem.count)
        cell.delegate = self //optional
        //configure left buttons
        cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named: "Home.png"), backgroundColor: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.onMoveToPantryClicked(indexPath)
            return true
            })]
        cell.leftSwipeSettings.transition = .drag
        
        cell.leftExpansion.fillOnTrigger = true
        cell.leftExpansion.buttonIndex = 0
        cell.leftExpansion.threshold = 1.5
        
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "", icon: UIImage(named: "Trash.png"), backgroundColor: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), callback: {
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
        let groceryItem = items[indexPath.row]
        
        // Remove HeroID from previously selected cell
        if let previousCell = selectedCell {
            previousCell.heroID = nil
            previousCell.textLabel?.heroID = nil
            previousCell.detailTextLabel?.heroID = nil
        }
        
        selectedGroceryItem = groceryItem
        selectedCell = cell
        
        cell.heroID = "itemBackground"
        cell.textLabel?.heroID = "itemName"
        cell.detailTextLabel?.heroID = "itemCount"
        cell.textLabel?.heroModifiers = [.zPosition(CGFloat(2000))]
        //cell.heroModifiers = [.zPosition(CGFloat(2000))]
        loadHeroView()
        
        tableView.reloadData()
    }
    
    func loadHeroView(){
        self.performSegue(withIdentifier: "showItemController", sender: self)    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showItemController") {
            let itemViewController = (segue.destination as! itemViewController)
            itemViewController.itemNameString = selectedGroceryItem.name
            itemViewController.itemCountString = String(selectedGroceryItem.count)
            itemViewController.item = selectedGroceryItem
        }

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
        thisItemRef.child("category").setValue(item.category)
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
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // Stuff run after safari is closed
        self.tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        fixTableViewInsets()
    }
}
