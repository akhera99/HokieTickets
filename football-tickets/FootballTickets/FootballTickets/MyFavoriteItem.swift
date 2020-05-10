//
//  MyFavoriteItem.swift
//  Countries
//
//  Created by Sameer Dandekar on 1/23/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import SwiftUI
 
struct MyFavoriteItem: View {
    // Input Parameter
    let account: Account
   
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(verbatim: account.fullname)
                    .font(.headline)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                HStack {
                    Text("Account Balance: ")
                    Text(verbatim: account.accountBalance + " HTK")
                }
            }
            // Set font and size for the whole VStack content
            .font(.system(size: 14))
           
        }   // End of HStack
    }
   
}
 
 
struct MyFavoriteItem_Previews: PreviewProvider {
    static var previews: some View {
        MyFavoriteItem(account: accountStructList[0])
    }
}
 
 
