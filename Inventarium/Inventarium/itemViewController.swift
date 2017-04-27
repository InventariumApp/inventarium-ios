//
//  itemViewController.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 4/12/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import UIKit
import SafariServices

/*
 * itemViewController displays the item's price, insights, and purchase link
 */
class itemViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemCount: UILabel!
    @IBOutlet weak var itemBackground: CardView!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var insightsWebView: UIWebView!
    @IBOutlet weak var itemImageView: UIImageView!
    
    var itemPriceString: UILabel!

    var itemCountString: String?
    var itemNameString: String?
    var item: GroceryItem?
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        itemCount.heroModifiers = [.fade, .scale(0.5)]
        itemName.heroModifiers = [.fade, .scale(0.5)]
        itemBackground.heroModifiers = [.fade, .scale(0.5)]
    }
    
    @IBAction func buyNowButtonClicked(_ sender: UIButton) {
        loadAmazonPage((item?.getAmazonLink())!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemName.text = itemNameString?.capitalized
        itemCount.text = itemCountString
        if let price = item?.price {
            itemPrice.text = price
        }
        
        self.navigationController?.navigationBar.isHidden = true;    
        insightsWebView.scrollView.isScrollEnabled = false
        
        let itemNameEncoded = itemNameString?.lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = URL(string: "https://inventarium.me/graphs/line_graph/iphoneaccount%40gmail%2ccom/\(itemNameEncoded!)")
        insightsWebView.loadRequest(URLRequest(url: url!))
        if let url = item?.imageURL {
            itemImageView.imageFromServerURL(urlString: url)
        }
    }
    
    func loadAmazonPage(_ web_url: String) {
        let vc = SFSafariViewController(url: URL(string: web_url)!)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }}
