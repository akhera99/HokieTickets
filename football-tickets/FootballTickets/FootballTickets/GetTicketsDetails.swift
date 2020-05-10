//
//  GetTicketsDetails.swift
//  FootballTickets
//
//  Created by Sameer Dandekar on 4/14/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//

import SwiftUI

struct GetTicketsDetails: View {

    // Subscribe to changes in UserData
    @EnvironmentObject var userData: UserData

        @State private var ticketBought = false
        // Alert: Part 1 of 4
        @State private var showSavedMessage = false
        // Alert: Part 2 of 4
    //    self.showSavedMessage = true
        // Alert: Part 4 of 4
        var savedMessage: Alert {
            Alert(title: Text("Ticket Purchased"),
                  message: Text("Success! This ticket has been added to your account.\n" + String(ticket.price / 100) + " HTK has been deducted from yor account.")
                                            .foregroundColor(Color(red: 134.0/255.0, green: 31.0/255.0, blue: 65.0/255.0, opacity: 1.0)),
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
//                          .frame(width: 80.0, height: 80.0)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 80.0)
                      // Set font and size for the whole VStack content
                      .font(.system(size: 14))
                    
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
                    
//                    if !buySuccess {
                            Button(action: {
                                self.ticketBought = true
                                self.showSavedMessage = true // test
                                postRequestData6(user: "nathanmk", action: "buy", gameID: self.ticket.gameID)
                                postRequestData3(user: "nathanmk", action: "get_tickets")
//                                postRequestData3(user: "nathanmk", action: "get_tickets")
                                //        postRequestData(user: "nathanmk", action: "get_tickets")
//                                self.userData.myTickets.append(self.ticket)
                                

                            }) {

                                BuyButtonContent()

                            }
                                .alert(isPresented: $showSavedMessage, content: { self.savedMessage })
                            .frame(width: UIScreen.main.bounds.width - 40)


                    

                        NavigationLink(destination:
                            Auction(ticket: ticket) // FIX
                                )
                            {
                        Button(action: {

                            test = "bruh" // test

                        }) {

                            AuctionButtonContent()

                        }
                        .frame(width: UIScreen.main.bounds.width - 40)
                        }
//                    }
                    
/*                    if buySuccess {
                        Button(action: {
                            self.showSellMessage = true
                            self.ticketBought = false
                        }) {

                            SellButtonContent()

                        }
                            .alert(isPresented: $showSellMessage, content: { self.sellMessage })
                        .frame(width: UIScreen.main.bounds.width - 40)
                        
                        Button(action: {
                            self.showSellMessage = true
                            self.ticketBought = false
                        }) {

                            PutAuctionButtonContent()

                        }
                            .alert(isPresented: $showSellMessage, content: { self.sellMessage })
                        .frame(width: UIScreen.main.bounds.width - 40)

                        
                    } */
                  }
       
              }   // End of Form
//                .alert(isPresented: $showSavedMessage, content: { self.savedMessage })
              .navigationBarTitle(Text("Game Details"), displayMode: .inline)
              .font(.system(size: 14))
          }
}

func convertFullDate(ticketDate: String) -> String {
    
    // Take the first 16 characters of stringDate
     let firstPart = ticketDate.prefix(16)
    
     // Convert firstPart substring to String
     let cleanedStringDate = String(firstPart)
     
     // Create an instance of DateFormatter
     let dateFormatter = DateFormatter()
    
     // Set date format and locale
     dateFormatter.dateFormat = "yyyyMMddHHmm"
     dateFormatter.locale = Locale(identifier: "en_US")
     
     // Convert date String to Date struct
     let dateStruct = dateFormatter.date(from: cleanedStringDate)
     
     // Create a new instance of DateFormatter
     let newDateFormatter = DateFormatter()
     
     newDateFormatter.locale = Locale(identifier: "en_US")
     newDateFormatter.dateStyle = .medium    // Jan 18, 2020
     newDateFormatter.timeStyle = .medium    // at 12:26 PM
     
     // Obtain newly formatted Date String as "Jan 18, 2020 at 12:26 PM"
     let dateWithNewFormat = newDateFormatter.string(from: dateStruct!)
    
    return dateWithNewFormat
}


struct BuyButtonContent : View {
    var body: some View {
        return Text("Buy Ticket")
            .font(.headline)
            //change
            .foregroundColor(.white)
            .padding()
            .frame(width: 250, height: 60)
            .background(/*@START_MENU_TOKEN@*/Color.green/*@END_MENU_TOKEN@*/)
            .cornerRadius(15.0)

    }
}

struct AuctionButtonContent : View {
    var body: some View {
        return Text("Enter Auction")
            .font(.headline)
            //change
            .foregroundColor(.white)
            .padding()
            .frame(width: 250, height: 60)
            .background(Color.orange)
            .cornerRadius(15.0)

    }
}

struct SellButtonContent : View {
    var body: some View {
        return Text("Sell Ticket")
            .font(.headline)
            //change
            .foregroundColor(.white)
            .padding()
            .frame(width: 250, height: 60)
            .background(Color.red)
            .cornerRadius(15.0)

    }
}

struct PutAuctionButtonContent : View {
    var body: some View {
        return Text("Auction Ticket")
            .font(.headline)
            //change
            .foregroundColor(.white)
            .padding()
            .frame(width: 250, height: 60)
            .background(Color.blue)
            .cornerRadius(15.0)

    }
}


struct GetTicketsDetails_Previews: PreviewProvider {
    static var previews: some View {
        GetTicketsDetails(ticket: ticketStructList[0])
    }
}
