//
//  SearchBar.swift
//  FootballTickets
//
//  Created by Sameer Dandekar on 3/30/20.
//  Copyright © 2020 Sameer Dandekar. All rights reserved.
//

import SwiftUI
 
struct SearchBar: UIViewRepresentable {
  
    @Binding var searchItem: String
  
    // This class is created to coordinate with UISearchBar
    class Coordinator: NSObject, UISearchBarDelegate {
      
        @Binding var searchText: String
      
        init(searchText: Binding<String>) {
            _searchText = searchText
        }
      
        func searchBar(_ searchBar: UISearchBar, textDidChange searchString: String) {
            searchText = searchString
            searchBar.showsCancelButton = true
        }
       
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchText = ""
            searchBar.showsCancelButton = false
            searchBar.endEditing(true)
        }
    }
  
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(searchText: $searchItem)
    }
  
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        // Create a UISearchBar instance and store its unique id into searchBar
        let searchBar = UISearchBar(frame: .zero)
      
        // Assign the associated coordinator as the search bar's delegate
        searchBar.delegate = context.coordinator
       
        // Return the created and dressed up search bar
        return searchBar
    }
  
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        // Update UISearchBar instance's property 'text', which is the current or starting search text
        uiView.text = searchItem
    }
}
