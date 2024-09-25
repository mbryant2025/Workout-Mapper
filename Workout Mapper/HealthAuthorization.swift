//
//  HealthAuthorization.swift
//  Workout Mapper
//
//  Created by Michael Bryant on 9/24/24.
//


import Foundation
import HealthKit


public func requestAuthorization(completion: @escaping (Bool) -> Void) {
    let healthStore = HKHealthStore()
    let readTypes: Set<HKObjectType> = [
        HKObjectType.workoutType(),
        HKSeriesType.workoutRoute()
    ]
    
    healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
        if let error = error {
            print("Error requesting HealthKit authorization: \(error.localizedDescription)")
            completion(false) // Pass `false` if authorization fails
        } else {
            completion(success) // Pass the actual success status
        }
    }
}
