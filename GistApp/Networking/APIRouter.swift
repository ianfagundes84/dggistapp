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
    case publishComment(commentText:String)
    case updateComment((commentText: String, commentID: String))
    case deleteComment(commentID: String)
    
    var baseURL: String {
        switch self {
        case .getAccessToken:
            return "https://github.com"
        case .getComments,
             .publishComment,
             .updateComment,
             .deleteComment:
            return "https://api.github.com"
        }
    }
    
    var path: String {
        switch self {
        case .getAccessToken:
            return "/login/oauth/access_token"
        case .getComments,
             .publishComment:
            return "/gists/\(APIConstants.gistID)/comments"
        case .deleteComment(let commentID):
            return "/gists/\(APIConstants.gistID)/comments/\(commentID)"
        case .updateComment(let tuple):
            return "/gists/\(APIConstants.gistID)/comments/\(tuple.1)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAccessToken,
             .publishComment:
            return .post
        case .updateComment:
            return .patch
        case .getComments:
            return .get
        case .deleteComment:
            return .delete
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
        case .getComments,
             .deleteComment:
            return [:]
        case .publishComment(let commentText):
            return ["body": commentText]
        case .updateComment((let tuple)):
            return ["body": tuple.0]
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
        } else if method == .post || method == .patch || method == .delete {
            request = try JSONParameterEncoder().encode(parameters, into: request)
            request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        }
        return request
    }
}
