//
//  WorkoutsList.swift
//  Workout Mapper
//
//  Created by Michael Bryant on 9/24/24.
//

import SwiftUI
import HealthKit

struct WorkoutsList: View {
    @Binding var workouts: [(HKWorkout, [HKWorkoutRoute])]
    @Binding var showSettings: Bool
    @Binding var selectedSortParameter: SortParameter

    var body: some View {
        VStack {
            HStack {
                Text("Workouts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gear")
                        .font(.title)
                        .foregroundColor(.primary)
                        .padding(.trailing, 16)
                }
            }
            .padding(10.0)

            NavigationView {
                List(sortedWorkouts, id: \.0) { workoutTuple in
                    let workout = workoutTuple.0

                    VStack(alignment: .leading) {
                        Text(getWorkoutType(for: workout))
                            .font(.headline)

                        // Display the date of the workout
                        Text("Date: \(formattedDate(for: workout.startDate))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if let totalDistance = workout.totalDistance {
                            let distanceInMeters = totalDistance.doubleValue(for: HKUnit.meter())
                            let distance = UnitManager.shared.convertKnownMeters(distanceInMeters)
                            Text("Distance: \(distance, specifier: "%.1f") \(UnitManager.shared.getDistanceStringShort())")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Distance: Not recorded")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Text("Duration: \(formatDuration(from: workout.duration))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.clear)
                }
                .listStyle(PlainListStyle())
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    // MARK: - Computed Property for Sorted Workouts
    private var sortedWorkouts: [(HKWorkout, [HKWorkoutRoute])] {
        switch selectedSortParameter {
        case .date:
            return workouts.sorted { $0.0.startDate > $1.0.startDate } // Newest first
        case .distance:
            return workouts.sorted { ($0.0.totalDistance?.doubleValue(for: HKUnit.meter()) ?? 0) > ($1.0.totalDistance?.doubleValue(for: HKUnit.meter()) ?? 0) } // Farthest first
        case .time:
            return workouts.sorted { $0.0.duration > $1.0.duration } // Longest duration first
        }
    }
}

#Preview {
    // Example preview with dummy data
    let sampleWorkout = HKWorkout(
        activityType: .running,
        start: Date(),
        end: Date().addingTimeInterval(3600),
        workoutEvents: [],
        totalEnergyBurned: HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 500),
        totalDistance: HKQuantity(unit: HKUnit.meter(), doubleValue: 500),
        metadata: [:]
    )

    WorkoutsList(workouts: .constant([(sampleWorkout, []),
                                       (sampleWorkout, []),
                                       (sampleWorkout, []),
                                       (sampleWorkout, []),
                                       (sampleWorkout, []),
                                       (sampleWorkout, []),
                                       (sampleWorkout, []),
                                       (sampleWorkout, []),
                                       (sampleWorkout, []),
                                       (sampleWorkout, []),
                                       (sampleWorkout, [])]),
                 showSettings: .constant(false), selectedSortParameter: .constant(.date))
}
