//
//  APIRouter.swift
//  GistApp
//
//  Created by Ian Fagundes on 24/03/21.
//

import UIKit
import Alamofire

enum APIRouter {
    case getAccessToken(String)
    
    var baseURL: String {
        switch self {
        case .getAccessToken:
            return "https://github.com"
        }
    }
    
    var path: String {
        switch self {
        case .getAccessToken:
            return "/login/oauth/access_token"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAccessToken:
            return .post
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .getAccessToken(let accessCode):
            return [
                "client_id": APIConstants.clientID,
                "client_secret": APIConstants.clientSecret,
                "code": accessCode
            ]
        }
    }
}

extension APIRouter: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL().appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method
        
        if method == .get {
            request = try URLEncodedFormParameterEncoder().encode(parameters, into: request)
        } else if method == .post {
            request = try JSONParameterEncoder().encode(parameters, into: request)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        return request
    }
}
