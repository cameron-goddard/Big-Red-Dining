//
//  Dining API.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/18/22.
//

import Foundation

class NetworkManager {
    
    #if TESTING
    static let host = "http://localhost:8000/eateries"
    #else
    static let host = "https://now.dining.cornell.edu/api/1.0/dining/eateries.json"
    #endif
    
    public static func getEateryInfo(completion: @escaping (_ json: [Eatery]?, _ error: Error?)-> ()) {
        let request = URLRequest(url: URL(string: host)!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            do {
                #if TESTING
                let parsedJSON = try JSONDecoder().decode([Eatery].self, from: data)
                completion(parsedJSON, error)
                #else
                let parsedJSON = try JSONDecoder().decode(Root.self, from: data)
                completion(parsedJSON.data["eateries"], error)
                #endif
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}
