//
//  ScannerViewController.swift
//  GistApp
//
//  Created by Ian Fagundes on 24/03/21.
//

import UIKit

class ScannerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: Clear test bellow
//        APITokenManager.shared.clearAccessToken()
        APIManager.shared.getComments { status in
            print(status)
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
