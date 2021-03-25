//
//  SecureStoreError.swift
//  GistApp
//
//  Created by Ian Fagundes on 24/03/21.
//

import Foundation

enum SecureStoreError: Error {
    case stringToDataConversionError
    case dataToStringConversionError
    case unhandleError(message: String)
}

//MARK: LocalizedErrorDescription
extension SecureStoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .dataToStringConversionError:
            return NSLocalizedString("Error during data to string conversion", comment: "")
        case .stringToDataConversionError:
            return NSLocalizedString("Error during string to data conversion", comment: "")
        case .unhandleError(let message):
            return NSLocalizedString(message, comment: "")
        }
    }
}
