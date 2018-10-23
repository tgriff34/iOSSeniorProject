//
//  SignInViewController.swift
//  Minerva
//
//  Created by Tristan Griffin on 10/21/18.
//  Copyright © 2018 Tristan Griffin. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Set up textFields for use
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //If the user is already signed in, don't show the login page
        if Auth.auth().currentUser != nil {
            print("Current user: \(String(describing: Auth.auth().currentUser?.email))")
            self.performSegue(withIdentifier: "alreadySignedInToHome", sender: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Remove keyboard when return is pressed
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //MARK: Actions
    
    @IBAction func signInButton(_ sender: UIButton) {
        //Get the email and password fields and sign them in. If there isn't an error move them to the home screen else display an error.
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error == nil {
                    self.performSegue(withIdentifier: "signInToHome", sender: self)
                } else {
                    let alertController = UIAlertController(title: "Error", message: "Error signing in", preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
}
