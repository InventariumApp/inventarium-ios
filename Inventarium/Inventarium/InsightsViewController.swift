//
//  InsightsViewController.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 4/20/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import UIKit

class InsightsViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var insightsSegmentedControl: UISegmentedControl!
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
