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
    case getComments
    
    var baseURL: String {
        switch self {
        case .getAccessToken:
            return "https://github.com"
        case .getComments:
            return "https://api.github.com"
        }
    }
    
    var path: String {
        switch self {
        case .getAccessToken:
            return "/login/oauth/access_token"
        case .getComments:
            return "/gists/\(APIConstants.gistID)/comments"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAccessToken:
            return .post
        case .getComments:
            return .get
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
        case .getComments:
            return [:]
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
            request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        }
        return request
    }
}
