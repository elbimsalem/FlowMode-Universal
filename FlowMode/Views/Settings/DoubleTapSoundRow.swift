import SwiftUI
#if os(macOS)
import AppKit
#endif

struct DoubleTapSoundRow: View {
    @Binding var selectedSound: String?
    
    private let macOSSounds = [
        ("None", nil),
        ("Morse", "Morse"),
        ("Glass", "Glass"),
        ("Ping", "Ping"),
        ("Pop", "Pop"),
        ("Purr", "Purr"),
        ("Submarine", "Submarine"),
        ("Tink", "Tink")
    ]
    
    var body: some View {
        HStack {
            Text("Double-tap Feedback Sound")
                .foregroundColor(.primary)
            
            Spacer()
            
            Picker("Sound", selection: $selectedSound) {
                ForEach(macOSSounds, id: \.1) { sound in
                    Text(sound.0).tag(sound.1)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: 120)
        }
        .onChange(of: selectedSound) { oldValue, newValue in
            // Test the selected sound
            #if os(macOS)
            if let soundName = newValue {
                NSSound(named: soundName)?.play()
            }
            #endif
        }
    }
}