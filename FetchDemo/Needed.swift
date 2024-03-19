//
//  Needed.swift
//  FetchDemo
//
//  Created by Aadi Shiv Malhotra on 3/18/24.
//

import Foundation

struct Item: Decodable, Identifiable, Comparable {
    let id: Int
    let listId: Int
    let name: String?
    
    var numericName: Int {
        return Int(name?.filter { "0"...\u{0039}" ~= $0 } ?? "") ?? 0
    }

    static func < (lhs: Item, rhs: Item) -> Bool {
        return lhs.numericName < rhs.numericName
    }
}


class ItemsViewModel: ObservableObject {
    @Published var groupedItems: [Int: [Item]] = [:]
    
    func fetchItems() {
        NetworkManager().fetchItems { [weak self] items in
            DispatchQueue.main.async {
                self?.groupedItems = Dictionary(grouping: items.sorted { $0.listId < $1.listId && $0 < $1 }) { $0.listId }
            }
        }
    }
}

class NetworkManager {
    func fetchItems(completion: @escaping ([Item]) -> Void) {
        guard let url = URL(string: "https://fetch-hiring.s3.amazonaws.com/hiring.json") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let decoder = JSONDecoder()
            if let items = try? decoder.decode([Item].self, from: data) {
                completion(items.filter { $0.name?.isEmpty == false && $0.name != nil })
            } else {
                print("Failed to decode data")
            }
        }
        task.resume()
    }
}
