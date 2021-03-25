//
//  APITokenManager.swift
//  GistApp
//
//  Created by Ian Fagundes on 24/03/21.
//

import Foundation

class APITokenManager {
    let userAccount = "accessToken"
    
    static let shared = APITokenManager()
    
    let secureStore: SecureStore = {
        let accessTokenQueryable = PasswordQueryable(service: "GistService")
        return SecureStore(secureStoreQueryable: accessTokenQueryable)
    }()
    
    func saveAccessToken(apiToken: APIAccessToken) {
        do {
            try secureStore.setValue(apiToken.accessToken, for: userAccount)
        } catch let ex {
            print("Error saving access token: \(ex)")
        }
    }
    
    func fetchAccessToken() -> String? {
        do {
            return try secureStore.getValue(for: userAccount)
        } catch let ex {
            print("Error fetching access token: \(ex)")
        }
        return nil
    }
    
    func clearAccessToken() {
        do {
            return try secureStore.removeValue(for: userAccount)
        } catch let ex {
            print("Error clearing access token: \(ex)")
        }
    }
}
