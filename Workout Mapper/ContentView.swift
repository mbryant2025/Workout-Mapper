//
//  ContentView.swift
//  Workout Mapper
//
//  Created by Michael Bryant on 9/23/24.
//

import SwiftUI
import HealthKit

struct ContentView : View {
    
    @State private var isAuthorized = false
    @State private var workouts: [(HKWorkout, [HKWorkoutRoute])] = []
    @State private var isLoading = true
    @State private var showSettings = false
    @State private var selectedSortParameter: SortParameter = .distance
    
    func authorizeUser() {
        requestAuthorization { success in
            if success {
                isAuthorized = true
                // Get the workouts (async)
                Task {
                    if let fetchedWorkouts = await getWorkoutsWithRoutes() {
                        workouts = fetchedWorkouts
                        isLoading = false
                    }
                }
            }
        }
    }
    
    var body: some View {
        Group {
            if isAuthorized {
                ZStack(alignment: .top) {
                    MapView(workouts: $workouts)
                    SlideOverCard {
                        VStack {
                            WorkoutsList(workouts: $workouts, showSettings: $showSettings, selectedSortParameter: $selectedSortParameter)
                        }
                        
                    }
                    if isLoading {
                        Loading()
                    }
                    if showSettings {
                        SettingsView(isPresented: $showSettings)
                    }
                }
                .edgesIgnoringSafeArea(.vertical)
            } else {
                // User is not authorized, show authorization tutorial
                AuthorizationTutorial(authorizeUser: authorizeUser)
                            
            }
        }
        .onAppear(perform: authorizeUser)
    }
}

enum SortParameter: String, CaseIterable {
    case date = "Date"
    case distance = "Distance"
    case time = "Time"
}


#Preview {
    ContentView()
}
