//
//  APIManager.swift
//  GistApp
//
//  Created by Ian Fagundes on 23/03/21.
//

import Foundation
import Alamofire

class APIManager {
    
    static let shared = APIManager()
    
    let sessionManager: Session = {
    
        let configuration = URLSessionConfiguration.af.default
        
        configuration.timeoutIntervalForRequest = 30
        configuration.waitsForConnectivity = true
        
        let networkLogger = APINetworkLogger()
        let interceptor = APIRequestInterceptor()
        
        return Session(configuration: configuration, interceptor: interceptor, eventMonitors: [networkLogger])
    }()
    
    func getAccessToken(accessCode: String, completion: @escaping (Bool) -> Void) {
        
        let headers: HTTPHeaders = ["Accept": "application/json"]
        
        let parameters = [
            "client_id": APIConstants.clientID,
            "client_secret": APIConstants.clientSecret,
            "code": accessCode
        ]
        
        sessionManager.request("https://github.com/login/oauth/access_token", method: .post, parameters: parameters, headers: headers)
            .responseDecodable(of: APIAccessToken.self) { response in
                guard let credencial = response.value else {
                    return completion(false)
                }
                APITokenManager.shared.saveAccessToken(apiToken: credencial)
                print(credencial)
                completion(true)
            }
    }
}
