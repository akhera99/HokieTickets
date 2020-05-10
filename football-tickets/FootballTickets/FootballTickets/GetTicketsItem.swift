//
//  MyFavoriteItem.swift
//  Countries
//
//  Created by Sameer Dandekar on 1/23/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import SwiftUI

var test2 = ""

struct GetTicketsItem: View {
    // Input Parameter
    let ticket: Ticket
    
    
   
    var body: some View {
            HStack(alignment: .center) {
                VStack {
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
                        
                        
                        Text(verbatim: convertDate(ticketDate: ticket.date))
                    }
                    
                }
                    
                Image(ticket.opponent + "_logo")
                                .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80.0, height: 80.0)
                // Set font and size for the whole VStack content
                .font(.system(size: 14))
               

                
            }   // End of HStack
    }
   
}

func convertDate(ticketDate: String) -> String {
    
    // Create an instance of DateFormatter
    let dateFormatter = DateFormatter()
     
    // Set the date format to yyyy-MM-dd
    dateFormatter.dateFormat = "yyyyMMddHHmm"
    dateFormatter.locale = Locale(identifier: "en_US")
     
    // Convert date String from "yyyy-MM-dd" to Date struct
    let dateStruct = dateFormatter.date(from: ticketDate)
     
    // Create a new instance of DateFormatter
    let newDateFormatter = DateFormatter()
     
    newDateFormatter.locale = Locale(identifier: "en_US")
    newDateFormatter.dateStyle = .full      // Thursday, November 7, 2019
    newDateFormatter.timeStyle = .none
     
    // Obtain newly formatted Date String as "Thursday, November 7, 2019"
    let dateWithNewFormat = newDateFormatter.string(from: dateStruct!)
    
    return dateWithNewFormat
}

struct GetTicketsItem_Previews: PreviewProvider {
    static var previews: some View {
        GetTicketsItem(ticket: ticketStructList[0])
    }
}
 
 
