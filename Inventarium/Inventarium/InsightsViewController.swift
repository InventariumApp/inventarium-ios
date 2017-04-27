//
//  InsightsViewController.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 4/20/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import UIKit

/*
 * InightsViewController handles the insights page (showing graphs regarding the user's purchases)
 */
class InsightsViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var insightsSegmentedControl: UISegmentedControl!
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Change graph when user clicks segmented controller
    @IBAction func graphChanged(_ sender: UISegmentedControl) {
        switch insightsSegmentedControl.selectedSegmentIndex {
        case 0:
            setWebView(url: "https://inventarium.me/graphs/top_categories/iphoneaccount%40gmail%2ccom")
        case 1:
            setWebView(url: "https://inventarium.me/graphs/top_products/iphoneaccount%40gmail%2ccom")
        default:
            break;
        }
    }

    
    

    func setWebView(url:String) {
        let url = URL(string: url)
        webView.loadRequest(URLRequest(url: url!))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.scrollView.isScrollEnabled = false
        setWebView(url: "https://inventarium.me/graphs/top_categories/iphoneaccount%40gmail%2ccom")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
