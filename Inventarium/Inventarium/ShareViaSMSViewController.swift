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

class ShareViaSMSViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var shareButton: UIButton!
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)

    }
    
    var oldNumber:String?
    
    @IBAction func shareClicked(_ sender: UIButton) {
        var request = URLRequest(url: URL(string: "http://159.203.166.121:8080/share_list")!)
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
//        if (textField.text?.range(of: "*") == nil) && (textField.text?.range(of: "#") == nil) && (textField.text?.characters.count == 10){
//            shareButton.isEnabled = true
//            reformatValidNumber()
//        } else {
//            if (textField.text?.range(of: "(") != nil && (textField.text?.characters.count == 13)) {
//                shareButton.isEnabled = true
//            } else {
//                shareButton.isEnabled = false
//            }
//        }
    }
//
//    
//    func reformatValidNumber() {
//        oldNumber = textField.text
//        let leftParenthIndex = (textField.text?.startIndex)!
//        let rightParenthIndex = (textField.text?.characters.index((textField.text?.startIndex)!, offsetBy: 4))!
//        let dashIndex = (textField.text?.characters.index((textField.text?.startIndex)!, offsetBy: 8))!
//        
//        textField.text?.insert("(", at: leftParenthIndex)
//        textField.text?.insert(")", at: rightParenthIndex)
//        textField.text?.insert("-", at: dashIndex)
//    }

//    func reformatInvalidNumber(_ digit: String) {
//        if let number = oldNumber {
//            if (digit == "delete"){
//                let index = number.characters.index((number.startIndex), offsetBy: (number.characters.count) - 1)
//                let newNumber = number.substring(to:index)
//                textField.text = newNumber
//            } else {
//                textField.text = number + digit
//                oldNumber = nil
//            }
//        }
//    }
    
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
//        if textField.text?.characters.count == 1 {
//            if textField.text?.characters.first == " " {
//                textField.text = ""
//                return
//            }
//        }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
