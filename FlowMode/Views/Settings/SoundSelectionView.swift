//
//  SoundSelectionView.swift
//  FlowMode
//
//  Created by Samir Meslem on 30.05.25.
//

import SwiftUI

struct SoundSelectionView: View {
    @Binding var selectedSound: String?
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(SoundService.availableSounds, id: \.name) { sound in
                    HStack {
                        Text(sound.name)
                        Spacer()
                        if selectedSound == sound.name {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                        #if os(macOS)
                        Button("Play") {
                            SoundService.playSound(named: sound.name)
                        }
                        .buttonStyle(.borderless)
                        #endif
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedSound = sound.name
                        #if os(iOS)
                        SoundService.playSound(named: sound.name)
                        #endif
                    }
                }
            }
            .navigationTitle(title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            #if os(macOS)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #endif
        }
    }
}