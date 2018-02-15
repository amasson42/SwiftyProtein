//
//  ViewController.swift
//  Swifty Protein
//
//  Created by Paul DESPRES on 2/15/18.
//  Copyright © 2018 Paul DESPRES. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func authenticate () {
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: NSLocalizedString("Swifty Protein is locked", comment: ""), reply: { (success, error) in
                if success {
                    DispatchQueue.main.async {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let innerPage: UINavigationController = mainStoryboard.instantiateViewController(withIdentifier:"NavToList") as! UINavigationController
                        appDelegate.window?.rootViewController = innerPage
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alert()
                    }
                }
            })
        }
        
    }
}

//  "popup" d'erreur
extension LoginViewController {
    
    func alert() {
//        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let alert = UIAlertController(title: "Authentification failed!", message: "Would you like to retry or exit?", preferredStyle: .alert)
        
        let OkAction        = UIAlertAction(title: "Retry", style: .default, handler: handleOK)
        let DeleteAction    = UIAlertAction(title: "Give Up", style: .destructive, handler: handleDelete)
//        let CancelAction    = UIAlertAction(title: "Cancel", style: .cancel, handler: handleCancel)
        
        alert.addAction(OkAction)
        alert.addAction(DeleteAction)
//        alert.addAction(CancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleOK(alertAction: UIAlertAction!) -> Void {
        self.authenticate()
    }
    func handleDelete(alertAction: UIAlertAction!) -> Void {
        exit(42)
    }
    func handleCancel(alertAction: UIAlertAction!) {
    }
    
}

