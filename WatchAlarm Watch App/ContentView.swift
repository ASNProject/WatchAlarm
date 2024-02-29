////
////  ContentView.swift
////  ChronoAlert Watch App
////
////  Created by Arief Setyo Nugroho on 16/02/24.

import SwiftUI
import UserNotifications
import WatchKit

struct ContentView: View {
    @StateObject private var alarmManager = AlarmManager()
    @State private var showingAlarmSheet = false
    
    // Haptic
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack {
                List {
                    ForEach(alarmManager.alarms, id: \.time) { alarm in
                        Text(alarmTimeString(alarm: alarm.time, runningElapsedTime: alarm.runningElapsedTime, selectedOption: alarm.selectedOption))
                        
                    }
                    .onDelete(perform: deleteAlarm)
                }.frame(height: 100)
                
                Button("Add Alarm") {
                    showingAlarmSheet.toggle()
                }
                .sheet(isPresented: $showingAlarmSheet) {
                    AlarmInputView(addAlarm: self.addAlarm)
                }
                Button("Request permission"){
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
                        success, error in
                        if success {
                            print("All set!")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }

            }
            .onReceive(timer) { _ in
                alarmManager.checkAlarms()
            }
            .environmentObject(alarmManager)
        }
    }

    
    func alarmTimeString(alarm: Date, runningElapsedTime: TimeInterval, selectedOption: String) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: alarm)
        
        let milliseconds = Int(runningElapsedTime * 1000)
        
        return "Alarm: \(timeString) \nElapsed Time: \(milliseconds) ms \nSelected Option: \(selectedOption)"    }
    
    func addAlarm(time: Date, selectedOption: String) {
        alarmManager.addAlarm(time: time, selectedOption: selectedOption)
    }
    
    func deleteAlarm(at offsets: IndexSet) {
        alarmManager.deleteAlarm(at: offsets)
    }
}


struct AlarmInputView: View {
    @State private var alarmTime = Date()
    @State private var selectedOption = "Visual" // Default selected option
    var addAlarm: (Date, String) -> Void
    
    var body: some View {
        ScrollView{
            VStack {
                DatePicker("Select Alarm Time", selection: $alarmTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .frame(height: 80) // Set height of DatePicker
                
                Picker("Alarm Options", selection: $selectedOption) {
                    Text("Visual").tag("Visual")
                    Text("Visual & Haptic").tag("Visual & Haptic")
                    Text("Visual & Audio").tag("Visual & Audio")
                    Text("Haptic").tag("Haptic")
                    Text("Haptic & Audio").tag("Haptic & Audio")
                    Text("Audio").tag("Audio")
                    Text("All").tag("All")
                }
                .pickerStyle(DefaultPickerStyle()) // You can change the style as per your requirement
                .frame(height: 50) // Set height of Picker
                
                Button("Set Alarm") {
                    addAlarm(alarmTime, selectedOption)
                }
            }
        }
        .padding()
    }
}



class AlarmManager: NSObject, ObservableObject {
    @Published var alarms: [Alarm] = []
    private var timers: [Timer] = [] // Store references to active timers
    
    private let userNotificationCenter = UNUserNotificationCenter.current()
    
    let haptic = WKHapticType.notification

    
    override init() {
        super.init()
        userNotificationCenter.delegate = self
    }
    
    func checkAlarms() {
        let currentTime = Date()
        let calendar = Calendar.current
        
        for index in alarms.indices {
            let alarm = alarms[index]
            if calendar.isDate(currentTime, equalTo: alarm.time, toGranularity: .minute) {
                if alarm.triggeredAt == nil {
                    print("Alarm triggered at \(alarm.time)")
                    alarms[index].triggeredAt = Date()
                    startAlarmCounting(for: index)
                    scheduleNotification(for: alarm.time)
//                    self.addHaptic()
                }
            }
        }
    }
    
    func addHaptic(){
        WKInterfaceDevice().play(haptic)
        print("Haptic ON")
    }
    
    func addAlarm(time: Date, selectedOption: String) {
        alarms.append(Alarm(time: time, triggeredAt: nil, runningElapsedTime: 0, selectedOption: selectedOption))
        
        // Schedule notification for the alarm time
        scheduleNotification(for: time)
    }
    
    func deleteAlarm(at offsets: IndexSet) {
        alarms.remove(atOffsets: offsets)
    }
    
    func scheduleNotification(for time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = "Your alarm is ringing!"
        content.sound = UNNotificationSound.default
        
        // Define actions
        let stopAction = UNNotificationAction(identifier: "Stop", title: "Stop", options: [.foreground])
        
        // Attach actions to notification
        let categoryIdentifier = "alarmCategory"
        let alarmCategory = UNNotificationCategory(identifier: categoryIdentifier, actions: [ stopAction], intentIdentifiers: [], options: [])
        
        userNotificationCenter.setNotificationCategories([alarmCategory])
        
        content.categoryIdentifier = categoryIdentifier
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        userNotificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(time)")
            }
        }
    }
    
    func startAlarmCounting(for index: Int) {
        // Pastikan index berada dalam rentang yang valid
        guard index >= 0 && index < alarms.count else {
            return
        }
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard let triggeredAt = self.alarms[index].triggeredAt else {
                timer.invalidate()
                return
            }
            let elapsedTime = Date().timeIntervalSince(triggeredAt)
            // Update running elapsed time in the corresponding alarm
            self.alarms[index].runningElapsedTime = elapsedTime
        }
        timers.append(timer) // Store reference to the timer
    }

}

struct Alarm {
    var time: Date
    var triggeredAt: Date?
    var runningElapsedTime: TimeInterval // Store running elapsed time
    var selectedOption: String // Store selected option

}

extension AlarmManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "Stop" {
            // Find the index of the triggered alarm
            if let alarmIndex = alarms.firstIndex(where: { $0.triggeredAt != nil }) {
                // Stop the counting for the alarm
                stopAlarmCounting(for: alarmIndex)
            }
        }
        completionHandler()
    }
    
    private func stopAlarmCounting(for index: Int) {
        // Handle stopping the alarm counting here
        print("Stopping alarm counting for index \(index)")
        // Invalidate the timer associated with this alarm
        timers[index].invalidate()
        // Remove the timer from the timers array
        timers.remove(at: index)
    }
}


