//
//  itemViewController.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 4/12/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import UIKit

class itemViewController: UIViewController {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemCount: UILabel!
    var itemCountString: String?
    var itemNameString: String?
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        itemName.text = itemNameString
        itemCount.text = itemCountString
        
        self.navigationController?.navigationBar.isHidden = true;

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
