//
//  NotificationService.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import Foundation
import UserNotifications

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
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}