//
//  Ticket.swift
//  FootballTickets
//
//  Created by Sameer Dandekar on 3/31/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//

import SwiftUI

struct Ticket: Hashable, Codable, Identifiable {
   
    var id: UUID        // Storage Type: String, Use Type (format): UUID
    var owner: String
    var gameID: String
    var ticketID: String
    var gameNumber: Int
    var location: String
    var name: String
    var price: Int
    var reward: Int
    var opponent: String
    var date: String
}
