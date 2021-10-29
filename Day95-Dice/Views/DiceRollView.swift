//
//  DiceRollView.swift
//  DiceRollView
//
//  Created by Robin Phillips on 28/08/2021.
//

import SwiftUI
import CoreData
import CoreHaptics

struct DiceRollView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var appSettings: AppSettings
    var colours: [Color] = [Color.red, Color.blue, Color.yellow, Color.green, Color.pink, Color.purple, Color.orange]
    @State private var rotationAmount = 0.0
    @State private var diceLabelNum = 0
    
    @State private var engine: CHHapticEngine?
    
    @State private var hitTestingOn = true
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    
                    
                    Section() {
                        Picker("Which size?", selection: $appSettings.selectedDice) {
                            ForEach(Dice.allCases, id: \.self) { i in
                                Text("Size \(i.rawValue)")
                                
                            }
                        }
                        Picker("How many?", selection: $appSettings._numberOfDice) {
                            ForEach(0..<10) { i in
                                Text(" \(i + 1)")
                                
                            }
                        }

                    }
                    
                    
                    
                    
//                    Button(appSettings.numberOfDice < 2 ? "Roll die" : "Roll dice") {
//                        var tempResults = [Int]()
//                        for i in 0..<appSettings.numberOfDice {
//                            tempResults.append( Int.random(in: 1...appSettings.selectedDice.rawValue) )
//                            print("number of dice: \(appSettings.numberOfDice) \nsize of dice: \(appSettings.selectedDice.rawValue)")
//                            print("temp result \(tempResults[i])")
//                        }
//                        print("temp results sum \(tempResults.reduce(0, +))\n")
//                        appSettings.totals.insert(tempResults.reduce(0, +), at: 0)
//                        
//                        
//                    }
//                    
//
//                    if appSettings.totals.count > 0 {
//                        Text("You have rolled: \(appSettings.totals[0])")
//                        
//                    }

                    
                    
                }
                .animation(.default)
                
                GeometryReader { geo in
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .foregroundColor(colours[Int.random(in: 0..<colours.count-1)]).opacity(0.3)
                            .frame(width: geo.size.width * 0.6, height: geo.size.width * 0.6, alignment: .center)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        
//                        RoundedRectangle(cornerRadius: 30)
//                            .stroke(colours[Int.random(in: 0..<colours.count-1)], lineWidth: 4)
//                            .frame(width: geo.size.width * 0.6, height: geo.size.width * 0.6, alignment: .center)
//                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        
                        if diceLabelNum > 0 {
//                            Text("\(appSettings.totals[0])")
                            Text("\(diceLabelNum)")
                                .font(.system(size: geo.size.height / 3))
                                .bold()
                                .foregroundColor(.white)
                                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        } else {
                            Text("ROLL")
                                .font(.system(size: geo.size.height / 5))
                                .bold()
                                .foregroundColor(.white)
                                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        }
                        
                        
                        
                    }
                    .rotation3DEffect(.degrees(rotationAmount), axis: (x: 0, y: 1, z: 0))
                    
                    .onTapGesture {
                        prepareHaptics()
                        rollingDice()
                        
                        hitTestingOn = false
                        
                        if rotationAmount == 0 {
                            rotationAmount = 360
                        } else {
                            rotationAmount = 0
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            rollRumble()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            rollDice()
                            hitTestingOn = true
                        }
                    }
                    .animation(.easeIn)
                    .allowsHitTesting(hitTestingOn)
                    
                }
                
                
                
            }
            .navigationTitle(Text("Dice!"))
        }
    }
    
    func rollingDice() {
        
        var timeDelay = 0.01
        for i in 0..<30 {
            DispatchQueue.main.asyncAfter(deadline: .now() + timeDelay) {
                diceLabelNum = Int.random(in: 1...appSettings.selectedDice.rawValue) * appSettings.numberOfDice
                print(diceLabelNum)
            }
            timeDelay = timeDelay + Double(i) / 400
        }
    }
    
    func rollDice() {
        appSettings.rollCount += 1
        var tempResults = [Int]()
        var tempTotal = 0
        for i in 0..<appSettings.numberOfDice {
            tempResults.append( Int.random(in: 1...appSettings.selectedDice.rawValue) )
            print("number of dice: \(appSettings.numberOfDice) \nsize of dice: \(appSettings.selectedDice.rawValue)")
            print("temp result \(tempResults[i])")
        }
        tempTotal = tempResults.reduce(0, +)
        print("temp results sum \(tempTotal)\n")
        appSettings.totals.insert(tempTotal, at: 0)
        appSettings.results.insert("Roll \(appSettings.rollCount): \(tempTotal)", at: 0)
        diceLabelNum = tempTotal
        
        addItem(diceRollResult: tempTotal)
    }
    
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    
    func rollRumble() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 4)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let unknown = CHHapticEventParameter(parameterID: .decayTime, value: 4)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness, unknown], relativeTime: 0)
        events.append(event)
        
        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness, unknown], relativeTime: 0.05)
        events.append(event2)
        
        let event3 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness, unknown], relativeTime: 0.1)
        events.append(event3)
        
        let event4 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness, unknown], relativeTime: 0.15)
        events.append(event4)
        
        let event5 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness, unknown], relativeTime: 0.25)
        events.append(event5)
        
        let event6 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness, unknown], relativeTime: 0.4)
        events.append(event6)
        
        let event7 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness, unknown], relativeTime: 0.6)
        events.append(event7)
        
        let event8 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness, unknown], relativeTime: 0.9)
        events.append(event8)
        
        let long1 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0, duration: 0.5)
        events.append(long1)
        
        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    
    private func addItem(diceRollResult: Int) {
        withAnimation {
            let newItem = DiceRoll(context: viewContext)
            newItem.timeOfRoll = Date()
            newItem.id = UUID()
            newItem.result = Int16(diceRollResult)
            newItem.resultText = "\(diceRollResult)"

            do {
                viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}

//struct DiceRollView_Previews: PreviewProvider {
//    static var dice = Dice.dice6
//
//    static var previews: some View {
//        DiceRollView(dice: dice.rawValue)
//    }
//}
