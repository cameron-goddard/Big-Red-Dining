//
//  Dining API.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/18/22.
//

import Foundation

import Foundation

class NetworkManager {
    
    static let host = "https://now.dining.cornell.edu/api/1.0/dining/eateries.json"
    
    public static func getEateryInfo(completion: @escaping (_ json: Root?, _ error: Error?)-> ()) {
        let request = URLRequest(url: URL(string: host)!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            do {
                let parsedJSON = try JSONDecoder().decode(Root.self, from: data)
                completion(parsedJSON, error)
                
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}
