//
//  StartViewController.swift
//  GistApp
//
//  Created by Ian Fagundes on 24/03/21.
//

import UIKit

class StartViewController: UIViewController {

//computed variable to recovery token and save user status
    var isLoggedIn: Bool {
        if APITokenManager.shared.fetchAccessToken() != nil {
            return true
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        APITokenManager.shared.clearAccessToken()
    }
    
//Login status is tested when button is clicked
    @IBAction func btEnter(_ sender: UIButton) {
        if isLoggedIn {
            self.performSegue(withIdentifier: "scannerSegue", sender: nil)
        } else {
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }
}



