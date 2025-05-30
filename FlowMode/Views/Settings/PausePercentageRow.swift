//
//  PausePercentageRow.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct PausePercentageRow: View {
    @Binding var selectedPercentage: Int
    
    private let percentageOptions = [5, 10, 15, 20, 25]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Break Duration")
                .font(.headline)
            
            Picker("Percentage", selection: $selectedPercentage) {
                ForEach(percentageOptions, id: \.self) { percentage in
                    Text("\(percentage)%").tag(percentage)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            #if os(macOS)
            .frame(maxWidth: .infinity, alignment: .leading)
            #else
            .frame(maxWidth: 200)
            #endif
        }
    }
}