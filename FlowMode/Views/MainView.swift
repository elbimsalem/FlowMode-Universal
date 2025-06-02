//
//  MainView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        #if os(macOS)
        TimerView()
        #else
        TabView {
            TimerView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Timer")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        #endif
    }
}

