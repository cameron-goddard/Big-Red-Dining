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
    let shortName: String
    let icon: String
    let location: Int
    let isCafe: Bool
    var obj: Eatery? {
        didSet {
            if isCafe {
                var menu : [MenuCategory] = []
                for item in obj!.diningItems {
                    if let index = menu.firstIndex(where: { $0.category == item.category }) {
                        menu[index].items.append(MenuItem(item: item.item))
                    } else {
                        let category = MenuCategory(category: item.category, items: [MenuItem(item: item.item)])
                        menu.append(category)
                    }
                }
                events.append(Event(descr: "", start: "", end: "", startTimestamp: 0, endTimestamp: 0, menu: menu))
            } else {
                // Get the current day's events - Will always be the second operating hour
                #if TESTING
                self.events = (obj?.operatingHours[4].events)!
                #else
                self.events = (obj?.operatingHours[1].events)!
                #endif
            }
        }
    }
    var events: [Event]
    
    init(name: String, shortName: String = "", icon: String, location: Int, isCafe: Bool = false, obj: Eatery? = nil) {
        self.name = name
        self.shortName = shortName
        self.icon = icon
        self.location = location
        self.isCafe = isCafe
        self.obj = obj
        self.events = []
    }
}

var allEateries : OrderedDictionary = [
    // North
    43: EateryInfo(name: "Morrison", icon: "text.book.closed", location: 2),
    3: EateryInfo(name: "North Star", icon: "moon.stars.fill", location: 2),
    4: EateryInfo(name: "Risley", icon: "theatermasks", location: 2),
    
    1: EateryInfo(name: "Nasties", icon: "cup.and.saucer.fill", location: 2, isCafe: true),
    44: EateryInfo(name: "Novick's", icon: "cup.and.saucer.fill", location: 2, isCafe: true),
    
    // West
    31: EateryInfo(name: "104West!", icon: "fork.knife", location: 0),
    25: EateryInfo(name: "Becker", icon: "books.vertical", location: 0),
    27: EateryInfo(name: "Bethe", icon: "atom", location: 0),
    26: EateryInfo(name: "Cook", icon: "hammer", location: 0),
    29: EateryInfo(name: "Keeton", icon: "pawprint.fill", location: 0),
    30: EateryInfo(name: "Rose", icon: "lightbulb", location: 0),
    
    28: EateryInfo(name: "Jansen's", icon: "cup.and.saucer.fill", location: 0, isCafe: true),
    
    // Central
    20: EateryInfo(name: "Okenshields", icon: "crown", location: 1),
    
    7: EateryInfo(name: "Libe", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    8: EateryInfo(name: "Atrium", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    10: EateryInfo(name: "Big Red Barn", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    11: EateryInfo(name: "Bus Stop Bagels", shortName: "Bagels", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    12: EateryInfo(name: "Café Jennie", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    13: EateryInfo(name: "Straight from the Market", shortName: "Market", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    14: EateryInfo(name: "Dairy Bar", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    32: EateryInfo(name: "Franny's", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    16: EateryInfo(name: "Goldie's", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    15: EateryInfo(name: "Green Dragon", shortName: "Dragon", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    42: EateryInfo(name: "Mann", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    18: EateryInfo(name: "Martha's", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    19: EateryInfo(name: "Mattin's", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    21: EateryInfo(name: "Rusty's", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    23: EateryInfo(name: "Trillium", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
    45: EateryInfo(name: "Vet School", icon: "cup.and.saucer.fill", location: 1, isCafe: true),
]
