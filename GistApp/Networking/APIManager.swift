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
    
    func getComments(completion: @escaping (Result<Comment?, Swift.Error>) -> Void) {
        
        sessionManager.request(APIRouter.getComments)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: Comment.self) { response in
                guard let comment = response.value else {
                    completion(.failure(response.error!))
                    return
                }
                completion(.success(comment))
            }
    }
    
    func publishComment(commentText: String, completion: @escaping (Result<CommentElement, Swift.Error>) -> Void) {
        
        sessionManager.request(APIRouter.publishComment(commentText: commentText))
            .validate(statusCode: 200..<300)
            .responseDecodable(of: CommentElement.self) { response in
                guard let commentElement = response.value else {
                    completion(.failure(response.error!))
                    return
                }
                completion(.success(commentElement))
            }
    }
    
    func updateComment(commentText: String, commentID: String, completion: @escaping (Result<CommentElement, Swift.Error>) -> Void) {
                
        sessionManager.request(APIRouter.updateComment((commentText, commentID)))
            .validate(statusCode: 200..<300)
            .responseDecodable(of: CommentElement.self) { response in
                guard let commentElement = response.value else {
                    completion(.failure(response.error!))
                    return
                }
                completion(.success(commentElement))
            }
    }
    
    func deleteComment(commentIndex: String, completion: @escaping (Bool) -> Void) {
        
        sessionManager.request(APIRouter.deleteComment(commentID: commentIndex))
            .validate(statusCode: 200..<300)
            .response { response in
                if response.error != nil {
                    completion(false)
                    return
                }
                completion(true)
            }
    }
}
