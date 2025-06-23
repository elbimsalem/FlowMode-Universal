import SwiftUI

struct ErrorView: View {
    let title: String
    let message: String
    let retry: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let retry = retry {
                Button("Try Again", action: retry)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}