//
//  UserData.swift
//  FootballTickets
//
//  Created by Sameer Dandekar on 1/23/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import Combine
import SwiftUI
 
final class UserData: ObservableObject {
    
    // Publish accountsList with initial value of accountStructList obtained in AccountData.swift
    @Published var accountsList = accountStructList
    
    @Published var ticketsList = ticketStructList
    
    @Published var userBalance = user_balance
    
    @Published var myTickets = my_tickets
     
}
 
