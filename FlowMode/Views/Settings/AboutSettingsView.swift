//
//  AboutSettingsView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct AboutSettingsView: View {
    @EnvironmentObject var subscriptionService: SubscriptionService
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("About FlowMode")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(themeService.currentTheme.primaryTextColor.color)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("FlowMode is a productivity timer app that implements the Flowmodoro technique.")
                            .foregroundColor(themeService.currentTheme.secondaryTextColor.color)
                        
                        Divider()
                        
                        HStack {
                            Text("Version")
                                .foregroundColor(themeService.currentTheme.primaryTextColor.color)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(themeService.currentTheme.secondaryTextColor.color)
                        }
                        
                        HStack {
                            Text("Build")
                                .foregroundColor(themeService.currentTheme.primaryTextColor.color)
                            Spacer()
                            Text("6")
                                .foregroundColor(themeService.currentTheme.secondaryTextColor.color)
                        }
                        
                        Divider()
                    }
                    .padding(.leading, 8)
                }
                
                Spacer()
            }
            .padding(24)
        }
        .scrollContentBackground(.hidden)
        .themedBackground(themeService.currentTheme)
        .navigationTitle("About")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}