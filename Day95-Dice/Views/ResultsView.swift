//
//  ResultsView.swift
//  ResultsView
//
//  Created by Robin Phillips on 28/08/2021.
//

import SwiftUI
import CoreData

struct ResultsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DiceRoll.timeOfRoll, ascending: false)],
        animation: .default)
    private var items: FetchedResults<DiceRoll>
    
    @ObservedObject var appSettings: AppSettings
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items, id: \.self) { item in
                    Text("\(item.wrapResultText)")
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle(Text("Results"))
            .toolbar {
                #if os(iOS)
                EditButton()
                #endif
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(appSettings: AppSettings())
    }
}
