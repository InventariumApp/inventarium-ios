//
//  TwoViewController.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 2/12/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import UIKit
import Firebase

// Some Help: https://spin.atomicobject.com/2015/10/13/switching-child-view-controllers-ios-auto-layout/
class TwoViewController: UIViewController {
    var user: User!
    
    //Move to a function in each view controller... So that you can say: currentView.addItem rather than changing the ref...
    let ref = FIRDatabase.database().reference(withPath: "grocery-items")
    
    @IBOutlet weak var containerView: UIView!
    weak var currentViewController: GroceryListTableViewController?
    var shoppingListViewController: ShoppingListViewController?
    var pantryListViewController: PantryListViewController?
    
    override func viewDidLoad() {
        // If the user changed, set user var to the new user
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
            self.shoppingListViewController = self.storyboard?.instantiateViewController(withIdentifier: "ComponentA") as! ShoppingListViewController?
            self.pantryListViewController = self.storyboard?.instantiateViewController(withIdentifier: "ComponentB") as! PantryListViewController?
            self.shoppingListViewController?.currentUser = self.user
            self.pantryListViewController?.currentUser = self.user
            self.currentViewController = self.shoppingListViewController
            self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.addChildViewController(self.currentViewController!)
            self.addSubview(subView: self.currentViewController!.view, toView: self.containerView)
            super.viewDidLoad()
            self.currentViewController?.willMove(toParentViewController: nil)
            self.currentViewController?.removeFromParentViewController()        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showComponent(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            let newViewController = self.shoppingListViewController
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
            self.currentViewController = newViewController
        } else {
            let newViewController = self.pantryListViewController
            newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
            self.currentViewController = newViewController
        }
    }
    
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParentViewController: nil)
        self.addChildViewController(newViewController)
        self.addSubview(subView: newViewController.view, toView:self.containerView!)
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
        },
                                   completion: { finished in
                                    oldViewController.view.removeFromSuperview()
                                    oldViewController.removeFromParentViewController()
                                    newViewController.didMove(toParentViewController: self)
        })
    }
    
    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
                                                                                 options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
                                                                                 options: [], metrics: nil, views: viewBindingsDict))
    }
    
    // MARK: Add Item
    @IBAction func addButtonDidTouch(_ sender: UIBarButtonItem) {
        var alertMessage:String
        if (self.currentViewController == self.shoppingListViewController) {
            alertMessage = "Add an Item to Shopping List"
        } else {
            alertMessage = "Add an Item to Pantry List"
        }
        
        let alert = UIAlertController(title: "Add Item",
                                      message: alertMessage,
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { _ in
                                        //Get the text field (and its text) from the alert controller.
                                        guard let textField = alert.textFields?.first,
                                            let text = textField.text else { return }
                                        
                                        
                                        //Using the current user’s data, create a new GroceryItem that is not completed by default.
                                        let groceryItem = GroceryItem(name: text,
                                                                      addedByUser: self.user.email,
                                                                      completed: false,
                                                                      count: 4)
                                        
                                        if (self.currentViewController == self.shoppingListViewController) {
                                            self.shoppingListViewController!.addItemToList(list: "shopping", item: groceryItem)

                                        } else {
                                            self.pantryListViewController!.addItemToList(list: "pantry", item: groceryItem)
                                        }
                                        
                                        
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
 */
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        if (segue.identifier == "segueTest") {
//            //Checking identifier is crucial as there might be multiple
//            // segues attached to same view
//            var detailVC = segue!.destinationViewController as DetailViewController;
//            detailVC.toPass = textField.text
//        }
//    }
 

}
