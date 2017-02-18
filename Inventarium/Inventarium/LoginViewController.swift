//
//  LoginViewController.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 2/10/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // MARK: Constants
    let loginToList = "LoginToList"
    
    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    // MARK: Actions
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        FIRAuth.auth()?.signIn(withEmail: textFieldLoginEmail.text!,
                               password: textFieldLoginPassword.text!) {(user, error) in
                                if (error != nil) {
                                    // an error occurred while attempting login
                                    if let errCode = FIRAuthErrorCode(rawValue: (error?._code)!) {
                                        switch errCode {
                                        case .errorCodeEmailAlreadyInUse:
                                            self.resetTextFields()
                                            print("Error: Email already in use")
                                        case .errorCodeInvalidEmail:
                                            self.resetTextFields()
                                            print("Error: Invalid email")
                                        case .errorCodeWrongPassword:
                                            self.resetTextFields()
                                            print("Error: Wrong Password")
                                        default:
                                            self.resetTextFields()
                                            print("Error: Unknown")
                                        }
                                    }
                                } else {
                                    self.showList()
                                    print("Login Success")
                                }
        }
    }
    
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in
                                        // Get the email and password from fields
                                        let emailField = alert.textFields![0]
                                        let passwordField = alert.textFields![1]
                                        
                                        // Create a firebase user using email and password
                                        FIRAuth.auth()!.createUser(withEmail: emailField.text!,
                                                                   password: passwordField.text!) { user, error in
                                                                    if error == nil {
                                                                        // If there is no error, login with the new info
                                                                        FIRAuth.auth()!.signIn(withEmail: self.textFieldLoginEmail.text!,
                                                                                               password: self.textFieldLoginPassword.text!)
                                                                    }
                                        }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func logout() {
        try! FIRAuth.auth()!.signOut()
    }
    
    func resetTextFields() {
        self.textFieldLoginEmail.text = ""
        self.textFieldLoginEmail.placeholder = "Email"
        self.textFieldLoginPassword.text = ""
        self.textFieldLoginPassword.placeholder = "Password"
    }
    
    func showList() {
        performSegue(withIdentifier: loginToList, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldLoginEmail.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let image = UIImage(named: "mail_icon")
        imageView.image = image
        textFieldLoginEmail.leftView = imageView
        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
            // If the user is signed in
            if user != nil {
                // Load list
                self.performSegue(withIdentifier: self.loginToList, sender: nil)
            }
        }
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
            textFieldLoginPassword.becomeFirstResponder()
        }
        if textField == textFieldLoginPassword {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
