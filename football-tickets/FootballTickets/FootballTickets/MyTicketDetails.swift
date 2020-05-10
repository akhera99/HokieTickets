//
//  MyTicketsDetails.swift
//  FootballTickets
//
//  Created by Sameer Dandekar on 4/14/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//

import SwiftUI

struct MyTicketDetails: View {
        @State private var ticketBought = false
        // Alert: Part 1 of 4
        @State private var showSavedMessage = false
        // Alert: Part 2 of 4
    //    self.showSavedMessage = true
        // Alert: Part 4 of 4
        var savedMessage: Alert {
            Alert(title: Text("Ticket Purchased"),
                  message: Text("Success! This ticket has been added to your account."),
                  dismissButton: .default(Text("OK")) )
        }
        
        // Alert: Part 1 of 4
        @State private var showErrorMessage = false
        // Alert: Part 2 of 4
    //    self.showErrorMessage = true
        // Alert: Part 4 of 4
        var errorMessage: Alert {
            Alert(title: Text("Ticket Not Purchased!"),
                  message: Text("You were unable to purchase this ticket."),
                  dismissButton: .default(Text("OK")) )
        }
    
        // Alert: Part 1 of 4
        @State private var showSellMessage = false
        // Alert: Part 2 of 4
    //    self.showErrorMessage = true
        // Alert: Part 4 of 4
        var sellMessage: Alert {
            Alert(title: Text("Ticket Sold!"),
                  message: Text("Your ticket has been sold back to Virginia Tech."),
                  dismissButton: .default(Text("OK")) )
        }
    
        // Alert: Part 1 of 4
        @State private var showAuctionMessage = false
        // Alert: Part 2 of 4
    //    self.showErrorMessage = true
        // Alert: Part 4 of 4
        var auctionMessage: Alert {
            Alert(title: Text("Ticket Auctioned!"),
                  message: Text("Your ticket has been put into an auction."),
                  dismissButton: .default(Text("OK")) )
        }
    
    
    
    // Input Parameter
    let ticket: Ticket
          var body: some View {
              // A Form cannot have more than 10 Sections.
              // Group the Sections if more than 10.
              Form {
                  Group {
                      VStack(alignment: .center) {
                          Text(verbatim: ticket.name)
                            .frame(width: UIScreen.main.bounds.width - 40)
                              .font(.headline)
                              .padding(.top, 10)
                              .padding(.bottom, 20)
                          HStack {
                              Text("Location: ")
                              Text(verbatim: ticket.location)
                          }
                          HStack {
                              Text("Date: ")
                            Text(verbatim: convertFullDate(ticketDate: ticket.date))
                          }
                          

                      }
                          
                      Image(ticket.opponent + "_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 80.0)
                        // Set font and size for the whole VStack content
                        .font(.system(size: 14))
                    
                    if (!ticket.date.hasPrefix("202005")) {
                        Image("qr")
                            .frame(width: UIScreen.main.bounds.width - 40)
                            
                    }
                    
                    Section(header: Text("Price")
                        .font(.headline)
                        .frame(width: UIScreen.main.bounds.width)) {
                            Text(verbatim: String(ticket.price / 100) + ".00 HTK")
                                .frame(width: UIScreen.main.bounds.width - 40)
                                .font(.title)
                                .foregroundColor(Color(red: 134.0/255.0, green: 31.0/255.0, blue: 65.0/255.0, opacity: 1.0))
                                .multilineTextAlignment(.center)
                       }
                    
                    Section(header: Text("Reward")
                        .font(.headline)
                        .frame(width: UIScreen.main.bounds.width)) {
                            Text(verbatim: "6.00 HTK")
                                .frame(width: UIScreen.main.bounds.width - 40)
                                .font(.title)
                                .foregroundColor(Color(red: 134.0/255.0, green: 31.0/255.0, blue: 65.0/255.0, opacity: 1.0))
                    }
                    
                    Button(action: {
                             self.showSellMessage = true
                    
                        self.ticketBought = false
                        postRequestData5(user: self.ticket.owner, action: "sell", ticketID: self.ticket.ticketID)
                        postRequestData3(user: "nathanmk", action: "get_tickets")
                        postRequestData(user: "nathanmk", action: "user_balance")

//                        if (sellSuccess) {
//                            postRequestData3(user: "nathanmk", action: "get_tickets")
//                            postRequestData(user: "nathanmk", action: "user_balance")
//                          }
                        
                    }) {

                        SellButtonContent()

                    }
                        .alert(isPresented: $showSellMessage, content: { self.sellMessage })
                    .frame(width: UIScreen.main.bounds.width - 40)
                    
                    Button(action: {
                        self.showAuctionMessage = true
                        self.ticketBought = false
                    }) {

                        PutAuctionButtonContent()

                    }
                        .alert(isPresented: $showAuctionMessage, content: { self.auctionMessage })
                    .frame(width: UIScreen.main.bounds.width - 40)
                                            
                    
                  }
       
              }   // End of Form
//                .alert(isPresented: $showSavedMessage, content: { self.savedMessage })
              .navigationBarTitle(Text("Game Details"), displayMode: .inline)
              .font(.system(size: 14))
          }
}

struct MyTicketsDetails_Previews: PreviewProvider {
    static var previews: some View {
        MyTicketDetails(ticket: ticketStructList[0])
    }
}
