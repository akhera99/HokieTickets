//
//  MyFavoritesList.swift
//  Countries
//
//  Created by Sameer Dandekar on 2/11/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import SwiftUI

struct MyAccountList: View {
   
    // Subscribe to changes in UserData
    @EnvironmentObject var userData: UserData
    
   var tickets_list: some View {
//       postRequestData3(user: "nathanmk", action: "get_tickets")
//       self.userData.myTickets = my_tickets
          return AnyView(
                                      List {
                  ForEach(my_tickets) { aTicket in
                              NavigationLink(destination: MyTicketDetails(ticket: aTicket)) {
                                  GetTicketsItem(ticket: aTicket)
                              }
                          }
                      
                  
                 
              }   // End of List
    )
   }
    
    
    var body: some View {
        NavigationView {

           Form {
               Group {
                Section(header: Text("Username")
                    .font(.headline)
                    .frame(width: UIScreen.main.bounds.width)) {
                        Text(verbatim: "nathanmk")
                            .frame(width: UIScreen.main.bounds.width - 40)
                            .font(.title)
                            .foregroundColor(Color(red: 134.0/255.0, green: 31.0/255.0, blue: 65.0/255.0, opacity: 1.0))
                            .multilineTextAlignment(.center)
                   }
                
                Section(header: Text("Account Balance")
                    .font(.headline)
                    .frame(width: UIScreen.main.bounds.width)) {
                        
                          Text(verbatim: self.userData.userBalance)
                            .frame(width: UIScreen.main.bounds.width - 40)
                            .font(.title)
                            .foregroundColor(Color(red: 134.0/255.0, green: 31.0/255.0, blue: 65.0/255.0, opacity: 1.0))
                }
                
                Section(header: Text("My Tickets")
                    .font(.headline)
                    .frame(width: UIScreen.main.bounds.width)) {
                        List {
                            ForEach(self.userData.myTickets) { aTicket in
                                        NavigationLink(destination: MyTicketDetails(ticket: aTicket)) {
                                            GetTicketsItem(ticket: aTicket)
                                        }
                                    }
                                
                            
                           
                        }   // End of List
                    }
                
               

//               Section(header: Text("Transaction History")) {
                   NavigationLink(destination:
                       MyFavoritesList() // FIX
                           )
                       {
                        
                           Image(systemName: "bag")
                           .imageScale(.medium)
                           .font(Font.title.weight(.regular))
                        Text("Transaction History")
                            .font(.headline)
                            .foregroundColor(Color.blue)
                   }
//               }
                   
               }
    
           }   // End of Form
           .navigationBarTitle(Text("My Account"), displayMode: .inline)
           .font(.system(size: 14))
            
            .navigationBarItems(trailing:
                               Button(action: {
                                postRequestData(user: "nathanmk", action: "user_balance")

                                    self.userData.userBalance = user_balance
                                    self.userData.myTickets = my_tickets

                                
                               }) {
                                   Text("Refresh")
                               }

            )
        }
    }
   
}
 
 
struct MyAccountList_Previews: PreviewProvider {
    static var previews: some View {
        MyAccountList()
            .environmentObject(UserData())
    }
}
 
 
