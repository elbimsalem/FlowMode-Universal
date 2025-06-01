//
//  SoundService.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import Foundation
import AudioToolbox
#if os(macOS)
import AppKit
#elseif os(iOS)
import AVFoundation
import UIKit
#endif

struct SystemSound {
    let id: SystemSoundID
    let name: String
}

class SoundService {
    #if os(iOS)
    private static var audioPlayer: AVAudioPlayer?
    private static var isPlayingContinuous = false
    #endif
    
    #if os(iOS)
    private static func validateContinuousSoundExists(_ soundName: String) -> Bool {
        let soundMapping: [String: String] = [
            // Call tones
            "Reflection": "Reflection",
            "Slow Rise": "Slow Rise", 
            "Suspense": "Suspense",
            "Presto": "Presto",
            "Radar": "Radar",
            "Hillside": "Hillside",
            "Vintage": "Vintage",
            "Uplift": "Uplift",
            "By The Seaside": "By The Seaside",
            "Bulletin": "Bulletin",
            // Ringtones
            "Marimba": "Marimba",
            "Alarm": "Alarm",
            "Ascending": "Ascending",
            "Bark": "Bark",
            "Bell Tower": "Bell Tower",
            "Blues": "Blues",
            "Boing": "Boing",
            "Crickets": "Crickets",
            "Digital": "Digital",
            "Dog": "Dog",
            "Duck": "Duck",
            "Electronic": "Electronic",
            "Happy": "Happy",
            "Harp": "Harp",
            "Old Car Horn": "Old Car Horn",
            "Old Phone": "Old Phone",
            "Organ": "Organ",
            "Piano Riff": "Piano Riff",
            "Pop": "Pop",
            "Robot": "Robot",
            "Sci-Fi": "Sci-Fi",
            "Strum": "Strum",
            "Timba": "Timba",
            "Trill": "Trill",
            "Xylophone": "Xylophone",
            "Opening": "Opening",
            "Apex": "Apex",
            "Beacon": "Beacon",
            "Chimes": "Chimes",
            "Circuit": "Circuit",
            "Constellation": "Constellation",
            "Cosmic": "Cosmic"
        ]
        
        guard let systemSoundName = soundMapping[soundName] else { return false }
        return Bundle.main.url(forResource: systemSoundName, withExtension: "caf") != nil ||
               Bundle.main.url(forResource: systemSoundName, withExtension: "m4a") != nil
    }
    #endif
    
    static var availableSounds: [SystemSound] {
        let allSounds: [SystemSound] = {
            #if targetEnvironment(macCatalyst) || os(macOS)
            // macOS sounds
            return [
                SystemSound(id: 1000, name: "Basso"),
                SystemSound(id: 1001, name: "Blow"),
                SystemSound(id: 1002, name: "Bottle"),
                SystemSound(id: 1003, name: "Frog"),
                SystemSound(id: 1004, name: "Funk"),
                SystemSound(id: 1005, name: "Glass"),
                SystemSound(id: 1006, name: "Hero"),
                SystemSound(id: 1007, name: "Morse"),
                SystemSound(id: 1008, name: "Ping"),
                SystemSound(id: 1009, name: "Pop"),
                SystemSound(id: 1010, name: "Purr"),
                SystemSound(id: 1011, name: "Sosumi"),
                SystemSound(id: 1012, name: "Submarine"),
                SystemSound(id: 1013, name: "Tink")
            ]
            #elseif os(iOS)
            // iOS sounds - call tones first, then ringtones, then regular sounds
            return [
                // Call tones (continuous)
                SystemSound(id: 1020, name: "Reflection"),
                SystemSound(id: 1021, name: "Slow Rise"),
                SystemSound(id: 1022, name: "Suspense"),
                SystemSound(id: 1023, name: "By The Seaside"),
                SystemSound(id: 1024, name: "Bulletin"),
                SystemSound(id: 1025, name: "Presto"),
                SystemSound(id: 1026, name: "Radar"),
                SystemSound(id: 1027, name: "Hillside"),
                SystemSound(id: 1028, name: "Vintage"),
                SystemSound(id: 1029, name: "Uplift"),
                // Ringtones (continuous)
                SystemSound(id: 1030, name: "Marimba"),
                SystemSound(id: 1031, name: "Alarm"),
                SystemSound(id: 1032, name: "Ascending"),
                SystemSound(id: 1033, name: "Bark"),
                SystemSound(id: 1034, name: "Bell Tower"),
                SystemSound(id: 1035, name: "Blues"),
                SystemSound(id: 1036, name: "Boing"),
                SystemSound(id: 1037, name: "Crickets"),
                SystemSound(id: 1038, name: "Digital"),
                SystemSound(id: 1039, name: "Dog"),
                SystemSound(id: 1040, name: "Duck"),
                SystemSound(id: 1041, name: "Electronic"),
                SystemSound(id: 1042, name: "Happy"),
                SystemSound(id: 1043, name: "Harp"),
                SystemSound(id: 1045, name: "Old Car Horn"),
                SystemSound(id: 1046, name: "Old Phone"),
                SystemSound(id: 1047, name: "Organ"),
                SystemSound(id: 1048, name: "Piano Riff"),
                SystemSound(id: 1049, name: "Pop"),
                SystemSound(id: 1050, name: "Robot"),
                SystemSound(id: 1051, name: "Sci-Fi"),
                SystemSound(id: 1052, name: "Strum"),
                SystemSound(id: 1053, name: "Timba"),
                SystemSound(id: 1054, name: "Trill"),
                SystemSound(id: 1055, name: "Xylophone"),
                SystemSound(id: 1011, name: "Opening"),
                SystemSound(id: 1012, name: "Apex"),
                SystemSound(id: 1013, name: "Beacon"),
                SystemSound(id: 1014, name: "Chimes"),
                SystemSound(id: 1015, name: "Circuit"),
                SystemSound(id: 1016, name: "Constellation"),
                SystemSound(id: 1017, name: "Cosmic"),
                // Regular notification sounds (single play)
                SystemSound(id: 1000, name: "Notification"),
                SystemSound(id: 1001, name: "Text Tone"),
                SystemSound(id: 1002, name: "New Mail"),
                SystemSound(id: 1003, name: "Mail Sent"),
                SystemSound(id: 1004, name: "Voicemail"),
                SystemSound(id: 1005, name: "Received Message"),
                SystemSound(id: 1006, name: "Sent Message"),
                SystemSound(id: 1008, name: "Low Power"),
                SystemSound(id: 1009, name: "SMS Received 1"),
                SystemSound(id: 1010, name: "SMS Received 2")
            ]
            #else
            // Fallback
            return [
                SystemSound(id: 1000, name: "Default")
            ]
            #endif
        }()
        
        return allSounds
    }
    
    static func playSound(named soundName: String, continuous: Bool = false) {
        guard let sound = availableSounds.first(where: { $0.name == soundName }) else { return }
        
        #if os(macOS)
        if let nsSound = NSSound(named: soundName) {
            nsSound.play()
        } else {
            // Fallback to system beep if named sound not found
            NSSound.beep()
        }
        #elseif os(iOS)
        // Check if this is a continuous sound (call tones or ringtones)
        let continuousSounds = ["Reflection", "Slow Rise", "Suspense", "By The Seaside", "Bulletin", 
                               "Presto", "Radar", "Hillside", "Vintage", "Uplift", "Marimba", "Alarm",
                               "Ascending", "Bark", "Bell Tower", "Blues", "Boing", "Crickets", "Digital",
                               "Dog", "Duck", "Electronic", "Happy", "Harp", "Old Car Horn", "Old Phone",
                               "Organ", "Piano Riff", "Pop", "Robot", "Sci-Fi", "Strum", "Timba", "Trill",
                               "Xylophone", "Opening", "Apex", "Beacon", "Chimes", "Circuit", "Constellation", "Cosmic"]
        
        if continuous && continuousSounds.contains(soundName) {
            playRingtoneContinuous(named: soundName)
        } else {
            AudioServicesPlaySystemSound(sound.id)
        }
        #endif
    }
    
    #if os(iOS)
    private static func playRingtoneContinuous(named soundName: String) {
        // Validate continuous sound exists before proceeding
        guard validateContinuousSoundExists(soundName) else {
            print("⚠️ Continuous sound file not found: \(soundName)")
            // Fallback to system alarm sound
            AudioServicesPlaySystemSound(1007)
            return
        }
        
        // Stop any currently playing sound
        stopContinuousSound()
        
        // Map sound names to system sound files
        let soundMapping: [String: String] = [
            // Call tones
            "Reflection": "Reflection",
            "Slow Rise": "Slow Rise", 
            "Suspense": "Suspense",
            "Presto": "Presto",
            "Radar": "Radar",
            "Hillside": "Hillside",
            "Vintage": "Vintage",
            "Uplift": "Uplift",
            "By The Seaside": "By The Seaside",
            "Bulletin": "Bulletin",
            // Ringtones
            "Marimba": "Marimba",
            "Alarm": "Alarm",
            "Ascending": "Ascending",
            "Bark": "Bark",
            "Bell Tower": "Bell Tower",
            "Blues": "Blues",
            "Boing": "Boing",
            "Crickets": "Crickets",
            "Digital": "Digital",
            "Dog": "Dog",
            "Duck": "Duck",
            "Electronic": "Electronic",
            "Happy": "Happy",
            "Harp": "Harp",
            "Old Car Horn": "Old Car Horn",
            "Old Phone": "Old Phone",
            "Organ": "Organ",
            "Piano Riff": "Piano Riff",
            "Pop": "Pop",
            "Robot": "Robot",
            "Sci-Fi": "Sci-Fi",
            "Strum": "Strum",
            "Timba": "Timba",
            "Trill": "Trill",
            "Xylophone": "Xylophone",
            "Opening": "Opening",
            "Apex": "Apex",
            "Beacon": "Beacon",
            "Chimes": "Chimes",
            "Circuit": "Circuit",
            "Constellation": "Constellation",
            "Cosmic": "Cosmic"
        ]
        
        if let systemSoundName = soundMapping[soundName],
           let soundURL = Bundle.main.url(forResource: systemSoundName, withExtension: "caf") ?? 
                          Bundle.main.url(forResource: systemSoundName, withExtension: "m4a") {
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.play()
                isPlayingContinuous = true
            } catch {
                print("⚠️ Failed to play sound \(soundName): \(error)")
                // Fallback to system sound if AVAudioPlayer fails
                AudioServicesPlaySystemSound(1007) // Alarm sound
            }
        } else {
            // Fallback to system alarm sound
            AudioServicesPlaySystemSound(1007)
        }
    }
    
    static func stopContinuousSound() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlayingContinuous = false
    }
    
    static var isPlayingContinuousSound: Bool {
        return isPlayingContinuous
    }
    #endif
    
    static func playSound(id: SystemSoundID) {
        #if os(macOS)
        NSSound.beep()
        #else
        AudioServicesPlaySystemSound(id)
        #endif
    }
}