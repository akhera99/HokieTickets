//
//  MyFavoritesList.swift
//  Countries
//
//  Created by Sameer Dandekar on 2/11/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import SwiftUI
 
struct Auction: View {
    // Alert: Part 1 of 4
    @State private var showSavedMessage = false
    // Alert: Part 2 of 4
//    self.showSavedMessage = true
    // Alert: Part 4 of 4
    var savedMessage: Alert {
        Alert(title: Text("Bid Submitted"),
              message: Text("Success! Your bid has been submitted."),
              dismissButton: .default(Text("OK")) )
    }
    
    // Alert: Part 1 of 4
    @State private var showErrorMessage = false
    // Alert: Part 2 of 4
//    self.showErrorMessage = true
    // Alert: Part 4 of 4
    var errorMessage: Alert {
        Alert(title: Text("Bid Not Submitted!"),
              message: Text("You were unable to bid on this ticket."),
              dismissButton: .default(Text("OK")) )
    }

   // Input Parameter
   let ticket: Ticket
    
    // Subscribe to changes in UserData
    @EnvironmentObject var userData: UserData
    
    // Picker: Part 1 of 3

//    let choicesForAnswer = ["60 HTK", "65 HTK", "70 HTK", "75 HTK", "80 HTK", "85 HTK", "90 HTK", "95 HTK", "100 HTK", "105 HTK"]
    let choicesForAnswer = [60, 65, 70, 75, 80, 85, 90, 95, 100, 105]
   
    @State var highestBid = 60

    // Picker: Part 2 of 3

    @State private var selectedIndex = 3
    
    var body: some View {
           Form {
               Group {
                Section {
                        
                    Text(ticket.name)
                            .frame(width: UIScreen.main.bounds.width - 40)
                            .font(.title)
                            .foregroundColor(Color(red: 134.0/255.0, green: 31.0/255.0, blue: 65.0/255.0, opacity: 1.0))
                            .multilineTextAlignment(.center)
                    

                        Image(ticket.opponent + "_logo")
                            .frame(width: UIScreen.main.bounds.width - 40)
                   }
                
                Section {
                        HStack {
                            Text(verbatim: "Current Highest Bid:")
                                .font(.headline)
                            
                            Text(String(self.highestBid) + ".00 HTK")
                                .font(.title)
                                .foregroundColor(Color(red: 232.0/255.0, green: 119.0/255.0, blue: 34.0/255.0, opacity: 1.0))
                        }
                        .frame(width: UIScreen.main.bounds.width - 40)
                        
                }
               

           // Picker: Part 3 of 3
                Text(verbatim: "Your Bid:")
                .font(.headline)
                .frame(width: UIScreen.main.bounds.width - 40)

           Picker("Bid: ", selection: $selectedIndex) {

               ForEach(0 ..< choicesForAnswer.count, id: \.self) {

                   Text(String(self.choicesForAnswer[$0]) + " HTK")

               }

           }
            .labelsHidden()
            .frame(width: UIScreen.main.bounds.width - 40)

           .pickerStyle(WheelPickerStyle())
                
            Button(action: {
                test = "bruh" // test
                self.highestBid = self.choicesForAnswer[self.selectedIndex]
                self.showSavedMessage = true // test

            }) {

                SubmitButtonContent()

            }
                .alert(isPresented: $showSavedMessage, content: { self.savedMessage })
                .frame(width: UIScreen.main.bounds.width - 40)

//               }
                   
               }
    
           }   // End of Form
           .navigationBarTitle(Text("My Account"), displayMode: .inline)
           .font(.system(size: 14))
        
    }
   
}

struct SubmitButtonContent : View {
    var body: some View {
        return Text("Submit Bid")
            .font(.headline)
            //change
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color(red: 134.0/255.0, green: 31.0/255.0, blue: 65.0/255.0, opacity: 1.0))
            .cornerRadius(15.0)
    }
}
 
struct Auction_Previews: PreviewProvider {
    static var previews: some View {
        Auction(ticket: ticketStructList[0])
            .environmentObject(UserData())
    }
}
 
 
