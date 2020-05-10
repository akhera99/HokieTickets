//
//  ContentView.swift
//  FootballTickets
//
//  Created by Sameer Dandekar on 3/19/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
 
    var body: some View {
        TabView(selection: $selection){
            MyFavoritesList()
                .tabItem {
                    VStack {
                        Image(systemName: "person.3")
                        Text("Accounts")
                    }
                }
                .tag(0)
            
            TicketsList()
            .tabItem {
                VStack {
                    Image(systemName: "film")
                    .foregroundColor(.blue)
                    Text("Tickets")
                }
            }
            .tag(1)

            ScanQRBarcode()
            .tabItem {
                VStack {
                    Image(systemName: "qrcode.viewfinder")
                    .foregroundColor(.blue)
                    Text("Scan")
                }
            }
            .tag(2)
            
            GetTicketsList()
            .tabItem {
                VStack {
                    Image(systemName: "film")
                    .foregroundColor(.blue)
                    Text("Get Tickets")
                }
            }
            .tag(3)
            
            MyAccountList()
            .tabItem {
                VStack {
                    Image(systemName: "person")
                    .foregroundColor(.blue)
                    Text("My Account")
                }
            }
            .tag(4)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
