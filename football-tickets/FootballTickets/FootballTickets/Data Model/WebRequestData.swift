//
//  WebRequestData.swift
//  FootballTickets
//
//  Created by Sameer Dandekar on 1/24/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import Foundation
import SwiftUI

var user_balance = "0.00 HTK"
 
var available_tickets = [Ticket]()

var my_tickets = [Ticket]()

var myTicket = Ticket(id: UUID(), owner: "hokipoki", gameID: "0", ticketID: "0", gameNumber: 0, location: "The Pool", name: "VT. vs Test", price: 6000, reward: 500, opponent: "Test", date: "202004101200")

var sellSuccess = false
var buySuccess = false

var qrSuccess = false
var scannedUser = "hokipoki"

/*
====================================
MARK: - GET Request Data from API
====================================
*/
public func getRequestData() {
    
    // Create URL
    let url = URL(string: "http://goblins.info.tm/requests.pyhtml")
    guard let requestUrl = url else { fatalError() }
    // Create URL Request
    var request = URLRequest(url: requestUrl)
    // Specify HTTP Method to use
    request.httpMethod = "GET"
    // Send HTTP Request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        
        // Check if Error took place
        if let error = error {
            print("Error took place \(error)")
            return
        }
        
        // Read HTTP Response Status code
        if let response = response as? HTTPURLResponse {
            print("Response HTTP Status code: \(response.statusCode)")
        }
        
        // Convert HTTP Response Data to a simple String
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            print("Response data string:\n \(dataString)")
        }
        
        
        let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
        // print if response is JSON object
        if let responseJSON = responseJSON as? [String: Any] {
            if responseJSON["success"] != nil {
                qrSuccess = true
            }
        }
        
    }
    task.resume()
 
}

/*
====================================
MARK: - Login via POST Request from API
====================================
*/
/*public func attemptLogin(user: String, pass: String) {
    // prepare json data
    let json: [String: String] = ["user": "hokipoki", "pass": "pass"]
    let jsonData = try? JSONSerialization.data(withJSONObject: json)

    // create post request
    let url = URL(string: "https://goblins.info.tm/login.pyhtml")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    // insert json data into the body
    request.httpBody = "user=hokipoki&pass=pass".data(using: .utf8)

    
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard
            let data = data,
            let httpResponse = response as? HTTPURLResponse,
            let fields = httpResponse.allHeaderFields as? [String: String],
            error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
        }
        
        print(HTTPCookie.requestHeaderFields(with: cookies))
        
        cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
        
        print(HTTPCookie.requestHeaderFields(with: cookies))
//        print(String(data: data, encoding: .utf8)) // TESTING
        
        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        // print if response is JSON object
        if let responseJSON = responseJSON as? [String: Any] {
            print(responseJSON) // TESTING
        }
    }

    task.resume()
}
*/
//
public func getGameData(user: String, gameID: String) {
    

     // prepare json data
    let json: [String: Any] = ["user": user, "action": "get_game", "game_id": gameID]
    let jsonData = try? JSONSerialization.data(withJSONObject: json)

    // create post request
    let url = URL(string: "https://goblins.info.tm/requests.pyhtml")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // insert json data to the request
    request.httpBody = jsonData
    
    request.addValue("application/json", forHTTPHeaderField: "content-type")

//        print(HTTPCookie.requestHeaderFields(with: cookies))

    // get header fields from cookies via HTTPCookie.requestHeaderFields(with: cookies!)
    //    request.allHeaderFields(headers)

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard
            let data = data,
            let httpResponse = response as? HTTPURLResponse,
            let fields = httpResponse.allHeaderFields as? [String: String],
            error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
        }
        
        print(String(data: data, encoding: .utf8)) // TESTING
        
        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        print(responseJSON) // TESTING
        let gameJson = responseJSON as? [String: Any]
        
//        gameJsons.append(gameJson!)
    }

    task.resume()
    
}


/*
====================================
MARK: - POST Request Data from API
====================================
*/
public func postRequestData(user: String, action: String) {
    
    // prepare json data
    let json: [String: Any] = ["user": user, "action": action]
    let jsonData = try? JSONSerialization.data(withJSONObject: json)

    // create post request
    let url = URL(string: "https://goblins.info.tm/requests.pyhtml")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // insert json data to the request
    request.httpBody = jsonData
    
    request.addValue("application/json", forHTTPHeaderField: "content-type")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard
            let data = data,
            let httpResponse = response as? HTTPURLResponse,
            let fields = httpResponse.allHeaderFields as? [String: String],
            error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
        }
        
        print(String(data: data, encoding: .utf8)) // TESTING
        
        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        print(responseJSON) // TESTING
    
        if action == "available_tickets" {
            if let jsonArray = responseJSON as? [Any] {
                for (element) in jsonArray {
                    let game = (element) as? [String: Any]
                    
                    guard let gameID = game?["id"] as? Int else {return}
                    
                    guard let gameDate = game?["date"] as? String else {return}
                    
                    guard let gameNumber = game?["number"] as? Int else {return}
                    
                    guard let gameName = game?["name"] as? String else {return}
                    
                    guard let gameReward = game?["reward"] as? Int else {return}
                    
                    guard let gamePrice = game?["initial_face_value"] as? Int else {return}

                    guard let gameLocation = game?["location"] as? String else {return}
                    
                    var delimiter = " "
                    var token = gameName.components(separatedBy: delimiter)
                    print (token[2])

                    let gameTicket = Ticket(id: UUID(), owner: "hokipoki", gameID: String(gameID), ticketID: "0", gameNumber: gameNumber, location: gameLocation, name: gameName, price: gamePrice, reward: gameReward, opponent: token[2], date: gameDate)
                    
                    available_tickets.append(gameTicket)
                }
            }
        }
        
        else if action == "get_tickets" {
            if let jsonArray = responseJSON as? [Any] {
                for (element) in jsonArray {
                    let game = (element) as? [String: Any]
                    
                    guard let gameID = game?["game_id"] as? Int else {return}
                    
                    guard let ticketID = game?["id"] as? Int else {return}
                                                   
                                                            
                    guard let gameOwner = game?["owner"] as? String else {return}
                    
                    var gameName = ""
                    var gameDate = ""
                    var gameLocation = ""
                    var gamePrice = 0
                    var gameReward = 0
                    
                    
                    // prepare json data
                        let json: [String: Any] = ["user": user, "action": "get_game", "game_id": gameID]
                        let jsonData = try? JSONSerialization.data(withJSONObject: json)

                        // create post request
                        let url = URL(string: "https://goblins.info.tm/requests.pyhtml")!
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"

                        // insert json data to the request
                        request.httpBody = jsonData
                        
                        request.addValue("application/json", forHTTPHeaderField: "content-type")

                    
                    
                    getGameData(user: user, gameID: String(gameID))
                    

                    
                    var delimiter = " "
                    var token = gameName.components(separatedBy: delimiter)
                    print (token[2])

                    let gameTicket = Ticket(id: UUID(), owner: gameOwner, gameID: String(gameID), ticketID: String(ticketID), gameNumber: 0, location: gameLocation, name: gameName, price: gamePrice, reward: gameReward, opponent: token[2], date: gameDate)
                    
                    my_tickets.append(gameTicket)
                }
            }
        }
        
        
        else if action == "user_balance" {
            let jsonObject = responseJSON as? [String: Any]
            user_balance = jsonObject!["balance"] as! String

                
        }
        

//semaphore.signal()

    }

    task.resume()
    
//    _ = semaphore.wait(timeout: .now() + 10)
}
 
/*
====================================
MARK: - POST QR Data from API
====================================
*/
public func postQRData(user: String, barcode: String) {
    // prepare json data
    let json: [String: Any] = ["admin": "true", "user": "hokipoki", "action": "scan_code", "code": barcode]
    let jsonData = try? JSONSerialization.data(withJSONObject: json)

    // create post request
    let url = URL(string: "https://goblins.info.tm/requests.pyhtml")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // insert json data to the request
    request.httpBody = jsonData
    
    request.addValue("application/json", forHTTPHeaderField: "content-type")
    
    // get header fields from cookies via HTTPCookie.requestHeaderFields(with: cookies!)
    //    request.allHeaderFields(headers)

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard
            let data = data,
            let httpResponse = response as? HTTPURLResponse,
            let fields = httpResponse.allHeaderFields as? [String: String],
            error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
        }
        
        print(String(data: data, encoding: .utf8)) // TESTING
        
        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        // print if response is JSON object
        if let responseJSON = responseJSON as? [String: Any] {
            if responseJSON["success"] != nil {
                scannedUser = responseJSON["user"] as! String
                qrSuccess = true
            }
        }
    }

    task.resume()
}


/*
====================================
MARK: - POST Request Data from API
====================================
*/
public func postRequestData2(user: String, action: String) {
    

    // prepare json data
    let json: [String: Any] = ["user": user, "action": action]
    let jsonData = try? JSONSerialization.data(withJSONObject: json)

    // create post request
    let url = URL(string: "https://goblins.info.tm/requests.pyhtml")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // insert json data to the request
    request.httpBody = jsonData
    
    request.addValue("application/json", forHTTPHeaderField: "content-type")
 
    /*
    *********************************************************************
    *  Setting Up a URL Session to Fetch the JSON File from the API     *
    *  in an Asynchronous Manner and Processing the Received JSON File  *
    *********************************************************************
    */
   
    /*
     Create a semaphore to control getting and processing API data.
     signal() -> Int    Signals (increments) a semaphore.
     wait()             Waits for, or decrements, a semaphore.
     */
    let semaphore = DispatchSemaphore(value: 0)
 
    URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
        /*
        URLSession is established and the JSON file from the API is set to be fetched
        in an asynchronous manner. After the file is fetched, data, response, error
        are returned as the input parameter values of this Completion Handler Closure.
        */
 
        // Process input parameter 'error'
        guard error == nil else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
       
        /*
         ---------------------------------------------------------
         🔴 Any 'return' used within the completionHandler Closure
            exits the Closure; not the public function it is in.
         ---------------------------------------------------------
         */
 
        // Process input parameter 'response'. HTTP response status codes from 200 to 299 indicate success.
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
 
        // Process input parameter 'data'. Unwrap Optional 'data' if it has a value.
        guard let jsonDataFromApi = data else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
 
        //------------------------------------------------
        // JSON data is obtained from the API. Process it.
        //------------------------------------------------
        do {
                   /*
                    Foundation framework’s JSONSerialization class is used to convert JSON data
                    into Swift data types such as Dictionary, Array, String, Number, or Bool.
                    */
               let jsonResponse = try JSONSerialization.jsonObject(with: jsonDataFromApi,
                                      options: JSONSerialization.ReadingOptions.mutableContainers)
            guard let jsonArray = jsonResponse as? [Any] else { return }
            
            for (element) in jsonArray {
                if let jsonObject = (element) as? [String: Any] {
                    
                    let game = (element) as? [String: Any]
                    
                    guard let gameID = game?["id"] as? Int else {return}
                    
                    guard let gameDate = game?["date"] as? String else {return}
                    
                    guard let gameNumber = game?["number"] as? Int else {return}
                    
                    guard let gameName = game?["name"] as? String else {return}
                    
                    guard let gameReward = game?["reward"] as? Int else {return}
                    
                    guard let gamePrice = game?["initial_face_value"] as? Int else {return}

                    guard let gameLocation = game?["location"] as? String else {return}
                    
                    var delimiter = " "
                    var token = gameName.components(separatedBy: delimiter)
                    print (token[2])

                    let gameTicket = Ticket(id: UUID(), owner: "hokipoki", gameID: String(gameID), ticketID: "0", gameNumber: gameNumber, location: gameLocation, name: gameName, price: gamePrice, reward: gameReward, opponent: token[2], date: gameDate)
                    
                    available_tickets.append(gameTicket)
                    
                } else {
                    semaphore.signal()
                    return }
            }
            
            
                  
                      
        
               } catch {
            semaphore.signal()
            return
        }
 
        semaphore.signal()
    }).resume()
 
    /*
     The URLSession task above is set up. It begins in a suspended state.
     The resume() method starts processing the task in an execution thread.
 
     The semaphore.wait blocks the execution thread and starts waiting.
     Upon completion of the task, the Completion Handler code is executed.
     The waiting ends when .signal() fires or timeout period of 10 seconds expires.
    */
 
    _ = semaphore.wait(timeout: .now() + 2)
 
}

/*
====================================
MARK: - POST Request Data from API
====================================
*/
public func postRequestData3(user: String, action: String) {
    

    // prepare json data
    let json: [String: Any] = ["user": user, "action": action]
    let jsonData = try? JSONSerialization.data(withJSONObject: json)

    // create post request
    let url = URL(string: "https://goblins.info.tm/requests.pyhtml")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // insert json data to the request
    request.httpBody = jsonData
    
    request.addValue("application/json", forHTTPHeaderField: "content-type")
 
    /*
    *********************************************************************
    *  Setting Up a URL Session to Fetch the JSON File from the API     *
    *  in an Asynchronous Manner and Processing the Received JSON File  *
    *********************************************************************
    */
   
    /*
     Create a semaphore to control getting and processing API data.
     signal() -> Int    Signals (increments) a semaphore.
     wait()             Waits for, or decrements, a semaphore.
     */
    let semaphore = DispatchSemaphore(value: 0)
 
    URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
        /*
        URLSession is established and the JSON file from the API is set to be fetched
        in an asynchronous manner. After the file is fetched, data, response, error
        are returned as the input parameter values of this Completion Handler Closure.
        */
 
        // Process input parameter 'error'
        guard error == nil else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
       
        /*
         ---------------------------------------------------------
         🔴 Any 'return' used within the completionHandler Closure
            exits the Closure; not the public function it is in.
         ---------------------------------------------------------
         */
 
        // Process input parameter 'response'. HTTP response status codes from 200 to 299 indicate success.
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
 
        // Process input parameter 'data'. Unwrap Optional 'data' if it has a value.
        guard let jsonDataFromApi = data else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
 
        //------------------------------------------------
        // JSON data is obtained from the API. Process it.
        //------------------------------------------------
        do {
                   /*
                    Foundation framework’s JSONSerialization class is used to convert JSON data
                    into Swift data types such as Dictionary, Array, String, Number, or Bool.
                    */
               let jsonResponse = try JSONSerialization.jsonObject(with: jsonDataFromApi,
                                      options: JSONSerialization.ReadingOptions.mutableContainers)
            guard let jsonArray = jsonResponse as? [Any] else { return }
            my_tickets.removeAll()
            for (element) in jsonArray {
                if let jsonObject = (element) as? [String: Any] {
                    
                    let game = (element) as? [String: Any]
                    
                    guard let gameID = game?["game_id"] as? Int else {return}
                    
                    guard let ticketID = game?["id"] as? Int else {return}
                                                   
                                                            
                    guard let gameOwner = game?["owner"] as? String else {return}
                    
                    var gameName = ""
                    var gameDate = ""
                    var gameLocation = ""
                    var gamePrice = 0
                    var gameReward = 0
                
                    // Process input parameter 'data'. Unwrap Optional 'data' if it has a value.
                    guard postRequestData4(user: user, action: "get_game", gameID: String(gameID), ticketID: String(ticketID), gameOwner: gameOwner) != nil else {
                        // productFound will have the initial values set as above
                        semaphore.signal()
                        return
                    }
                    
                    
                    
                    /*if let gameData = postRequestData4(user: user, action: "get_game", gameID: String(gameID)) as? [String: Any]  {
                        
                        gameName = gameData["name"] as? String ?? ""
                        gameDate = gameData["date"] as? String ?? ""
                        gameLocation = gameData["location"] as? String ?? ""
                        gamePrice = gameData["initial_face_value"] as? Int ?? 0
                        gameReward = gameData["reward"] as? Int ?? 0
                        
                    }
                    else {
                    semaphore.signal()
                    return
                        
                    }
                    */

                    
/*                    var delimiter = " "
                    var token = myTicket.name.components(separatedBy: delimiter)
                    print (token[2])

                    let gameTicket = Ticket(id: UUID(), owner: gameOwner, gameID: String(gameID), ticketID: String(ticketID), gameNumber: 0, location: gameLocation, name: gameName, price: gamePrice, reward: gameReward, opponent: token[2], date: gameDate)
                    
                    myTicket.gameID = String(gameID)
                    myTicket.ticketID = String(ticketID)
                    myTicket.owner = gameOwner
                    my_tickets.append(myTicket)
*/
                } else {
                    semaphore.signal()
                    return }
            }
            
            
                  
                      
        
               } catch {
            semaphore.signal()
            return
        }
 
        semaphore.signal()
    }).resume()
 
    /*
     The URLSession task above is set up. It begins in a suspended state.
     The resume() method starts processing the task in an execution thread.
 
     The semaphore.wait blocks the execution thread and starts waiting.
     Upon completion of the task, the Completion Handler code is executed.
     The waiting ends when .signal() fires or timeout period of 10 seconds expires.
    */
 
    _ = semaphore.wait(timeout: .now() + 2)
 
}

/*
====================================
MARK: - POST Request Data from API
====================================
*/
public func postRequestData4(user: String, action: String, gameID: String, ticketID: String, gameOwner: String) {
    

    // prepare json data
    let json: [String: Any] = ["user": user, "action": action, "game_id": gameID]
    let jsonData = try? JSONSerialization.data(withJSONObject: json)

    // create post request
    let url = URL(string: "https://goblins.info.tm/requests.pyhtml")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // insert json data to the request
    request.httpBody = jsonData
    
    request.addValue("application/json", forHTTPHeaderField: "content-type")
 
    /*
    *********************************************************************
    *  Setting Up a URL Session to Fetch the JSON File from the API     *
    *  in an Asynchronous Manner and Processing the Received JSON File  *
    *********************************************************************
    */
   
    /*
     Create a semaphore to control getting and processing API data.
     signal() -> Int    Signals (increments) a semaphore.
     wait()             Waits for, or decrements, a semaphore.
     */
    let semaphore = DispatchSemaphore(value: 0)
 
    URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
        /*
        URLSession is established and the JSON file from the API is set to be fetched
        in an asynchronous manner. After the file is fetched, data, response, error
        are returned as the input parameter values of this Completion Handler Closure.
        */
 
        // Process input parameter 'error'
        guard error == nil else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
       
        /*
         ---------------------------------------------------------
         🔴 Any 'return' used within the completionHandler Closure
            exits the Closure; not the public function it is in.
         ---------------------------------------------------------
         */
 
        // Process input parameter 'response'. HTTP response status codes from 200 to 299 indicate success.
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
 
        // Process input parameter 'data'. Unwrap Optional 'data' if it has a value.
        guard let jsonDataFromApi = data else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
 
        //------------------------------------------------
        // JSON data is obtained from the API. Process it.
        //------------------------------------------------
        do {
                   /*
                    Foundation framework’s JSONSerialization class is used to convert JSON data
                    into Swift data types such as Dictionary, Array, String, Number, or Bool.
                    */
               let jsonResponse = try JSONSerialization.jsonObject(with: jsonDataFromApi,
                                      options: JSONSerialization.ReadingOptions.mutableContainers)
//            guard let jsonArray = jsonResponse as? [Any] else { return }
            
                if let game = jsonResponse as? [String: Any] {
                    
//                    let game = jsonResponse as? [String: Any]
                    
                    guard let gameID = game["id"] as? Int else {return}
                    
                    guard let gameDate = game["date"] as? String else {return}
                    
                    guard let gameNumber = game["number"] as? Int else {return}
                    
                    guard let gameName = game["name"] as? String else {return}
                    
                    guard let gameReward = game["reward"] as? Int else {return}
                    
                    guard let gamePrice = game["initial_face_value"] as? Int else {return}

                    guard let gameLocation = game["location"] as? String else {return}
                    
                    var delimiter = " "
                    var token = gameName.components(separatedBy: delimiter)
                    print (token[2])

                    myTicket = Ticket(id: UUID(), owner: gameOwner, gameID: String(gameID), ticketID: String(ticketID), gameNumber: gameNumber, location: gameLocation, name: gameName, price: gamePrice, reward: gameReward, opponent: token[2], date: gameDate)
                    
                    my_tickets.append(myTicket)
                    
                } else {
                    semaphore.signal()
                    return }
            
            
                  
                      
        
               } catch {
            semaphore.signal()
            return
        }
 
        semaphore.signal()
    }).resume()
 
    /*
     The URLSession task above is set up. It begins in a suspended state.
     The resume() method starts processing the task in an execution thread.
 
     The semaphore.wait blocks the execution thread and starts waiting.
     Upon completion of the task, the Completion Handler code is executed.
     The waiting ends when .signal() fires or timeout period of 10 seconds expires.
    */
 
    _ = semaphore.wait(timeout: .now() + 2)
 
}

/*
====================================
MARK: - POST Request Data from API
====================================
*/
public func postRequestData5(user: String, action: String, ticketID: String) {
    

    // prepare json data
    let json: [String: Any] = ["user": user, "action": action, "ticket_id": ticketID]
    let jsonData = try? JSONSerialization.data(withJSONObject: json)

    // create post request
    let url = URL(string: "https://goblins.info.tm/requests.pyhtml")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // insert json data to the request
    request.httpBody = jsonData
    
    request.addValue("application/json", forHTTPHeaderField: "content-type")
 
    /*
    *********************************************************************
    *  Setting Up a URL Session to Fetch the JSON File from the API     *
    *  in an Asynchronous Manner and Processing the Received JSON File  *
    *********************************************************************
    */
   
    /*
     Create a semaphore to control getting and processing API data.
     signal() -> Int    Signals (increments) a semaphore.
     wait()             Waits for, or decrements, a semaphore.
     */
    let semaphore = DispatchSemaphore(value: 0)
 
    URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
        /*
        URLSession is established and the JSON file from the API is set to be fetched
        in an asynchronous manner. After the file is fetched, data, response, error
        are returned as the input parameter values of this Completion Handler Closure.
        */
 
        // Process input parameter 'error'
        guard error == nil else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
       
        /*
         ---------------------------------------------------------
         🔴 Any 'return' used within the completionHandler Closure
            exits the Closure; not the public function it is in.
         ---------------------------------------------------------
         */
 
        // Process input parameter 'response'. HTTP response status codes from 200 to 299 indicate success.
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
 
        // Process input parameter 'data'. Unwrap Optional 'data' if it has a value.
        guard let jsonDataFromApi = data else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
 
        //------------------------------------------------
        // JSON data is obtained from the API. Process it.
        //------------------------------------------------
        do {
                   /*
                    Foundation framework’s JSONSerialization class is used to convert JSON data
                    into Swift data types such as Dictionary, Array, String, Number, or Bool.
                    */
               let jsonResponse = try JSONSerialization.jsonObject(with: jsonDataFromApi,
                                      options: JSONSerialization.ReadingOptions.mutableContainers)
                if let sellResponse = jsonResponse as? [String: Any] {
                    
                    if sellResponse["balance"] != nil {
                        sellSuccess = true
                    }
                    
                } else {
                    semaphore.signal()
                    return }
            
                  
                      
        
               } catch {
            semaphore.signal()
            return
        }
 
        semaphore.signal()
    }).resume()
 
    /*
     The URLSession task above is set up. It begins in a suspended state.
     The resume() method starts processing the task in an execution thread.
 
     The semaphore.wait blocks the execution thread and starts waiting.
     Upon completion of the task, the Completion Handler code is executed.
     The waiting ends when .signal() fires or timeout period of 10 seconds expires.
    */
 
    _ = semaphore.wait(timeout: .now() + 2)
 
}

/*
====================================
MARK: - POST Request Data from API
====================================
*/
public func postRequestData6(user: String, action: String, gameID: String) {
    

    // prepare json data
    let json: [String: Any] = ["user": user, "action": action, "game_id": gameID]
    let jsonData = try? JSONSerialization.data(withJSONObject: json)

    // create post request
    let url = URL(string: "https://goblins.info.tm/requests.pyhtml")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // insert json data to the request
    request.httpBody = jsonData
    
    request.addValue("application/json", forHTTPHeaderField: "content-type")
 
    /*
    *********************************************************************
    *  Setting Up a URL Session to Fetch the JSON File from the API     *
    *  in an Asynchronous Manner and Processing the Received JSON File  *
    *********************************************************************
    */
   
    /*
     Create a semaphore to control getting and processing API data.
     signal() -> Int    Signals (increments) a semaphore.
     wait()             Waits for, or decrements, a semaphore.
     */
    let semaphore = DispatchSemaphore(value: 0)
 
    URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
        /*
        URLSession is established and the JSON file from the API is set to be fetched
        in an asynchronous manner. After the file is fetched, data, response, error
        are returned as the input parameter values of this Completion Handler Closure.
        */
 
        // Process input parameter 'error'
        guard error == nil else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
       
        /*
         ---------------------------------------------------------
         🔴 Any 'return' used within the completionHandler Closure
            exits the Closure; not the public function it is in.
         ---------------------------------------------------------
         */
 
        // Process input parameter 'response'. HTTP response status codes from 200 to 299 indicate success.
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
 
        // Process input parameter 'data'. Unwrap Optional 'data' if it has a value.
        guard let jsonDataFromApi = data else {
            // productFound will have the initial values set as above
            semaphore.signal()
            return
        }
 
        //------------------------------------------------
        // JSON data is obtained from the API. Process it.
        //------------------------------------------------
        do {
                   /*
                    Foundation framework’s JSONSerialization class is used to convert JSON data
                    into Swift data types such as Dictionary, Array, String, Number, or Bool.
                    */
               let jsonResponse = try JSONSerialization.jsonObject(with: jsonDataFromApi,
                                      options: JSONSerialization.ReadingOptions.mutableContainers)
                if let buyResponse = jsonResponse as? [String: Any] {
                    
                    if buyResponse["balance"] != nil {
                        buySuccess = true
                    }
                    
                } else {
                    semaphore.signal()
                    return }
            
                  
                      
        
               } catch {
            semaphore.signal()
            return
        }
 
        semaphore.signal()
    }).resume()
 
    /*
     The URLSession task above is set up. It begins in a suspended state.
     The resume() method starts processing the task in an execution thread.
 
     The semaphore.wait blocks the execution thread and starts waiting.
     Upon completion of the task, the Completion Handler code is executed.
     The waiting ends when .signal() fires or timeout period of 10 seconds expires.
    */
 
    _ = semaphore.wait(timeout: .now() + 2)
 
}
