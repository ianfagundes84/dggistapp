//
//  SecureStoreQueryable.swift
//  GistApp
//
//  Created by Ian Fagundes on 24/03/21.
//

import Foundation

protocol SecureStoreQueryable {
    var query: [String: Any] { get }
}

struct PasswordQueryable {
    let service: String
    let accessGroup: String?
    
    init(service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }
}

extension PasswordQueryable: SecureStoreQueryable {
    var query: [String : Any] {
        var query: [String: Any] = [:]
        query[String(kSecClass)] = kSecClassGenericPassword
        query[String(kSecAttrService)] = service
        
        #if !targetEnvironment(simulator)
        if let accessGroup = accessGroup {
            query[String(kSecAttrAccessGroup)] = accessGroup
        }
        #endif
    return query
    }
}
