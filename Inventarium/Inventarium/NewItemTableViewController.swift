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

    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var itemNameTextField: UITextField!
    
    var item:GroceryItem?
    var prefilledItemName:String? = nil
    var price:String? = nil
    var imageURL:String? = nil
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        if let _ = self.price, let _ = imageURL {
            self.performSegue(withIdentifier: "NewItem", sender: self)
        } else {
            lookupItemName() { product  in
                if product.count != 0 {
                    print(product)
                    DispatchQueue.main.async {
                        self.imageURL = product[2]
                        self.price = product[1]
                        self.performSegue(withIdentifier: "NewItem", sender: self)
                    }
                }
            }
        }
    }
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
    
    func lookupItemName(completion: @escaping (_ result : [String?])->()) {
        let itemNameEncoded = itemNameTextField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let itemEndpoint: String = "http://159.203.166.121:8080/product_data_for_name/\(itemNameEncoded)"
        guard let url = URL(string: itemEndpoint) else {
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
                
                guard let productName = todo["clean_nm"] as? String else {
                    print("Could not get product name from JSON")
                    return
                }
                
                guard let productImageURL = todo["image_url"] as? String else {
                    print("Could not get product image url from JSON")
                    return
                }
                
                guard let productPrice = todo["price"] as? String else {
                    print("Could not get product price from JSON")
                    return
                }
                
                let data = [productName, productPrice, productImageURL]
                
                completion(data)
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
        // gtin_nm
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewItem" {
            print("Blahoo")
            item = GroceryItem(name: itemNameTextField.text!, addedByUser: "mike", count: Int(countTextField.text!)!, price: price!, imageURL: imageURL!)
        }
    }
}
