//
//  NotificationService.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import Foundation
import UserNotifications
#if os(macOS)
import AppKit
#endif

class NotificationService {
    static let shared = NotificationService()
    
    private init() {
        #if os(iOS)
        // Only auto-request authorization on iOS
        Task {
            await requestAuthorization()
        }
        #endif
    }
    
    func requestAuthorization() async -> Bool {
        do {
            #if os(macOS)
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound]
            )
            #else
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            #endif
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval, identifier: String) {
        #if os(macOS)
        // On macOS, use a simple delayed sound + alert approach to avoid notification center issues
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
            // Play sound
            NSSound.beep()
            
            // Show simple alert (optional - could be removed if too intrusive)
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = body
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            
            // Show alert on main window if available
            if let window = NSApplication.shared.windows.first {
                alert.beginSheetModal(for: window) { _ in }
            } else {
                alert.runModal()
            }
        }
        #else
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        Task {
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("Failed to schedule notification: \(error)")
            }
        }
        #endif
    }
    
    func cancelNotification(identifier: String) {
        #if os(iOS)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        #endif
        // On macOS, we can't cancel DispatchQueue.asyncAfter calls easily
    }
    
    func cancelAllNotifications() {
        #if os(iOS)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        #endif
        // On macOS, we can't cancel DispatchQueue.asyncAfter calls easily
    }
}