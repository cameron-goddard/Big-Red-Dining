//
//  NetworkManager.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/18/22.
//

import Foundation

enum NetworkManager {
    
    #if TESTING
    private static let host = "http://localhost:8000/eateries"
    #else
    private static let host = "https://admin-now.dining.cornell.edu/api/1.0/dining/eateries.json"
    #endif
    
    /// Queries the Cornell Dining API for eatery info.
    /// - Returns: A list of ``Eatery`` objects
    static func getEateryInfo() async throws -> [Eatery] {
        guard let url = URL(string: host) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        #if TESTING
        return try JSONDecoder().decode([Eatery].self, from: data)
        #else
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.data["eateries"] ?? []
        #endif
    }
}
