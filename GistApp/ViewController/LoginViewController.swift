//
//  LoginViewController.swift
//  GistApp
//
//  Created by Ian Fagundes on 23/03/21.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {
    var webAuthSession: ASWebAuthenticationSession?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAuthTokenWithWebLogin()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getAuthTokenWithWebLogin() {
        var authURLComponents = URLComponents(string: APIConstants.authorizeURL)
        authURLComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: APIConstants.clientID),
            URLQueryItem(name: "scope", value: APIConstants.scope)
        ]
        
        guard let authURL = authURLComponents?.url else { return }
        
        webAuthSession = ASWebAuthenticationSession.init(url: authURL, callbackURLScheme: APIConstants.redirectURI) { (callBack: URL?, error: Error?) in
            guard error == nil, let successURL = callBack else {
                return
            }
            
            guard let accessCode = URLComponents(string: (successURL.absoluteString))?.queryItems?.first(where: { $0.name == "code"}) else {
                return
            }
            
            guard let value = accessCode.value else { return }
            
            print("Access Code Value is: \(value)")
            
            APIManager.shared.getAccessToken(accessCode: value) { [self] isSuccess in
                if !isSuccess {
                    print("Error obtaining token")
                }
                navigationController?.popViewController(animated: true)
            }
        }
        webAuthSession?.presentationContextProvider = self
        webAuthSession?.start()
    }
}

extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window ?? ASPresentationAnchor()
    }
}
