import SwiftUI

struct TimerGestureModifier: ViewModifier {
    let onTap: () -> Void
    let onDoubleTap: () -> Void
    let onLongPress: () -> Void
    
    @State private var tapCount = 0
    @State private var lastTapTime = Date()
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                handleTap()
            }
            .onLongPressGesture(minimumDuration: 1.0) {
                tapCount = 0
                onLongPress()
            }
    }
    
    private func handleTap() {
        let now = Date()
        let timeSinceLastTap = now.timeIntervalSince(lastTapTime)
        
        if timeSinceLastTap < 0.3 {
            tapCount += 1
        } else {
            tapCount = 1
        }
        
        lastTapTime = now
        
        if tapCount == 2 {
            onDoubleTap()
            tapCount = 0
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if tapCount == 1 && now.timeIntervalSince(lastTapTime) >= 0.3 {
                    onTap()
                    tapCount = 0
                }
            }
        }
    }
}