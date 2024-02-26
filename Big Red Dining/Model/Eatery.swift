//
//  Eatery.swift
//  Big Red Dining
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
    let diningItems : [DiningItem]
}

struct DiningItem: Decodable {
    let category : String
    let item : String
}

struct OperatingHours: Decodable {
    let date: String
    let status: String
    let events: [Event]
}

struct Event: Decodable {
    let descr: String
    let start: String
    let end: String
    let startTimestamp: Int
    let endTimestamp: Int
    let menu: [MenuCategory]
}

struct MenuCategory: Decodable {
    let category: String
    var items: [MenuItem]
}

struct MenuItem: Decodable {
    let item: String
}
