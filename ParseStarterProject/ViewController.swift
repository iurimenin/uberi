/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

@available(iOS 8.0, *)
class ViewController: UIViewController, UITextFieldDelegate {

    var signUpActive = true
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passageiroLabel: UILabel!
    @IBOutlet weak var motoristaLabel: UILabel!
    @IBOutlet weak var userIsDriver: UISwitch!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var toggleSingUpButton: UIButton!
    
    @IBAction func signUp(sender: AnyObject) {
    
        if (username.text == "" || password.text == "") {
        
            mostraAlert("Ooops", message: "É preciso informar usuário e senha!")
        } else {
            
            if signUpActive == true {
                
                //Cadastra usuário
                let user = PFUser()
                user.username = self.username.text
                user.password = self.password.text
                user["isDriver"] = userIsDriver.on
                
                user.signUpInBackgroundWithBlock {(succeeded: Bool, error: NSError?) -> Void in
                    
                    if let error = error {
                        
                        if let errorString = error.userInfo["error"] as? String {
                        
                            self.mostraAlert("Falha no cadastro", message: errorString)
                        }
                    } else {
                        
                        self.performSegueWithIdentifier("loginPassageiro", sender: self)
                    }
                }
            } else {
                
                //Realiza Login
                PFUser.logInWithUsernameInBackground(self.username.text!, password: self.password.text!, block: { (user: PFUser?, error: NSError?) in
                    
                    if user != nil {
                        
                        self.redirectUser()
                    } else {
                        
                        if let error = error {

                            if let errorString = error.userInfo["error"] as? String {
                            
                                self.mostraAlert("Falha no entrar", message: errorString)
                            }
                        }
                    }
                })
            }
        }
        
    }
    
    @IBAction func toggleSignUp(sender: AnyObject) {
    
        if signUpActive == true {
            
            signUpButton.setTitle("Entrar", forState: .Normal)
            toggleSingUpButton.setTitle("Cadastre-se", forState: UIControlState.Normal)
            signUpActive = false
            
            passageiroLabel.alpha = 0
            motoristaLabel.alpha = 0
            userIsDriver.alpha = 0
        } else {
            
            signUpButton.setTitle("Cadastrar", forState: .Normal)
            toggleSingUpButton.setTitle("Realize seu login", forState: UIControlState.Normal)
            signUpActive = true
            
            passageiroLabel.alpha = 1
            motoristaLabel.alpha = 1
            userIsDriver.alpha = 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.username.delegate = self
        self.password.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.escondeTeclado))
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil && PFUser.currentUser()?.username != nil {
            redirectUser()
        }
    }
    
    func mostraAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func escondeTeclado(){
        self.view.endEditing(true)
    }
    
    func redirectUser () {
        
        var segueName = "loginPassageiro"
        
        if PFUser.currentUser()?["isDriver"]! as! Bool == true {
            segueName = "loginMotorista"
        }
        
        performSegueWithIdentifier(segueName, sender: self)
    }
}
