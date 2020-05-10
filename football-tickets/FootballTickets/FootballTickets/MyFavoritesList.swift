//
//  MyFavoritesList.swift
//  Countries
//
//  Created by Sameer Dandekar on 2/11/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import SwiftUI
 
struct MyFavoritesList: View {
   
    // Subscribe to changes in UserData
    @EnvironmentObject var userData: UserData
    
    @State private var searchItem = ""
   
    var body: some View {
        NavigationView {
            List {
                SearchBar(searchItem: $searchItem)
                // Each Country struct has its own unique 'id' used by ForEach
                ForEach(userData.accountsList.filter {self.searchItem.isEmpty ? true : $0.fullname.localizedStandardContains(self.searchItem)}, id: \.self) {
                    anAccount in
                    NavigationLink(destination: MyFavoriteDetails(account: anAccount)) {
                        MyFavoriteItem(account: anAccount)
                    }
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
               
            }   // End of List
            .navigationBarTitle(Text("Student Accounts"), displayMode: .inline)
           
            // Place the Edit button on left of the navigation bar
            .navigationBarItems(leading: EditButton(), trailing:
            NavigationLink(destination: AddAccount()) {
                Image(systemName: "plus")
            })
           
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
 
 
struct MyFavoritesList_Previews: PreviewProvider {
    static var previews: some View {
        MyFavoritesList()
            .environmentObject(UserData())
    }
}
 
 
