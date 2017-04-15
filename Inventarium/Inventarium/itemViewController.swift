//
//  itemViewController.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 4/12/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import UIKit
import SafariServices

class itemViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemCount: UILabel!
    @IBOutlet weak var itemBackground: CardView!
    @IBOutlet weak var insightsWebView: UIWebView!
    @IBOutlet weak var whiteBackground: UILabel!
    
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
        itemName.text = itemNameString
        itemCount.text = itemCountString
        
        self.navigationController?.navigationBar.isHidden = true;

        whiteBackground.isUserInteractionEnabled = true
    
        
        let url = URL(string: "http://159.203.166.121:8080/graphs")
        insightsWebView.loadRequest(URLRequest(url: url!))
        

        // Do any additional setup after loading the view.
    }
    
    func loadAmazonPage(_ web_url: String) {
        let vc = SFSafariViewController(url: URL(string: web_url)!)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
        //present(vc, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
