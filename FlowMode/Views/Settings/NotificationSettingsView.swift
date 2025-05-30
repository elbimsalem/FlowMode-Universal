//
//  NotificationSettingsView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Binding var notifyMaxWorkTime: Bool
    @Binding var notifyPauseComplete: Bool
    
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    var body: some View {
        Group {
            if authorizationStatus == .denied {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notifications Disabled")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text("Please enable notifications in System Settings to receive timer alerts.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            
            Toggle("Max Work Time Alert", isOn: $notifyMaxWorkTime)
                .disabled(authorizationStatus == .denied)
            
            Toggle("Break Complete Alert", isOn: $notifyPauseComplete)
                .disabled(authorizationStatus == .denied)
        }
        .onAppear {
            checkAuthorizationStatus()
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                authorizationStatus = settings.authorizationStatus
            }
        }
    }
}