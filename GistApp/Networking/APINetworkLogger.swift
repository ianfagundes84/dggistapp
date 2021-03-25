//
//  APINetworkLogger.swift
//  GistApp
//
//  Created by Ian Fagundes on 24/03/21.
//

import Foundation
import Alamofire

class APINetworkLogger: EventMonitor {
    
    let queue = DispatchQueue(label: "com.ianfagundes.dggistapp.networklogger")
    
    func requestDidFinish(_ request: Request) {
        print(request.description)
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        
        guard let data = response.data else { return }
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
            print(json)
        }
    }
}
