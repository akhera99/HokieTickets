//
//  WebView.swift
//  BarcodeScanner
//
//  Created by Sameer Dandekar on 2/15/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//
 
import SwiftUI
import WebKit
 
struct WebView: UIViewRepresentable {
 
    // Input Parameter
    let url: String
 
    func makeUIView(context: Context) -> WKWebView  {
        WKWebView(frame: .zero)
    }
 
    // A WKWebView object displays interactive web content in a web browser within the app
    func updateUIView(_ webView: WKWebView, context: Context) {
     
        // Convert url string value into a URL struct
        var urlStruct: URL?
 
        if let url_struct = URL(string: url) {
            urlStruct = url_struct
        } else {
            // Show nothing since url is invalid
            return
        }
     
        /*
         Convert the URL struct into a URLRequest struct.
         URLRequest is a URL load request that is independent of protocol or URL scheme.
         */
        let urlLoadRequest = URLRequest(url: urlStruct!)
     
        // Ask the webView object to display the web page for the given url
        webView.load(urlLoadRequest)
    }
 
}
 
struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url: "https://www.apple.com")
    }
}
 
