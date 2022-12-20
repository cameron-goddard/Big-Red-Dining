//
//  EateryInfo.swift
//  DiningBar
//
//  Created by Cameron Goddard on 12/20/22.
//

import Foundation

struct EateryInfo {
    let name: String
    let icon: String
    let location: Int
    let id: Int
    var events: [Event]
}

var allEateries = [
    EateryInfo(name: "Morrison", icon: "text.book.closed", location: 2, id: 43, events: []),
    EateryInfo(name: "North Star", icon: "moon.stars.fill", location: 2, id: 3, events: []),
    EateryInfo(name: "Risley", icon: "theatermasks", location: 2, id: 4, events: []),
    EateryInfo(name: "104West!", icon: "fork.knife", location: 0, id: 31, events: []),
    EateryInfo(name: "Becker House", icon: "books.vertical", location: 0, id: 25, events: []),
    EateryInfo(name: "Bethe House", icon: "atom", location: 0, id: 27, events: []),
    EateryInfo(name: "Cook House", icon: "hammer", location: 0, id: 26, events: []),
    EateryInfo(name: "Keeton House", icon: "pawprint.fill", location: 0, id: 29, events: []),
    EateryInfo(name: "Rose House", icon: "lightbulb", location: 0, id: 30, events: []),
    EateryInfo(name: "Okenshields", icon: "crown", location: 1, id: 20, events: [])
]
