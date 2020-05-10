//
//  MyFavoritesList.swift
//  Countries
//
//  Created by Sameer Dandekar on 2/11/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import SwiftUI
 
struct TicketsList: View {
   
    // Subscribe to changes in UserData
    @EnvironmentObject var userData: UserData
    
    @State private var searchItem = ""
   
    var body: some View {
        NavigationView {
            List {
                SearchBar(searchItem: $searchItem)
                // Each Country struct has its own unique 'id' used by ForEach
                ForEach(userData.ticketsList.filter {self.searchItem.isEmpty ? true : $0.name.localizedStandardContains(self.searchItem)}, id: \.self) {
                    aTicket in
                        TicketsItem(ticket: aTicket)
                    
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
               
            }   // End of List
            .navigationBarTitle(Text("Tickets"), displayMode: .inline)
           
            // Place the Edit button on left of the navigation bar
            .navigationBarItems(leading: EditButton())
           
        }   // End of NavigationView
        
    }
   
    /*
     -------------------------------
     MARK: - Delete Selected Country
     -------------------------------
     */
    /*
     IndexSet:  A collection of unique integer values that represent the indexes of elements in another collection.
     first:     The first integer in self, or nil if self is empty.
     */
    func delete(at offsets: IndexSet) {
        if let first = offsets.first {
            userData.accountsList.remove(at: first)
        }
        // Set the global variable point to the changed list
        accountStructList = userData.accountsList
    }
   
    /*
     -----------------------------
     MARK: - Move Selected Country
     -----------------------------
     */
    func move(from source: IndexSet, to destination: Int) {
 
        userData.accountsList.move(fromOffsets: source, toOffset: destination)
       
        // Set the global variable point to the changed list
        accountStructList = userData.accountsList
    }
}
 
 
struct TicketsList_Previews: PreviewProvider {
    static var previews: some View {
        TicketsList()
            .environmentObject(UserData())
    }
}
 
 
