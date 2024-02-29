////
////  ContentView.swift
////  ChronoAlert Watch App
////
////  Created by Arief Setyo Nugroho on 16/02/24.
////
//
//import SwiftUI
//import AVFoundation
//import WatchKit
//
//struct Alarm: Identifiable {
//    var hour: Int
//    var minute: Int
//    var second: Int
//    var id = UUID()
//}
//
//struct ContentView: View {
//    @State private var currentTime = Date()
//    @State private var showingAlarmSheet = false
//    @State private var alarms: [Alarm] = []
//    @State private var showAlert = false
//    @State private var alertShow = false
//    @State private var alertMessage = ""
//    @State private var startTime: Date?
//    @State private var countingResult: [TimeInterval] = []
//    
//    @State private var showCountingResults = false
//    
//    // Set audio
//    @State private var audioPlayer: AVAudioPlayer?
//    @State private var isPlayingAudio = false
//    
//    //vibration
//    let haptic = WKHapticType.notification
//    
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            Text(getCurrentTime())
//                .font(.largeTitle)
//                .padding()
//            
//            Spacer()
//            
//            Text("Hello, world!")
//            
//            Spacer()
//            
//            HStack {
//                Button(action: {
//                    showingAlarmSheet = true
//                }) {
//                    Text("Set Alarm")
//                        .font(.custom("Arial", size: 10))
//                        .padding()
//                        .foregroundColor(.primary)
//                        .background(Color.blue)
//                        .cornerRadius(8)
//                }
//                .frame(width: 100)
//                .sheet(isPresented: $showingAlarmSheet){
//                    alarmInputView(setAlarm: addAlarm, alarms: $alarms, countingResults: $countingResult)
//                }
//                
//                
//                Button(action: {
//                    showCountingResults = true
//                }) {
//                    Text("Get Data")
//                        .font(.custom("Arial", size: 10))
//                        .padding()
//                        .foregroundColor(.primary)
//                        .background(Color.blue)
//                        .cornerRadius(8)
//                }
//                .frame(width: 100)
//                .sheet(isPresented: $showCountingResults){
//                    CountingResultsView(countingResults: countingResult)
//                }
//            }
//            ///Line Terakhir
//        }
//        .padding(.top, 16)
//        .buttonStyle(BorderlessButtonStyle())
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
//            self.currentTime = Date()
//            self.checkAlarm()
//        }
//        .alert(isPresented: $showAlert){
//            self.addHaptic()
//            self.playAudio()
//            return Alert(title: Text("Alarm!"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
//                if let startTime = startTime {
//                    let endTime = Date()
//                    let timeDifference = endTime.timeIntervalSince(startTime)
//                    countingResult.append(timeDifference)
//                    //Stop Audio
//                    self.stopAudio()
//                    // Reset start time
//                    self.startTime = nil
//                }
//                showAlert = false
//            })
//        }
//        // Play audio
//        .onAppear {
//            self.playAudio()
//            self.addHaptic()
//        }
//
//    }
//    
//    func getCurrentTime() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        return formatter.string(from: currentTime)
//    }
//    
//    func addAlarm(hour: Int, minute: Int, second: Int) {
//        let newAlarm = Alarm(hour: hour, minute: minute, second: second)
//        alarms.append(newAlarm)
//    }
//    
//    /// Check Alarm Visual
//    func checkAlarm() {
//        for alarm in alarms {
//            let calendar = Calendar.current
//            let currentHour = calendar.component(.hour, from: currentTime)
//            let currentMinute = calendar.component(.minute, from: currentTime)
//            let currentSecond = calendar.component(.second, from: currentTime)
//            
//            if currentHour == alarm.hour && currentMinute == alarm.minute && currentSecond == alarm.second {
//                showAlert = true
//                alertMessage = "Alarm \(alarm.hour):\(alarm.minute):\(alarm.second) telah tercapai!"
//                startTime = Date()
//            }
//        }
//        
//        if let startTime = startTime, showAlert == false {
//            let endTime = Date()
//            let calendar = Calendar.current
//            let secondsDifference = calendar.dateComponents([.second], from: startTime, to: endTime).second ?? 0
//
//            if countingResult.isEmpty || countingResult.last != 0 {
//                countingResult.append(0)
//            }
//
//            countingResult[countingResult.count - 1] += Double(secondsDifference)
//
//            self.startTime = nil
//        }
//    }
//    
//    func playAudio() {
//        guard let soundURL = Bundle.main.url(forResource: "tone", withExtension: "wav", subdirectory: "Sounds") else {
//            return
//        }
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
//            audioPlayer?.play()
//        } catch {
//            print("Error playing audio: \(error.localizedDescription)")
//        }
//    }
//    func stopAudio() {
//        audioPlayer?.stop()
//    }
//    
//    func addHaptic(){
//        WKInterfaceDevice().play(haptic)
//    }
//
//}
//
//
//
//struct alarmInputView: View {
//    var setAlarm: (Int, Int, Int) -> Void
//    @State private var alarmHour = 0
//    @State private var alarmMinute = 0
//    @State private var alarmSecond = 0
//    @State private var secondText = "01"
//    @Binding var alarms: [Alarm]
//    @State private var showAlarmList = false
//    @Binding var countingResults: [TimeInterval]
//
//    
//    var body: some View {
//        ScrollView {
//            VStack {
//                Text("Set Alarm")
//                    .font(.custom("Arial", size: 14))
//                    .padding()
//                
//                Picker(selection: $alarmHour, label: Text("Hour")){
//                    ForEach(0..<24) { hour in
//                        Text("\(hour)")
//                    }
//                }
//                .pickerStyle(WheelPickerStyle())
//                .labelsHidden()
//                .frame(width: 100, height: 20)
//                
//                Picker(selection: $alarmMinute, label: Text("Minute")) {
//                    ForEach(0..<60) { minute in
//                        Text("\(minute)")
//                    }
//                }
//                .pickerStyle(WheelPickerStyle())
//                .labelsHidden()
//                .frame(width: 100, height: 20)
//                
//                Button(action: {
//                    setAlarm(alarmHour, alarmMinute, alarmSecond)
//                }) {
//                    Text("Save")
//                        .font(.custom("Arial", size: 12))
//                        .padding()
//                        .foregroundColor(.primary)
//                        .background(Color.blue)
//                        .cornerRadius(8)
//                }
//                .frame(width: .infinity)
//                Button(action: {
//                    showAlarmList = true
//                }) {
//                    Text("List alarm")
//                        .font(.custom("Arial", size: 12))
//                        .padding()
//                        .foregroundColor(.primary)
//                        .background(Color.blue)
//                        .cornerRadius(8)
//                }
//                .frame(width: .infinity)
//                .sheet(isPresented: $showAlarmList){
//                    AlarmListView(alarms: $alarms)
//                }
//                Button(action: {
//                    self.alarms = []
//                    self.countingResults = []
//                }) {
//                    Text("Reset")
//                        .font(.custom("Arial", size: 12))
//                        .padding()
//                        .foregroundColor(.primary)
//                        .background(Color.red)
//                        .cornerRadius(8)
//                }
//                .frame(width: .infinity)
//                .padding(.top, 20)
//            }
//        }
//        .padding()
//        .buttonStyle(BorderlessButtonStyle())
//    }
//    
//}
//
//struct AlarmListView: View {
//    @Binding var alarms: [Alarm]
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(Array(alarms.enumerated()), id: \.element.id) { index, alarm in
//                    Text("Alarm \(index + 1): \(alarm.hour):\(alarm.minute):\(alarm.second)")
//                }
//            }
//            .navigationTitle("Alarm List")
//            .font(.custom("Arial", size: 12))
//        }
//    }
//}
//
//
//
//
//struct CountingResultsView: View {
//    var countingResults: [TimeInterval]
//
//    var body: some View {
//        List {
//            ForEach(countingResults.indices, id: \.self) { index in
//                Text("Alarm \(index + 1): \(Int(countingResults[index] * 1000)) ms")
//            }
//        }
//        .navigationTitle("Results")
//        .font(.custom("Arial", size: 12))
//    }
//}
//
//
//
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//////////////////////////////////////////////////////////////////////////////////
//import SwiftUI
//import UserNotifications
//
//struct ContentView: View {
//    @State private var alarms: [Alarm] = []
//    @State private var showingAlarmSheet = false
//    
//    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    
//    var body: some View {
//        VStack {
//            List {
//                ForEach(alarms, id: \.time) { alarm in
//                    Text(alarmTimeString(alarm: alarm.time))
//                    
//                }
//                .onDelete(perform: deleteAlarm)
//            }
//            
//            Button("Add Alarm") {
//                showingAlarmSheet.toggle()
//            }
//            .sheet(isPresented: $showingAlarmSheet) {
//                AlarmInputView(addAlarm: self.addAlarm)
//            }
//        }
////        .onAppear {
////            registerNotificationCategory()
////            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
////                if success {
////                    print("Notification authorization granted.")
////                } else if let error = error {
////                    print("Notification authorization failed: \(error.localizedDescription)")
////                }
////            }
////        }
//        .onReceive(timer) { _ in
//            checkAlarms()
//        }
//    }
//    
//    func checkAlarms() {
//        let currentTime = Date()
//        let calendar = Calendar.current
//        
//        for index in alarms.indices {
//            let alarm = alarms[index]
//            if calendar.isDate(currentTime, equalTo: alarm.time, toGranularity: .minute) {
//                if alarm.triggeredAt == nil {
//                    print("Alarm triggered at \(alarm.time)")
//                    alarms[index].triggeredAt = Date()
//                    startAlarmCounting(for: index)
//                    scheduleNotification(for: alarm.time)
//
//                }
//            }
//        }
//    }
//    
//    func alarmTimeString(alarm: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        return formatter.string(from: alarm)
//    }
//    
//    func addAlarm(time: Date) {
//        alarms.append(Alarm(time: time, triggeredAt: nil))
//        
//        // Schedule notification for the alarm time
//        scheduleNotification(for: time)
//    }
//    
//    func deleteAlarm(at offsets: IndexSet) {
//        alarms.remove(atOffsets: offsets)
//    }
//    
//    func scheduleNotification(for time: Date) {
//        let content = UNMutableNotificationContent()
//        content.title = "Alarm"
//        content.body = "Your alarm is ringing!"
//        content.sound = UNNotificationSound.default
//        
//        // Define actions
//        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
//        let stopAction = UNNotificationAction(identifier: "Stop", title: "Stop", options: [])
//        
//        // Attach actions to notification
//        let categoryIdentifier = "alarmCategory"
//        let alarmCategory = UNNotificationCategory(identifier: categoryIdentifier, actions: [snoozeAction, stopAction], intentIdentifiers: [], options: [])
//        
//        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
//        
//        content.categoryIdentifier = categoryIdentifier
//        
//        let calendar = Calendar.current
//        let dateComponents = calendar.dateComponents([.hour, .minute], from: time)
//        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//        
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//        
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Failed to schedule notification: \(error.localizedDescription)")
//            } else {
//                print("Notification scheduled for \(time)")
//            }
//        }
//    }
//
//    
//    func registerNotificationCategory() {
//        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
//        let stopAction = UNNotificationAction(identifier: "Stop", title: "Stop", options: [])
//        
//        let alarmCategory = UNNotificationCategory(identifier: "alarmCategory", actions: [snoozeAction, stopAction], intentIdentifiers: [], options: [])
//        
//        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
//    }
//    
//    func startAlarmCounting(for index: Int) {
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//               guard let triggeredAt = self.alarms[index].triggeredAt else {
//                   timer.invalidate()
//                   return
//               }
//               let elapsedTime = Date().timeIntervalSince(triggeredAt)
//               print("Elapsed Time: \(elapsedTime) seconds")
//           }
//    }
//}
//
//struct AlarmInputView: View {
//    @State private var alarmTime = Date()
//    var addAlarm: (Date) -> Void
//    
//    var body: some View {
//        VStack {
//            DatePicker("Select Alarm Time", selection: $alarmTime, displayedComponents: .hourAndMinute)
//                .datePickerStyle(WheelDatePickerStyle())
//            
//            Button("Set Alarm") {
//                addAlarm(alarmTime)
//            }
//        }
//        .padding()
//    }
//}
//
//struct Alarm {
//    var time: Date
//    var triggeredAt: Date?
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
////////////////////////////////////////////////////////
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
    
//    func alarmTimeString(alarm: Date, runningElapsedTime: TimeInterval) -> String {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        let timeString = formatter.string(from: alarm)
//        
//        let milliseconds = Int(runningElapsedTime * 1000) % 1000
//        let seconds = Int(runningElapsedTime) % 60
//        let minutes = Int(runningElapsedTime) / 60
//        
//        return "\(timeString) - Elapsed Time: \(minutes) min \(seconds) sec \(milliseconds) ms"
//    }
    
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

//struct AlarmInputView: View {
//    @State private var alarmTime = Date()
//    var addAlarm: (Date) -> Void
//    
//    var body: some View {
//        VStack {
//            DatePicker("Select Alarm Time", selection: $alarmTime, displayedComponents: .hourAndMinute)
//                .datePickerStyle(WheelDatePickerStyle())
//            
//            Button("Set Alarm") {
//                addAlarm(alarmTime)
//            }
//        }
//        .padding()
//    }
//}

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
    
//    func startAlarmCounting(for index: Int) {
//        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//            guard let triggeredAt = self.alarms[index].triggeredAt else {
//                timer.invalidate()
//                return
//            }
//            let elapsedTime = Date().timeIntervalSince(triggeredAt)
//            // Update running elapsed time in the corresponding alarm
//            self.alarms[index].runningElapsedTime = elapsedTime
//        }
//        timers.append(timer) // Store reference to the timer
//    }
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


