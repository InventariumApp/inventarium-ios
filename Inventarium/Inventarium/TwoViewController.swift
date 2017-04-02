//
//  TwoViewController.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 2/12/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class TwoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var user: User!
    var product:String? = nil

    @IBOutlet weak var infoCard: CardView!
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        let optionMenu = UIAlertController(title: nil, message: "Share Via...", preferredStyle: .actionSheet)
        
        let smsAction = UIAlertAction(title: "SMS", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let emailAction = UIAlertAction(title: "Email", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        optionMenu.addAction(smsAction)
        optionMenu.addAction(emailAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    //Move to a function in each view controller... So that you can say: currentView.addItem rather than changing the ref...
    let ref = FIRDatabase.database().reference(withPath: "grocery-items")
    
    // Get a reference to the storage service using the default Firebase App
    let storage = FIRStorage.storage()
    
    @IBOutlet weak var containerView: UIView!
    weak var currentViewController: GroceryListTableViewController?
    var shoppingListViewController: ShoppingListViewController?
    var pantryListViewController: PantryListViewController?
    var imagePicker: UIImagePickerController!
    
    @IBAction func cameraButtonClicked(_ sender: UIBarButtonItem) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        //imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        uploadImageToDatabase(image: image!)
    }
    
    func uploadImageToDatabase(image:UIImage) -> String {
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        var data = NSData()
        data = UIImageJPEGRepresentation(image, 0.1)! as NSData
        // set upload path
        let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\("userPhoto")"
        let newMetadata = FIRStorageMetadata()
        newMetadata.contentType = "image/jpg"
        storageRef.child(filePath).put(data as Data, metadata: newMetadata){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                //store downloadURL
                let downloadURL = metaData!.downloadURL()!.absoluteString
                self.sendRequestToServer(img_path: filePath) { product  in
                    if let product = product {
                        print(product)
                        DispatchQueue.main.async {
                            self.product = product
                            self.performSegue(withIdentifier: "cameraToAddItemSegue", sender: self)
                        }
                    }
                }
                print("*****" + filePath)
                //store downloadURL at database
                //self.databaseRef.child("users").child(FIRAuth.auth()!.currentUser!.uid).updateChildValues(["userPhoto": downloadURL])
            }
        }
        
        return filePath
    }
    
    func sendRequestToServer(img_path:String, completion: @escaping (_ result : String?)->()) {
        //let param = ["image_path":img_path]
        var escaped_path = img_path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let imageEndpoint = "http://159.203.166.121:8080/image_data/\(escaped_path)"
        
        guard let url = URL(string: imageEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                
                guard let productName = todo["product_name"] as? String else {
                    print("Could not get product name from JSON")
                    return
                }
                
                print(productName)
                completion(productName)
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
        // gtin_nm

    }
    
    
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cameraToAddItemSegue" {
            let navigationViewController = (segue.destination as! UINavigationController)
            let newItemTableViewController = navigationViewController.topViewController as! NewItemTableViewController
            newItemTableViewController.prefilledItemName = self.product!
            navigationViewController.view.tintColor = UIColor.black
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
