//
//  ContentView.swift
//  FetchDemo
//
//  Created by Aadi Shiv Malhotra on 3/18/24.
//

import SwiftUI


// Define the Item struct that conforms to Decodable for JSON parsing,
// Identifiable for use in ForEach, and Comparable for sorting.
// Declaring it in the same file as it helps readability
// Each Item has an id, listId, and name
// id and listId are guaranteed to exit, but name IS NOT guaranteed to be real as it can be NULL
struct Item: Decodable, Identifiable, Comparable {
    var id: Int
    var listId: Int
    var name: String?
    
    
    // Compute a numeric representation of the item name, extracting digits and converting to Int.
    // This is useful for sorting items that are named with numbers (e.g., "Item 1").
    // Do I need this still?
    var numericName: Int {
        return Int(name?.filter(\.isNumber) ?? "") ?? 0
    }

    // Define custom comparison logic for Item structs.
    // First, compare by listId, then by numericName if listIds are equal.
    // Do i need this still
    static func < (lhs: Item, rhs: Item) -> Bool {
        (lhs.listId, lhs.numericName) < (rhs.listId, rhs.numericName)
    }
}

// Create your main App view that fetches and displays the data.
struct ContentView: View {
    @State private var groupedItems = [Int: [Item]]()
    
    var body: some View {
        NavigationView {
            // Create a list where each section represents a group of items with the same listId.
            List(groupedItems.keys.sorted(), id: \.self) { key in
                Section(header: Text("List ID \(key)")) {
                    
                    // List each item within its listId group.
                    ForEach(groupedItems[key] ?? [], id: \.id) { item in
                        Text(item.name ?? "N/A") // Should never actually show N/A as we filter, but keep for safety
                    }
                }
            }
            .navigationTitle("Items")
            .onAppear {
                fetchItems() // Fetch items when the view appears.
            }
        }
    }
    
    // Function to fetch items from a given URL and parse the JSON data.
    func fetchItems() {
        guard let url = URL(string: "https://fetch-hiring.s3.amazonaws.com/hiring.json") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            // Parse the JSON data into an array of Item structs.
            if let data = data,
               let items = try? JSONDecoder().decode([Item].self, from: data) {
                DispatchQueue.main.async {
                    // Filter out items with nil or empty names, sort them, and group by listId.
                    self.groupedItems = Dictionary(grouping: items.filter { $0.name?.isEmpty == false && $0.name != nil }.sorted(), by: { $0.listId })
                }
            }
        }.resume()
    }
}


