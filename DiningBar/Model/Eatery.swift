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
    let about : String
    let aboutshort : String
    let cornellDining : Bool
    let latitude : Double
    let longitude : Double
    let location : String
    let operatingHours : [OperatingHours]
    
    //let eateryTypes : [[Int:EateryType]]
}

struct EateryType: Decodable {
    let descr : String
    let descrshort : String
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
    let start: String
    let end: String
    let menu: [MenuCategory]
}

struct MenuCategory: Decodable {
    let category: String
    let items: [MenuItem]
}

/*struct Menu: Decodable {
    //let category: String
    //let items: [MenuItem]
}*/

struct MenuItem: Decodable {
    let item: String
    let healthy: Bool
}
