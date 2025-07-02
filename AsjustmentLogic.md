import SwiftUI

struct ValueAdjuster: View {
    @State private var value: Double = 50
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    @State private var accumulatedChange: Double = 0
    @State private var lastDragValue: CGFloat = 0
    @State private var displayValue: Double = 50
    
    // Configuration
    let minValue: Double = 10
    let maxValue: Double = 300
    let snapIncrement: Double = 5
    let sensitivity: Double = 0.5 // Adjust for more/less sensitive dragging
    
    var body: some View {
        VStack(spacing: 40) {
            // Visual representation
            ZStack {
                // Background track
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 40)
                
                // Fill track
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * CGFloat((displayValue - minValue) / (maxValue - minValue)))
                        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: displayValue)
                }
                .frame(height: 40)
            }
            .frame(maxWidth: 300)
            
            // Value display with gesture
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDragging ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 200, height: 80)
                    .scaleEffect(isDragging ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
                
                // Value text
                VStack(spacing: 4) {
                    Text("\(Int(displayValue))")
                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                        .foregroundColor(isDragging ? .blue : .primary)
                    
                    if isDragging {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.left")
                                .font(.caption)
                                .opacity(dragOffset < 0 ? 1 : 0.3)
                            Text("drag to adjust")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .opacity(dragOffset > 0 ? 1 : 0.3)
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
                
                // Drag indicator overlay
                if isDragging {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: 200, height: 80)
                        .scaleEffect(1.05)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if !isDragging {
                            isDragging = true
                            lastDragValue = gesture.translation.width
                            #if os(iOS)
                            // Haptic feedback on iOS
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.prepare()
                            impactFeedback.impactOccurred()
                            #endif
                        }
                        
                        // Calculate change based on drag delta
                        let delta = gesture.translation.width - lastDragValue
                        dragOffset = gesture.translation.width
                        
                        // Accumulate the change with sensitivity
                        accumulatedChange += Double(delta) * sensitivity
                        
                        // Apply accumulated change when it exceeds the snap increment
                        if abs(accumulatedChange) >= snapIncrement {
                            let increments = Int(accumulatedChange / snapIncrement)
                            let change = Double(increments) * snapIncrement
                            
                            // Update value with bounds checking
                            let newValue = min(max(value + change, minValue), maxValue)
                            
                            // Haptic feedback for value changes on iOS
                            if newValue != value {
                                #if os(iOS)
                                let selectionFeedback = UISelectionFeedbackGenerator()
                                selectionFeedback.prepare()
                                selectionFeedback.selectionChanged()
                                #endif
                            }
                            
                            value = newValue
                            displayValue = newValue
                            
                            // Reset accumulated change
                            accumulatedChange -= change
                        }
                        
                        lastDragValue = gesture.translation.width
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isDragging = false
                            dragOffset = 0
                        }
                        accumulatedChange = 0
                        lastDragValue = 0
                        
                        #if os(iOS)
                        // Final haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.prepare()
                        impactFeedback.impactOccurred()
                        #endif
                    }
            )
            
            // Additional controls
            HStack(spacing: 30) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        value = max(value - snapIncrement, minValue)
                        displayValue = value
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(ScaleButtonStyle())
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        value = minValue
                        displayValue = value
                    }
                }) {
                    Text("Reset")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        value = min(value + snapIncrement, maxValue)
                        displayValue = value
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            // Info text
            Text("Hold and drag left or right to adjust the value")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// Custom button style for better interaction
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Enhanced version with visual drag indicator
struct EnhancedValueAdjuster: View {
    @State private var value: Double = 50
    @State private var isDragging = false
    @State private var dragLocation: CGPoint = .zero
    @State private var startLocation: CGPoint = .zero
    @State private var accumulatedChange: Double = 0
    @State private var displayValue: Double = 50
    
    let minValue: Double = 10
    let maxValue: Double = 300
    let snapIncrement: Double = 5
    let sensitivity: Double = 0.3
    
    var body: some View {
        VStack(spacing: 50) {
            Text("Enhanced Value Adjuster")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Circular value display
            ZStack {
                // Background circle
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 180, height: 180)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: CGFloat((displayValue - minValue) / (maxValue - minValue)))
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: displayValue)
                
                // Value display
                VStack {
                    Text("\(Int(displayValue))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Range: \(Int(minValue))-\(Int(maxValue))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Drag indicator line
                if isDragging {
                    GeometryReader { geometry in
                        Path { path in
                            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            path.move(to: center)
                            
                            let angle = atan2(dragLocation.y - center.y, dragLocation.x - center.x)
                            let endX = center.x + cos(angle) * 70
                            let endY = center.y + sin(angle) * 70
                            
                            path.addLine(to: CGPoint(x: endX, y: endY))
                        }
                        .stroke(Color.blue, lineWidth: 2)
                        .opacity(0.6)
                    }
                    .frame(width: 180, height: 180)
                }
            }
            .scaleEffect(isDragging ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if !isDragging {
                            isDragging = true
                            startLocation = gesture.location
                            #if os(iOS)
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            #endif
                        }
                        
                        dragLocation = gesture.location
                        
                        // Calculate horizontal movement
                        let horizontalDelta = gesture.location.x - startLocation.x
                        
                        // Update value based on horizontal movement
                        let change = Double(horizontalDelta) * sensitivity
                        let newRawValue = value + change
                        
                        // Snap to increment
                        let snappedValue = round(newRawValue / snapIncrement) * snapIncrement
                        let clampedValue = min(max(snappedValue, minValue), maxValue)
                        
                        if clampedValue != displayValue {
                            displayValue = clampedValue
                            #if os(iOS)
                            let selectionFeedback = UISelectionFeedbackGenerator()
                            selectionFeedback.selectionChanged()
                            #endif
                        }
                    }
                    .onEnded { _ in
                        value = displayValue
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isDragging = false
                        }
                        #if os(iOS)
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        #endif
                    }
            )
            
            Text("Hold and drag horizontally to adjust")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// Demo view
struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 60) {
                ValueAdjuster()
                    .padding(.top, 40)
                
                Divider()
                
                EnhancedValueAdjuster()
                    .padding(.bottom, 40)
            }
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}