//
//  ContentView.swift
//  iExpense
//
//  Created by Aidan Bergerson on 12/18/24.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
        
        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    
    @State private var showingAddExpense = false
    
    @State private var type = "All"
    
    let types = ["All", "Business", "Personal"]
    
    var body: some View {
        NavigationStack {
            Picker("Category Selector", selection: $type) {
                ForEach(types, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            List {
                ForEach(expenses.items) { item in
                    if type == item.type || type == "All" {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                .modifier(ExpenseViewModifier(expense: item))
                                
                        }
                    }
                }
                .onDelete(perform: removeItems)
            }
            .navigationTitle("iExpense")
            .toolbar {
                NavigationLink {
                    AddView(expenses: expenses)
                        .navigationBarBackButtonHidden()
                } label: {
                    Image(systemName: "plus")
                }
            }
            

        }
       
    }
    
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}

struct ExpenseViewModifier: ViewModifier {
    var expense: ExpenseItem
    func body(content: Content) -> some View {
        if expense.amount < 10 {
            content
                .foregroundStyle(.green)
        } else if expense.amount < 100 {
            content
                .foregroundStyle(.yellow)
        } else {
            content
                .foregroundStyle(.red)
        }
    }
}


#Preview {
    ContentView()
}
