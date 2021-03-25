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
        
        sessionManager.request(APIRouter.getAccessToken(accessCode))
            .responseDecodable(of: APIAccessToken.self) { response in
                guard let credencial = response.value else {
                    return completion(false)
                }
                APITokenManager.shared.saveAccessToken(apiToken: credencial)
                print(credencial)
                completion(true)
            }
    }
    
    func getComments(completion: @escaping (Bool) -> Void) {
        
        sessionManager.request(APIRouter.getComments)
            .responseDecodable(of: Comment.self) { response in
                print(response)
                guard let comment = response.value else {
                    return completion(false)
                }
//                print(gistData)
                completion(true)
            }
    }
}
