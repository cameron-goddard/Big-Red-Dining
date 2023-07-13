//
//  EateryInfo.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/20/22.
//

import Foundation

var noEateryInfo = false

class EateryInfo {
    let name: String
    let icon: String
    let location: Int
    let id: Int
    var events: [Event]
    
    init(name: String, icon: String, location: Int, id: Int, events: [Event]) {
        self.name = name
        self.icon = icon
        self.location = location
        self.id = id
        self.events = events
    }
}

var allEateries = [
    EateryInfo(name: "Morrison", icon: "text.book.closed", location: 2, id: 43, events: []),
    EateryInfo(name: "North Star", icon: "moon.stars.fill", location: 2, id: 3, events: []),
    EateryInfo(name: "Risley", icon: "theatermasks", location: 2, id: 4, events: []),
    EateryInfo(name: "104West!", icon: "fork.knife", location: 0, id: 31, events: []),
    EateryInfo(name: "Becker", icon: "books.vertical", location: 0, id: 25, events: []),
    EateryInfo(name: "Bethe", icon: "atom", location: 0, id: 27, events: []),
    EateryInfo(name: "Cook", icon: "hammer", location: 0, id: 26, events: []),
    EateryInfo(name: "Keeton", icon: "pawprint.fill", location: 0, id: 29, events: []),
    EateryInfo(name: "Rose", icon: "lightbulb", location: 0, id: 30, events: []),
    EateryInfo(name: "Okenshields", icon: "crown", location: 1, id: 20, events: [])
]
