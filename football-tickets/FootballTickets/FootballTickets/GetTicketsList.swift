//
//  MyFavoritesList.swift
//  Countries
//
//  Created by Sameer Dandekar on 2/11/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import SwiftUI
 
struct GetTicketsList: View {
   
    // Subscribe to changes in UserData
    @EnvironmentObject var userData: UserData
    
    @State private var searchItem = ""
   
    var body: some View {
        NavigationView {
            List {
                SearchBar(searchItem: $searchItem)
                // Each Country struct has its own unique 'id' used by ForEach
                ForEach(available_tickets.filter {self.searchItem.isEmpty ? true : $0.name.localizedStandardContains(self.searchItem)}, id: \.self) {
                    aTicket in
                        NavigationLink(destination: GetTicketsDetails(ticket: aTicket)) {
                            GetTicketsItem(ticket: aTicket)
                        }
                    
                }
               
            }   // End of List
            .navigationBarTitle(Text("Tickets"), displayMode: .inline)
           
            // Place the Edit button on left of the navigation bar
            .navigationBarItems(leading: EditButton())
           
        }   // End of NavigationView
        
    }
   
}
 
 
struct GetTicketsList_Previews: PreviewProvider {
    static var previews: some View {
        GetTicketsList()
            .environmentObject(UserData())
    }
}
 
 
