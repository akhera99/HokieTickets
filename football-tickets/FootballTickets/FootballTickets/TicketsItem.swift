//
//  MyFavoriteItem.swift
//  Countries
//
//  Created by Sameer Dandekar on 1/23/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import SwiftUI

var test = ""

struct TicketsItem: View {
    // Input Parameter
    let ticket: Ticket
    
    
   
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center) {
                Text(verbatim: ticket.name)
                    .font(.headline)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                HStack {
                    Text("Location: ")
                    Text(verbatim: ticket.location)
                }
                HStack {
                    Text("Date: ")
                    Text(verbatim: ticket.date)
                }
                
                Button(action: {

                    test = "bruh" // test

                }) {

                    OpenButtonContent()

                }
            }
                
            Image(ticket.opponent + "_logo")
                .imageScale(.small)
            // Set font and size for the whole VStack content
            .font(.system(size: 14))
           

            
        }   // End of HStack
    }
   
}
 
 struct OpenButtonContent : View {
     var body: some View {
         return Text("Open Lottery")
             .font(.headline)
             //change
             .foregroundColor(.white)
             .padding()
             .frame(width: 220, height: 60)
             .background(Color(red: 134.0/255.0, green: 31.0/255.0, blue: 65.0/255.0, opacity: 1.0))
             .cornerRadius(15.0)
     }
 }

struct ExecuteButtonContent : View {
    var body: some View {
        return Text("Execute Lottery")
            .font(.headline)
            //change
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color(red: 232.0/255.0, green: 119.0/255.0, blue: 34.0/255.0, opacity: 1.0))
            .cornerRadius(15.0)
    }
}

struct TicketsItem_Previews: PreviewProvider {
    static var previews: some View {
        TicketsItem(ticket: ticketStructList[0])
    }
}
 
 
