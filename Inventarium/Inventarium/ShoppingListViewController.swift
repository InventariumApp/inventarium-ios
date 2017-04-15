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

class ShoppingListViewController: GroceryListTableViewController, MGSwipeTableCellDelegate, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
    var items: [GroceryItem] = []
    var currentUser:User!
    var selectedGroceryItem:GroceryItem!

    @IBOutlet var tableView: UITableView!
    var infoCard: CardView!
    var infoCardItemNameLabel: UILabel!
    var infoCardItemName: String!
    var infoCardButton: UIButton!
    
    var animator: UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var snapBehavior : UISnapBehavior!
    
    var infoCardCenterY:Double = 480.0
    var infoCardCenterX:Double = 27.0

    //let ref = FIRDatabase.database().reference(withPath: "shopping-items")
    // NEED AN INIT THAT PROVIDES USER AND THEN ADDS EMAIL TO THE REF
    var ref:FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        HeroDebugPlugin.isEnabled = true
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
        createInfoCard()
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func prepareInfoCard() {
        
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
        
        cell.textLabel!.text = groceryItem.name
        cell.detailTextLabel!.text = String(groceryItem.count)
        cell.delegate = self //optional
        //configure left buttons
        cell.leftButtons = [MGSwipeButton(title: "Move To Pantry", backgroundColor: .purple, callback: {
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
        let groceryItem = items[indexPath.row]
        selectedGroceryItem = groceryItem
//        infoCardItemName = groceryItem.name
//        infoCardItemNameLabel.text = infoCardItemName
//        if (infoCard != nil) {
//            dismissCard()
//        }
//        makeInfoCardAppear()
//        print(groceryItem.getAmazonLink())
        
        cell.heroID = "itemBackground"
        cell.textLabel?.heroID = "itemName"
        cell.detailTextLabel?.heroID = "itemCount"
        //cell.textLabel?.heroModifiers = [.zPosition(CGFloat(2000))]
        //cell.heroModifiers = [.zPosition(CGFloat(2000))]
        loadHeroView()
        
        tableView.reloadData()
    }
    
    func loadHeroView(){
        //GARBAGE
        //        let vc = itemViewController()
        //
        //DispatchQueue.main.async {
            //self.hero_replaceViewController(with: itemViewController())

            self.performSegue(withIdentifier: "showItemController", sender: self)
        //}
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showItemController") {
            let itemViewController = (segue.destination as! itemViewController)
            itemViewController.itemNameString = selectedGroceryItem.name
            itemViewController.itemCountString = String(selectedGroceryItem.count)
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
    
    /*
     Info Box Animation Stuff
     */
    
    func createInfoCard() {
        let cardWidth: CGFloat = 321
        let cardHeight: CGFloat = 128
        let cardFrame: CGRect = CGRect(x: CGFloat(view.center.x - 160), y: CGFloat(infoCardCenterY + 50), width: cardWidth, height: cardHeight)
        infoCard = CardView(frame: cardFrame)
        infoCard.backgroundColor = UIColor.purple
        infoCard.alpha = 0.0
        
        // Create a button and set a listener on it for when it is tapped. Then the button is added to the alert view
        let button = UIButton(type: UIButtonType.system) as UIButton
        button.setTitle("Purchase", for: UIControlState.normal)
        button.backgroundColor = UIColor.white
        button.frame =  CGRect(x: 74, y: 75, width: 172, height: 34)
        
        
        button.addTarget(self, action: #selector(self.purchaseButtonClicked(_:)), for: UIControlEvents.touchUpInside)
        
        infoCard.addSubview(button)
        
        // Create item title
        infoCardItemNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 218, height: 37))
        infoCardItemNameLabel.center = CGPoint(x: 139, y: 22)
        infoCardItemNameLabel.textAlignment = .center
        infoCardItemNameLabel.textColor = .white
        infoCardItemNameLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 27.0)
        infoCardItemNameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        infoCardItemNameLabel.numberOfLines = 2
        infoCardItemNameLabel.text = infoCardItemName
        
        infoCard.addSubview(infoCardItemNameLabel)
        
        view.addSubview(infoCard)
    }
    
    func makeInfoCardAppear() {
        if infoCard == nil {
           createInfoCard()
        }
        createGestureRecognizer()
        animator.removeAllBehaviors()
        
        infoCard.alpha = 1.0
        
        let snapBehaviour: UISnapBehavior = UISnapBehavior(item: infoCard, snapTo: CGPoint(x: view.center.x, y: CGFloat(infoCardCenterY)))
        animator.addBehavior(snapBehaviour)
    }
    
    func createGestureRecognizer() {
        let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(sender:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        if (infoCard != nil) {
            let panLocationInView = sender.location(in: view)
            let panLocationInBoxView = sender.location(in: infoCard)
            
            // Twist in direction of pan
            if sender.state == UIGestureRecognizerState.began {
                animator.removeAllBehaviors()
                let offset = UIOffsetMake(panLocationInBoxView.x - infoCard.bounds.midX, panLocationInBoxView.y - infoCard.bounds.midY)
                attachmentBehavior = UIAttachmentBehavior(item: infoCard, offsetFromCenter: offset, attachedToAnchor: panLocationInView)
                animator.addBehavior(attachmentBehavior)
            }
                
            // Move to user's finger
            else if sender.state == UIGestureRecognizerState.changed {
                attachmentBehavior.anchorPoint = panLocationInView
            }
                
            // Snap back to original location
            else if sender.state == UIGestureRecognizerState.ended {
                animator.removeAllBehaviors()
                snapBehavior = UISnapBehavior(item: infoCard, snapTo: CGPoint(x: view.center.x, y: CGFloat(infoCardCenterY)))
                animator.addBehavior(snapBehavior)
                if sender.translation(in: view).y > 75 {
                    dismissCard()
                }
            }
        }
    }
    
    func dismissCard() {
        animator.removeAllBehaviors()
        
        let gravityBehaviour: UIGravityBehavior = UIGravityBehavior(items: [infoCard])
        gravityBehaviour.gravityDirection = CGVector(dx: 0.0, dy: 10.0);
        animator.addBehavior(gravityBehaviour)
        
        // tilt when falling
        let itemBehaviour: UIDynamicItemBehavior = UIDynamicItemBehavior(items: [infoCard])
        itemBehaviour.addAngularVelocity(CGFloat(-M_PI_2), for: infoCard)
        animator.addBehavior(itemBehaviour)
        
        self.infoCard.removeFromSuperview()
        self.infoCard = nil

        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        fixTableViewInsets()
    }
}
