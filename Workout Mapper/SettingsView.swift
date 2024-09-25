import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    
    @State private var selectedUnits: Int = UnitManager.shared.unitType == .imperial ? 0 : 1
    @State private var tempShowWalking = false
    @State private var tempShowRunning = false
    @State private var tempShowCycling = false

    var body: some View {
        NavigationView {
            Form {
                
            }
            .navigationTitle("Settings") // Title for the settings view
            .navigationBarItems(trailing: Button(action: {
                withAnimation {
                    isPresented = false // Dismiss the settings view
                }
            }) {
                Text("Close") // Close button
                    .foregroundColor(.blue)
            })
        }
        .presentationDetents([.fraction(0.5)]) // Adjust the height of the panel
    }
}

    // Preview for the SettingsView
    struct SettingsView_Previews: PreviewProvider {
        @State static var isPresented = true

        static var previews: some View {
            SettingsView(isPresented: $isPresented)
        }
    }

