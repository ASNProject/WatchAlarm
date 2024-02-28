//
//  ContentView.swift
//  ChronoAlert Watch App
//
//  Created by Arief Setyo Nugroho on 16/02/24.
//

import SwiftUI
import AVFoundation
import WatchKit

struct Alarm: Identifiable {
    var hour: Int
    var minute: Int
    var second: Int
    var id = UUID()
}

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var showingAlarmSheet = false
    @State private var alarms: [Alarm] = []
    @State private var showAlert = false
    @State private var alertShow = false
    @State private var alertMessage = ""
    @State private var startTime: Date?
    @State private var countingResult: [TimeInterval] = []
    
    @State private var showCountingResults = false
    
    // Set audio
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlayingAudio = false
    
    //vibration
    let haptic = WKHapticType.notification
    
    
    var body: some View {
        VStack(spacing: 0) {
            Text(getCurrentTime())
                .font(.largeTitle)
                .padding()
            
            Spacer()
            
            Text("Hello, world!")
            
            Spacer()
            
            HStack {
                Button(action: {
                    showingAlarmSheet = true
                }) {
                    Text("Set Alarm")
                        .font(.custom("Arial", size: 10))
                        .padding()
                        .foregroundColor(.primary)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .frame(width: 100)
                .sheet(isPresented: $showingAlarmSheet){
                    alarmInputView(setAlarm: addAlarm, alarms: $alarms, countingResults: $countingResult)
                }
                
                
                Button(action: {
                    showCountingResults = true
                }) {
                    Text("Get Data")
                        .font(.custom("Arial", size: 10))
                        .padding()
                        .foregroundColor(.primary)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .frame(width: 100)
                .sheet(isPresented: $showCountingResults){
                    CountingResultsView(countingResults: countingResult)
                }
            }
            ///Line Terakhir
        }
        .padding(.top, 16)
        .buttonStyle(BorderlessButtonStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            self.currentTime = Date()
            self.checkAlarm()
        }
        .alert(isPresented: $showAlert){
//            self.addHaptic()
            self.playAudio()
            return Alert(title: Text("Alarm!"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                if let startTime = startTime {
                    let endTime = Date()
                    let timeDifference = endTime.timeIntervalSince(startTime)
                    countingResult.append(timeDifference)
                    //Stop Audio
                    self.stopAudio()
                    // Reset start time
                    self.startTime = nil
                }
                showAlert = false
            })
        }
        // Play audio
        .onAppear {
            self.playAudio()
            self.addHaptic()
        }

    }
    
    func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: currentTime)
    }
    
    func addAlarm(hour: Int, minute: Int, second: Int) {
        let newAlarm = Alarm(hour: hour, minute: minute, second: second)
        alarms.append(newAlarm)
    }
    
    /// Check Alarm Visual
    func checkAlarm() {
        for alarm in alarms {
            let calendar = Calendar.current
            let currentHour = calendar.component(.hour, from: currentTime)
            let currentMinute = calendar.component(.minute, from: currentTime)
            let currentSecond = calendar.component(.second, from: currentTime)
            
            if currentHour == alarm.hour && currentMinute == alarm.minute && currentSecond == alarm.second {
                showAlert = true
                alertMessage = "Alarm \(alarm.hour):\(alarm.minute):\(alarm.second) telah tercapai!"
                startTime = Date()
            }
        }
        
        if let startTime = startTime, showAlert == false {
            let endTime = Date()
            let calendar = Calendar.current
            let secondsDifference = calendar.dateComponents([.second], from: startTime, to: endTime).second ?? 0

            if countingResult.isEmpty || countingResult.last != 0 {
                countingResult.append(0)
            }

            countingResult[countingResult.count - 1] += Double(secondsDifference)

            self.startTime = nil
        }
    }
    
    func playAudio() {
        guard let soundURL = Bundle.main.url(forResource: "tone", withExtension: "wav", subdirectory: "Sounds") else {
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    func stopAudio() {
        audioPlayer?.stop()
    }
    
    func addHaptic(){
        WKInterfaceDevice().play(haptic)
    }

}



struct alarmInputView: View {
    var setAlarm: (Int, Int, Int) -> Void
    @State private var alarmHour = 0
    @State private var alarmMinute = 0
    @State private var alarmSecond = 0
    @State private var secondText = "01"
    @Binding var alarms: [Alarm]
    @State private var showAlarmList = false
    @Binding var countingResults: [TimeInterval]

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Set Alarm")
                    .font(.custom("Arial", size: 14))
                    .padding()
                
                Picker(selection: $alarmHour, label: Text("Hour")){
                    ForEach(0..<24) { hour in
                        Text("\(hour)")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
                .frame(width: 100, height: 20)
                
                Picker(selection: $alarmMinute, label: Text("Minute")) {
                    ForEach(0..<60) { minute in
                        Text("\(minute)")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .labelsHidden()
                .frame(width: 100, height: 20)
                
                Button(action: {
                    setAlarm(alarmHour, alarmMinute, alarmSecond)
                }) {
                    Text("Save")
                        .font(.custom("Arial", size: 12))
                        .padding()
                        .foregroundColor(.primary)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .frame(width: .infinity)
                Button(action: {
                    showAlarmList = true
                }) {
                    Text("List alarm")
                        .font(.custom("Arial", size: 12))
                        .padding()
                        .foregroundColor(.primary)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .frame(width: .infinity)
                .sheet(isPresented: $showAlarmList){
                    AlarmListView(alarms: $alarms)
                }
                Button(action: {
                    self.alarms = []
                    self.countingResults = []
                }) {
                    Text("Reset")
                        .font(.custom("Arial", size: 12))
                        .padding()
                        .foregroundColor(.primary)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .frame(width: .infinity)
                .padding(.top, 20)
            }
        }
        .padding()
        .buttonStyle(BorderlessButtonStyle())
    }
    
}

struct AlarmListView: View {
    @Binding var alarms: [Alarm]

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(alarms.enumerated()), id: \.element.id) { index, alarm in
                    Text("Alarm \(index + 1): \(alarm.hour):\(alarm.minute):\(alarm.second)")
                }
            }
            .navigationTitle("Alarm List")
            .font(.custom("Arial", size: 12))
        }
    }
}




struct CountingResultsView: View {
    var countingResults: [TimeInterval]

    var body: some View {
        List {
            ForEach(countingResults.indices, id: \.self) { index in
                Text("Alarm \(index + 1): \(Int(countingResults[index] * 1000)) ms")
            }
        }
        .navigationTitle("Results")
        .font(.custom("Arial", size: 12))
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
