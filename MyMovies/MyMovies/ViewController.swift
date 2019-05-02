//
//  ViewController.swift
//  MyMovies
//
//  Created by Luke Seo on 4/28/19.
//  Copyright © 2019 Luke Seo. All rights reserved.
//

import UIKit
import FirebaseUI

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    @IBAction func loginClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "Login",
                                      message: "Enter email and password.", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Email"
        })
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            print("Cancel.")
        }))
        
        alert.addAction(UIAlertAction(title: "Login", style: .default,
                                      handler: { (action) in
                                        let email = alert.textFields?[0].text
                                        let password = alert.textFields?[1].text
                                        Auth.auth().signIn(withEmail: email!, password: password!) { [weak self] user, error in
                                            guard self != nil else { return }
                                            if let user = user {
                                                // The user's ID, unique to the Firebase project.
                                                // Do NOT use this value to authenticate with your backend server,
                                                // if you have one. Use getTokenWithCompletion:completion: instead.
                                                let uid = user.user.uid
                                                let email = user.user.email
                                                self?.performSegue(withIdentifier: "showMovies", sender: self)
                                            } else {
                                                print("Didn't sign in ")
                                            }
                                        }

        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signupClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "Login",
                                      message: "Enter email and password.", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Email"
        })
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            print("Cancel.")
        }))
        
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (action) in
            let email = alert.textFields?[0].text
            let password = alert.textFields?[1].text
            print("email = \(email!), password = \(password!)")
            Auth.auth().createUser(withEmail: email!, password: password!) { authResult, error in
                if error == nil {
                    Auth.auth().signIn(withEmail: email!, password: password!) { [weak self] user, error in
                        guard self != nil else { return }
                        if let user = user {
                            // The user's ID, unique to the Firebase project.
                            // Do NOT use this value to authenticate with your backend server,
                            // if you have one. Use getTokenWithCompletion:completion: instead.
                            let uid = user.user.uid
                            let email = user.user.email
                            print("~~~~~~ signed in/signed up ~~~~~~~")
                            print(uid)
                            print(email!)
                            self?.performSegue(withIdentifier: "showMovies", sender: self)
                        }
                    }
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func guestClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showMovies", sender: self)
    }
}
