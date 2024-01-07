//
//  EateryInfo.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/20/22.
//

import Foundation
import OrderedCollections

var noEateryInfo = false

class EateryInfo {
    let name: String
    let icon: String
    let location: Int
    var obj: Eatery? {
        didSet {
            // Get the current day's events - Will always be the second operating hour
            #if TESTING
            self.events = (obj?.operatingHours[4].events)!
            #else
            self.events = (obj?.operatingHours[1].events)!
            #endif
        }
    }
    var events: [Event]
    
    init(name: String, icon: String, location: Int, obj: Eatery? = nil) {
        self.name = name
        self.icon = icon
        self.location = location
        self.obj = obj
        self.events = [] // TODO: Change to Optional to account for no data available
    }
}

var allEateries : OrderedDictionary = [
    // North
    43: EateryInfo(name: "Morrison", icon: "text.book.closed", location: 2),
    3: EateryInfo(name: "North Star", icon: "moon.stars.fill", location: 2),
    4: EateryInfo(name: "Risley", icon: "theatermasks", location: 2),
    
    // West
    31: EateryInfo(name: "104West!", icon: "fork.knife", location: 0),
    25: EateryInfo(name: "Becker", icon: "books.vertical", location: 0),
    27: EateryInfo(name: "Bethe", icon: "atom", location: 0),
    26: EateryInfo(name: "Cook", icon: "hammer", location: 0),
    29: EateryInfo(name: "Keeton", icon: "pawprint.fill", location: 0),
    30: EateryInfo(name: "Rose", icon: "lightbulb", location: 0),
    
    // Central
    20: EateryInfo(name: "Okenshields", icon: "crown", location: 1)
]
