//
//  TicketData.swift
//  FootballTickets
//
//  Created by Sameer Dandekar on 1/23/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import Foundation
import SwiftUI
 
// Global array of Ticket structs
var ticketStructList = [Ticket]()
/*
 Difference between fileprivate and private:
 fileprivate --> makes this constant accessible anywhere only inside this source file.
 private     --> makes it accessible only inside the type (e.g., class, struct) that declared it.
 */
fileprivate let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
 
/*
 ******************************
 MARK: - Read Country Data File
 ******************************
 */
public func readTicketDataFile() {
   
    let ticketDataFilename = "TicketData.json"
   
    // Obtain URL of the country data file in document directory on user's device
    let urlOfJsonFileInDocumentDirectory = documentDirectory.appendingPathComponent(ticketDataFilename)
 
    do {
        _ = try Data(contentsOf: urlOfJsonFileInDocumentDirectory)
       
        // Country data file exists in the document directory
 
        ticketStructList = loadFromDocumentDirectory(ticketDataFilename)
        
        print("TicketData is loaded from document directory")
       
    } catch {
        // Country data file does not exist in the document directory; Load it from the main bundle.
       
        ticketStructList = loadFromMainBundle(ticketDataFilename)
        
        print("TicketData is loaded from main bundle")
    }
}
 
/*
 *****************************************************
 MARK: - Write Country Data File to Document Directory
 *****************************************************
 */
public func writeTicketDataFile() {
 
    // Obtain the URL of the JSON file in the document directory on the user's device
    let urlOfJsonFileInDocumentDirectory: URL? = documentDirectory.appendingPathComponent("TicketData.json")
 
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(ticketStructList) {
        do {
            try encoded.write(to: urlOfJsonFileInDocumentDirectory!)
        } catch {
            fatalError("Unable to write encoded country data to document directory!")
        }
    } else {
        fatalError("Unable to encode country data!")
    }
}
