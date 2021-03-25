//
//  APIAccessToken.swift
//  GistApp
//
//  Created by Ian Fagundes on 23/03/21.
//

import Foundation

struct APIAccessToken: Decodable {
    let accessToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}
