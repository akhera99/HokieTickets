//
//  MyFavoriteDetails.swift
//  Countries
//
//  Created by Sameer Dandekar on 1/23/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import SwiftUI
import MapKit
 
struct MyFavoriteDetails: View {
    // Input Parameter
    let account: Account
   
    var body: some View {
        // A Form cannot have more than 10 Sections.
        // Group the Sections if more than 10.
        Form {
            Group {
                Section(header: Text("Username")) {
                    Text(verbatim: account.username)
                }
                Section(header: Text("Account Balance")) {
                    Text(verbatim: account.accountBalance)
                }
                Section(header: Text("Tickets")) {
                    Text(verbatim: account.tickets)
                }
            }
 
        }   // End of Form
        .navigationBarTitle(Text("Account Details"), displayMode: .inline)
        .font(.system(size: 14))
    }
   
}
 
 
struct MyFavoriteDetails_Previews: PreviewProvider {
    static var previews: some View {
        MyFavoriteDetails(account: accountStructList[0])
    }
}
 
