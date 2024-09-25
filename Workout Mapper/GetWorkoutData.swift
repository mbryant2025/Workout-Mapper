//
//  GetWorkoutData.swift
//  Workout Mapper
//
//  Created by Michael Bryant on 9/24/24.
//


import Foundation
import HealthKit
import MapKit


let store = HKHealthStore()

/// Get workout type string, e.g. "Running"
public func getWorkoutType(for workout: HKWorkout) -> String {
    let workoutType = workout.workoutActivityType
    return workoutTypeMap[Int(workoutType.rawValue)] ?? "Unknown"
}



/// Retrieves all workouts that have an associated route.
///
/// This asynchronous function queries HealthKit for all workouts and checks if each workout has an associated
/// `HKWorkoutRoute`. It returns an optional array of tuples, where each tuple contains a workout and its
/// corresponding routes. If no workouts with routes are found, it returns `nil`.
///
/// - Returns: An optional array of tuples, where each tuple contains a workout (`HKWorkout`) and an array of
///            associated routes (`[HKWorkoutRoute]`).
///
/// - Throws: An error if the HealthKit query fails or if there are issues retrieving the routes.

func getWorkoutsWithRoutes() async -> [(HKWorkout, [HKWorkoutRoute])]? {
    // Fetch all workouts
    let workouts = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKWorkout], Error>) in
        let workoutType = HKObjectType.workoutType()
        
        let query = HKSampleQuery(sampleType: workoutType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { (query, samplesOrNil, errorOrNil) in
            if let error = errorOrNil {
                continuation.resume(throwing: error)
                return
            }
            
            guard let workouts = samplesOrNil as? [HKWorkout] else {
                continuation.resume(returning: [])
                return
            }
            
            continuation.resume(returning: workouts)
        }
        
        store.execute(query)
    }

    // Filter workouts that have a route associated
    var workoutsWithRoutes: [(HKWorkout, [HKWorkoutRoute])] = []

    for workout in workouts {
        let routes = try! await getWorkoutRoute(workout: workout)
        
        if let routes = routes, !routes.isEmpty {
            workoutsWithRoutes.append((workout, routes))
        }
    }
    
    return workoutsWithRoutes.isEmpty ? nil : workoutsWithRoutes
}

/// Retrieves the workout routes associated with a specific workout.
///
/// This asynchronous function queries HealthKit for routes associated with the given workout. It returns an
/// optional array of `HKWorkoutRoute`. If no routes are found or if an error occurs, it handles the situation
/// accordingly and returns `nil`.
///
/// - Parameter workout: The workout (`HKWorkout`) for which to retrieve associated routes.
///
/// - Returns: An optional array of `HKWorkoutRoute` associated with the specified workout.
///
/// - Throws: An error if the HealthKit query fails.
func getWorkoutRoute(workout: HKWorkout) async throws -> [HKWorkoutRoute]? {
    // Create a predicate to filter workout routes by the specific workout
    let byWorkout = HKQuery.predicateForObjects(from: workout)

    // Perform the query for workout routes asynchronously
    let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
        // Execute an anchored object query for workout routes
        let query = HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(),
                                           predicate: byWorkout,
                                           anchor: nil,
                                           limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
            
            // Handle any errors encountered during the query
            if let hasError = error {
                continuation.resume(throwing: hasError)
                return
            }

            // Resume the continuation with the retrieved samples or an empty array if none found
            continuation.resume(returning: samples ?? [])
        }
        
        // Execute the query on the HealthKit store
        store.execute(query)
    }

    // Cast the samples to the expected type of HKWorkoutRoute
    let routes = samples.compactMap { $0 as? HKWorkoutRoute }
    
    // Return nil if no routes were found, otherwise return the array of routes
    return routes.isEmpty ? nil : routes
}

func getLocationDataForRoute(givenRoute: HKWorkoutRoute) async -> [CLLocation] {
    let locations = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CLLocation], Error>) in
        var allLocations: [CLLocation] = []

        // Create the route query.
        let query = HKWorkoutRouteQuery(route: givenRoute) { (query, locationsOrNil, done, errorOrNil) in

            if let error = errorOrNil {
                continuation.resume(throwing: error)
                return
            }

            guard let currentLocationBatch = locationsOrNil else {
                fatalError("*** Invalid State: This can only fail if there was an error. ***")
            }

            allLocations.append(contentsOf: currentLocationBatch)

            if done {
                continuation.resume(returning: allLocations)
            }
        }

        store.execute(query)
    }

    return locations
    
}


public let workoutTypeMap: [Int: String] = [
    1: "American Football",
    2: "Archery",
    3: "Australian Football",
    4: "Badminton",
    5: "Baseball",
    6: "Basketball",
    7: "Bowling",
    8: "Boxing",
    9: "Climbing",
    10: "Cricket",
    11: "Cross Training",
    12: "Curling",
    13: "Cycling",
    14: "Dance",
    15: "Dance Inspired Training",
    16: "Elliptical",
    17: "Equestrian Sports",
    18: "Fencing",
    19: "Fishing",
    20: "Functional Strength Training",
    21: "Golf",
    22: "Gymnastics",
    23: "Handball",
    24: "Hiking",
    25: "Hockey",
    26: "Hunting",
    27: "Lacrosse",
    28: "Martial Arts",
    29: "Mind and Body",
    30: "Mixed Metabolic Cardio Training",
    31: "Paddle Sports",
    32: "Play",
    33: "Preparation and Recovery",
    34: "Racquetball",
    35: "Rowing",
    36: "Rugby",
    37: "Running",
    38: "Sailing",
    39: "Skating Sports",
    40: "Snow Sports",
    41: "Soccer",
    42: "Softball",
    43: "Squash",
    44: "Stair Climbing",
    45: "Surfing Sports",
    46: "Swimming",
    47: "Table Tennis",
    48: "Tennis",
    49: "Track and Field",
    50: "Traditional Strength Training",
    51: "Volleyball",
    52: "Walking",
    53: "Water Fitness",
    54: "Water Polo",
    55: "Water Sports",
    56: "Wrestling",
    57: "Yoga",
    58: "Barre"
]
