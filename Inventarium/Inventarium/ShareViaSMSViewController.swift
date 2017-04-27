//
//  ShareViaSMSViewController.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 4/2/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import UIKit
import Firebase
import PhoneNumberKit

/*
 * ShareViaSMSViewController handles the sharing page where users can input a phone number and give them access to the chatbot and list
 */
class ShareViaSMSViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var shareButton: UIButton!
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)

    }
    
    var oldNumber:String?
    
    @IBAction func shareClicked(_ sender: UIButton) {
        var request = URLRequest(url: URL(string: "https://inventarium.me/share_list")!)
        request.httpMethod = "POST"
        let userEmail = FIRAuth.auth()!.currentUser!.email!
        let cleanUserEmail = userEmail.replacingOccurrences(of: ".", with: ",", options: .literal, range: nil)
        let postString = "user_email=\(cleanUserEmail)&recipient_phone_number=\(cleanNumber(textField.text!))"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error!)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {                           print("status should be 200 but is \(httpStatus.statusCode)")
                print("response = \(response!)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
        }
        task.resume()
        dismiss(animated: true, completion: nil)
    }
    
    func cleanNumber(_ num:String) -> String {
        var newNum = num.replacingOccurrences(of: "(", with: "", options: .literal, range: nil)
        newNum = newNum.replacingOccurrences(of: ")", with: "", options: .literal, range: nil)
        newNum = newNum.replacingOccurrences(of: "-", with: "", options: .literal, range: nil)
        newNum = newNum.replacingOccurrences(of: "+", with: "", options: .literal, range: nil)
        newNum = newNum.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        newNum = "1" + newNum
        return newNum
    }
    
    func validateNumber() {
        if !(textField.text?.isEmpty)! && textField.text?.characters.count == 14 {
            shareButton.isEnabled = true
        } else {
            shareButton.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.isEnabled = false
        textField.delegate = self
        textField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ShareViaSMSViewController.keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(ShareViaSMSViewController.keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func editingChanged(_ textField: UITextField) {
        validateNumber()
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        let keyboardHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.height
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.window?.frame.origin.y = -1 * keyboardHeight
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.window?.frame.origin.y = 0
            self.view.layoutIfNeeded()
        })
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
