//
//  StartViewController.swift
//  GistApp
//
//  Created by Ian Fagundes on 24/03/21.
//

import UIKit
import TransitionButton

class StartViewController: UIViewController {
    
    @IBOutlet weak var btStartScan: TransitionButton!
    
    //computed variable to recovery token and save user status
    var isLoggedIn: Bool {
        if APITokenManager.shared.fetchAccessToken() != nil {
            return true
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    
    //Login status is tested when button is clicked
    @IBAction func btEnter(_ sender: TransitionButton) {
        btStartScan.startAnimation()
        DispatchQueue.main.async {
            self.btStartScan.stopAnimation(animationStyle: .expand) {
                if self.isLoggedIn {
                    if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "scannerVC") as? ScannerViewController {
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                } else {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            }
        }
    }
    
    @IBAction func logout(_ sender: UIButton) {
        APITokenManager.shared.clearAccessToken()
    }
}

