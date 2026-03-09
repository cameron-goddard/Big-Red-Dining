//
//  EateryInfo.swift
//  Big Red Dining
//
//  Created by Cameron Goddard on 12/20/22.
//

import Foundation
import OrderedCollections

enum Location: Int {
    case west = 0
    case central = 1
    case north = 2
}

/// A construct combining hardcoded eatery metadata with live API data.
struct EateryInfo {

    let name: String
    let shortName: String
    let icon: String
    let location: Location
    let isCafe: Bool

    private(set) var obj: Eatery?
    private(set) var events: [Event] = []

    /// Initializes an ``EateryInfo`` struct.
    /// - Parameters:
    ///   - name: The name of this eatery
    ///   - shortName: A concise name for this eatery
    ///   - icon: The icon to display in the eatery list
    ///   - location: Where on campus this eatery is
    ///   - isCafe: Whether this eatery is a cafe
    init(name: String, shortName: String = "", icon: String, location: Location, isCafe: Bool = false) {
        self.name = name
        self.shortName = shortName
        self.icon = icon
        self.location = location
        self.isCafe = isCafe
    }

    /// Update the object with live eatery data.
    /// - Parameter eatery: The ``Eatery`` object from which to extract information
    mutating func update(with eatery: Eatery) {
        self.obj = eatery
        
        #if TESTING
        let dayIndex = 4
        #else
        let dayIndex = 1
        #endif
        
        guard dayIndex < eatery.operatingHours.count else {
            self.events = []
            return
        }
        
        let dayEvents = eatery.operatingHours[dayIndex].events
        
        if isCafe {
            var menu: [MenuCategory] = []
            for item in eatery.diningItems {
                if let index = menu.firstIndex(where: { $0.category == item.category }) {
                    menu[index].items.append(MenuItem(item: item.item))
                } else {
                    menu.append(MenuCategory(category: item.category, items: [MenuItem(item: item.item)]))
                }
            }
            self.events = dayEvents.map { ev in
                Event(descr: ev.descr, start: ev.start, end: ev.end, startTimestamp: ev.startTimestamp, endTimestamp: ev.endTimestamp, menu: menu)
            }
        } else {
            self.events = dayEvents
        }
    }
}

@MainActor
var noEateryInfo = false

@MainActor
var allEateries : OrderedDictionary = [
    // North
    43: EateryInfo(name: "Morrison", icon: "text.book.closed", location: .north),
    3: EateryInfo(name: "North Star", icon: "moon.stars.fill", location: .north),
    4: EateryInfo(name: "Risley", icon: "theatermasks", location: .north),
    
    41: EateryInfo(name: "Crossings", icon: "cup.and.saucer.fill", location: .north, isCafe: true),
    1: EateryInfo(name: "Nasties", icon: "cup.and.saucer.fill", location: .north, isCafe: true),
    44: EateryInfo(name: "Novick's", icon: "cup.and.saucer.fill", location: .north, isCafe: true),
    
    // West
    31: EateryInfo(name: "104West!", icon: "fork.knife", location: .west),
    25: EateryInfo(name: "Becker", icon: "books.vertical", location: .west),
    27: EateryInfo(name: "Bethe", icon: "atom", location: .west),
    26: EateryInfo(name: "Cook", icon: "hammer", location: .west),
    29: EateryInfo(name: "Keeton", icon: "pawprint.fill", location: .west),
    30: EateryInfo(name: "Rose", icon: "lightbulb", location: .west),
    
    28: EateryInfo(name: "Jansen's", icon: "cup.and.saucer.fill", location: .west, isCafe: true),
    
    // Central
    20: EateryInfo(name: "Okenshields", icon: "crown", location: .central),
    
    7: EateryInfo(name: "Libe", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    8: EateryInfo(name: "Atrium", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    10: EateryInfo(name: "Big Red Barn", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    11: EateryInfo(name: "Bus Stop Bagels", shortName: "Bagels", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    12: EateryInfo(name: "Café Jennie", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    13: EateryInfo(name: "Straight from the Market", shortName: "Market", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    14: EateryInfo(name: "Dairy Bar", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    32: EateryInfo(name: "Franny's", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    16: EateryInfo(name: "Goldie's", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    15: EateryInfo(name: "Green Dragon", shortName: "Dragon", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    42: EateryInfo(name: "Mann", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    18: EateryInfo(name: "Martha's", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    19: EateryInfo(name: "Mattin's", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    21: EateryInfo(name: "Rusty's", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    23: EateryInfo(name: "Trillium", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
    45: EateryInfo(name: "Vet School", icon: "cup.and.saucer.fill", location: .central, isCafe: true),
]
