//
//  SweetsTableViewController.swift
//  FireSwiffer
//
//  Created by Justin Lazarski on 8/23/16.
//  Copyright © 2016 Justin Lazarski. All rights reserved.
//
// Justin Lazarski

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SweetsTableViewController: UITableViewController {
    
    var dbRef:FIRDatabaseReference!
    var sweets = [Sweet]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = FIRDatabase.database().reference().child("sweet-items")
        startObservingDB()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth:FIRAuth, user:FIRUser?) in
            if let user = user {
                print("Welcome \(user.email)")
                self.startObservingDB()
            }
            else{
                print("Please sign up or login first")
            }
        })
        
    }
    
    @IBAction func loginAndSignUp(sender: UIBarButtonItem) {
        
        let userAlert = UIAlertController(title: "Login/Sign Up", message: "Enter email and Password", preferredStyle: .Alert)
        userAlert.addTextFieldWithConfigurationHandler { (textfield:UITextField) in
            textfield.placeholder = "Email"
        }
        
        userAlert.addTextFieldWithConfigurationHandler{ (textfield:UITextField) in
            textfield.secureTextEntry = true
            textfield.placeholder = "Password"
        }
        
        userAlert.addAction(UIAlertAction(title: "Sign in", style: .Default, handler: { (action: UIAlertAction) in
            let emailTextField = userAlert.textFields!.first!
            let passwordTextField = userAlert.textFields!.last!
            
            FIRAuth.auth()?.signInWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: { (user:FIRUser?, error:NSError?) in
                if error != nil
                {
                    print(error?.description)
                }
                
            })
        }))
        userAlert.addAction(UIAlertAction(title: "Sign up", style: .Default, handler: { (action: UIAlertAction) in
            let emailTextField = userAlert.textFields!.first!
            let passwordTextField = userAlert.textFields!.last!
            
            FIRAuth.auth()?.createUserWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: { (user:FIRUser?, error:NSError?) in
                if error != nil {
                    print(error?.description)
                }
                
                
            })
        }))
        self.presentViewController(userAlert, animated: true, completion: nil)
        
    }
    func startObservingDB () {
        dbRef.observeEventType(.Value, withBlock: { (snapshot:FIRDataSnapshot) in
            var newSweets = [Sweet]()
            
            for sweet in snapshot.children {
                let sweetObject = Sweet(snapshot: sweet as! FIRDataSnapshot)
                newSweets.append(sweetObject)
            }
            self.sweets = newSweets
            self.tableView.reloadData()
            
        }) { (error:NSError) in
            print(error.description)
        }
    }
    
    
    @IBAction func addSweet(sender: UIBarButtonItem) {
        let sweetAlert = UIAlertController(title: "New Sweet", message: "Enter your Sweet", preferredStyle: .Alert)
        sweetAlert.addTextFieldWithConfigurationHandler { (textField:UITextField) in
            textField.placeholder = "Your Sweet"
        }
        /*sweetAlert.addAction(UIAlertAction(title: "Send", style: .Default, handler: { (action:UIAlertAction) in
            if let sweetContent = sweetAlert.textFields?.first?.text {
                let sweet = Sweet(content: sweetContent, addedByUser: "Justin Lazarski")
                
                let sweetRef = self.dbRef.child(sweetContent.lowercaseString)
                
                sweetRef.setValue(sweet.toAnyObject())
            }
            
              }))*/
        
        
        let sendAction = UIAlertAction(title: "Send", style: .Default) { (action:UIAlertAction) in
            if let sweetContent = sweetAlert.textFields?.first?.text {
                let sweet = Sweet(content: sweetContent, addedByUser: "Justin Lazarski")
                
                let sweetRef = self.dbRef.child(sweetContent.lowercaseString)
                
                sweetRef.setValue(sweet.toAnyObject())
            }
            
        }

        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Default) { (action: UIAlertAction) -> Void in
        }
        sweetAlert.addAction(sendAction)
        sweetAlert.addAction(cancelAction)
        presentViewController(sweetAlert, animated: true, completion: nil)
}

// MARK: - Table view data source

override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
}

override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sweets.count
}


override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    
    let sweet = sweets[indexPath.row]
    cell.textLabel?.text = sweet.content
    cell.detailTextLabel?.text = sweet.addedByUser
    return cell
    
    
}
override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
        let sweet = sweets[indexPath.row]
        
        sweet.itemRef?.removeValue()
    }
}


}