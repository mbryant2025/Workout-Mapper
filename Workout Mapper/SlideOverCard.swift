//
//  SlideOverCard.swift
//  Workout Mapper
//
//  Created by Michael Bryant on 9/23/24.
//

import SwiftUI

struct Handle : View {
    private let handleThickness = 5.0
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: handleThickness / 2.0)
                .frame(width: 40, height: handleThickness)
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color.secondary)
                .padding(10)
            Spacer()
        }
        .frame(height: handleThickness, alignment: .top)
    }
}

struct SlideOverCard<Content: View> : View {
    @GestureState private var dragState = DragState.inactive
    @State var position = 700.0
    private let setpoints: [CGFloat] = [80.0, 400.0, 700.0]
    
    @Environment(\.colorScheme) var colorScheme
    
    var content: () -> Content
    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)
        
        let currentHeight = setpoints.reduce(0) { (current, setpoint) in
            return (position + dragState.translation.height >= setpoint) ? setpoint : current
        }
        
        return Group {
            VStack {
                Handle()
                Spacer()
                self.content()
                    .frame(alignment: .top)
                    .padding(.bottom, currentHeight)
            }
            
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(20.0)
        .shadow(color: colorScheme == .dark ? Color(.sRGBLinear, white: 1, opacity: 0.1) : Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
        .offset(y: self.position + self.dragState.translation.height)
        .animation(self.dragState.isDragging ? nil : .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0))
        .gesture(drag)
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardTopEdgeLocation = self.position + drag.translation.height
        
        var positionAbove: CGFloat?
        var positionBelow: CGFloat?
        
        for i in 0..<setpoints.count {
            if cardTopEdgeLocation <= setpoints[i] {
                if i > 0 {
                    positionAbove = setpoints[i - 1]
                }
                positionBelow = setpoints[i]
                break
            }
        }
        
        if positionBelow == nil && setpoints.count > 0 {
            positionBelow = setpoints.last
        }
        
        if positionAbove == nil && setpoints.count > 0 {
            positionAbove = setpoints.first
        }
        
        let closestPosition: CGFloat
        if let above = positionAbove, let below = positionBelow {
            closestPosition = (cardTopEdgeLocation - above).magnitude < (below - cardTopEdgeLocation).magnitude ? above : below
        } else {
            closestPosition = positionAbove ?? positionBelow ?? 0
        }
        
        if verticalDirection > 0, let below = positionBelow {
            self.position = below
        } else if verticalDirection < 0, let above = positionAbove {
            self.position = above
        } else {
            self.position = closestPosition
        }
    }
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}

#Preview {
    ZStack {
        Color.blue
            .edgesIgnoringSafeArea(.all)
        
        SlideOverCard {
            ScrollView {
            
                ForEach(0..<20, id: \.self) { _ in
                    Text("Some content here")
                        .font(.system(size: 40))
                        .padding(10)
                }
            }
        }
    }
}
