//
//  Eatery.swift
//  DiningBar
//
//  Created by Cameron Goddard on 12/18/22.
//

import Foundation

struct Root: Decodable {
    let status : String
    let data : [String:[Eatery]]
}

struct Eatery: Decodable {
    let id : Int
    let name : String
    let operatingHours : [OperatingHours]
}

struct OperatingHours: Decodable {
    let date: String
    let status: String
    let events: [Event]
}

struct Event: Decodable {
    let descr: String
    let startTimestamp: Int
    let endTimestamp: Int
    let menu: [MenuCategory]
}

struct MenuCategory: Decodable {
    let category: String
    let items: [MenuItem]
}

struct MenuItem: Decodable {
    let item: String
    let healthy: Bool
}
