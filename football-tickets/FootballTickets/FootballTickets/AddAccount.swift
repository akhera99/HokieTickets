//
//  AddAccount.swift
//  FootballTickets
//
//  Created by Sameer Dandekar on 3/31/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//

import SwiftUI

struct AddAccount: View {
    
    
    // Subscribe to changes in UserData
    @EnvironmentObject var userData: UserData
    
    // Enable this View to be dismissed to go back when the Save button is tapped
    @Environment(\.presentationMode) var presentationMode
    
    @State private var fullName = ""
    @State private var username = ""
    @State private var accountBalance = 0.0
    var body: some View {
           Form {
               Section(header: Text("Full Name")) {
                   TextField("Enter Student's Full Name", text: $fullName)
               }
               Section(header: Text("Username")) {
                   TextField("Enter Student's Username", text: $username)
               }
    
           }   // End of Form
           .disableAutocorrection(true)
           .autocapitalization(.words)
           .navigationBarTitle(Text("Create Student"), displayMode: .inline)
           .navigationBarItems(trailing:
               Button(action: {
                    // Append the country found to userData.countriesList
                self.userData.accountsList.append(Account(id: UUID(), fullname: self.fullName, username: self.username, accountBalance: "0.00", tickets: "None"))

                    // Set the global variable point to the changed list
                    accountStructList = self.userData.accountsList
                 
//                    self.showAddedMessage = true
                  
                   // Dismiss this View and go back
                    self.presentationMode.wrappedValue.dismiss()
               }) {
                   Text("Save")
               })
    }
    
     var alert: Alert {
         Alert(title: Text("Account Created!"),
               message: Text("This account has been added to the database."),
               dismissButton: .default(Text("BRUH")) ) // Change to "OK"
     }
}

struct AddAccount_Previews: PreviewProvider {
    static var previews: some View {
        AddAccount()
    }
}
