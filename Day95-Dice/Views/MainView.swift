//
//  ContentView.swift
//  Day95-Dice
//
//  Created by Robin Phillips on 28/08/2021.
//

import SwiftUI
import CoreData


enum Dice: Int, CaseIterable, Identifiable {
    case dice4 = 4, dice6 = 6, dice8 = 8, dice10 = 10, dice12 = 12, dice20 = 20, dice100 = 100
    
    var id: Int { self.rawValue }
}

class AppSettings: ObservableObject {
    @Published var selectedDice: Dice = Dice.dice6 // default value
    @Published var _numberOfDice = 0
    var numberOfDice: Int {
        get {
            _numberOfDice + 1
        }
    }
    
    @Published var totals = [Int]()
    @Published var results = [String]()
    @Published var rollCount = 0
}





struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var appSettings = AppSettings()
    
    
    
    var body: some View {
        
        
        
        
        
        
        TabView {
            
            
            DiceRollView(appSettings: appSettings)
                .tabItem {
                    Image(systemName: "dice")
                    Text("Roll dice")
                }
            ResultsView(appSettings: appSettings)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Results")
                }
            
        }
        
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
