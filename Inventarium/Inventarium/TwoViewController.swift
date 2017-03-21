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
            self.currentViewController?.removeFromParentViewController()
        }
        self.navigationController?.navigationBar.tintColor = UIColor.white;
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
        UIView.animate(withDuration: 0.1, animations: {
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
    
    
    @IBAction func cancelToTwoViewController(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func backFromSettingsLogoutSegue(segue:UIStoryboardSegue) {
        print("Attempting to segue from main to logout")
        performSegue(withIdentifier: "unwindToLogin", sender: nil)
    }
    
    @IBAction func saveNewItem(segue:UIStoryboardSegue) {
        if let newItemTableviewController = segue.source as? NewItemTableViewController {
            if let item = newItemTableviewController.item {
                let newItem = GroceryItem(name: item.name, addedByUser: self.user.email, count: item.count)
                
                if (self.currentViewController == self.shoppingListViewController) {
                    self.shoppingListViewController!.addItemToList(list: "shopping", item: newItem)
                    
                } else {
                    self.pantryListViewController!.addItemToList(list: "pantry", item: newItem)
                }
            }
        }
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
