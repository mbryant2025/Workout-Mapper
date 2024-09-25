//
//  UnitManager.swift
//  Workout Mapper
//
//  Created by Michael Bryant on 9/24/24.
//

import Foundation

class UnitManager {
    // Singleton pattern for shared instance
    static let shared = UnitManager()

    // Enum to track the unit system (metric or imperial)
    enum UnitType: Int {
        case metric = 0
        case imperial = 1
    }
    
    // Default to imperial system, loaded from UserDefaults
    var unitType: UnitType {
        get {
            if let storedValue = UserDefaults.standard.value(forKey: "unitType") as? Int {
                return UnitType(rawValue: storedValue) ?? .imperial
            }
            return .imperial // Default to imperial if no value is stored
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "unitType")
        }
    }
    
    // MARK: - Conversion Constants
    private let kmToMiles = 0.62137119
    private let milesToKm = 1.609344
    private let metersToKm = 0.001
    private let metersToMiles = 0.00062137119
    
    private init() {}
    
    // MARK: - Length Conversion
    
    /// Converts distance (in meters) based on the active unit system
    func convertKnownMeters(_ meters: Double) -> Double {
        switch unitType {
        case .metric:
            return metersToKilometers(meters)
        case .imperial:
            return metersToMiles(meters)
        }
    }
    
    /// Converts distance (in miles) based on the active unit system
    func convertKnownMiles(_ miles: Double) -> Double {
        switch unitType {
        case .metric:
            return milesToKilometers(miles)
        case .imperial:
            return miles
        }
    }
    
    /// Converts distance (in kilometers) based on the active unit system
    func convertKnownKilometers(_ kilometers: Double) -> Double {
        switch unitType {
        case .metric:
            return kilometers
        case .imperial:
            return kilometersToMiles(kilometers)
        }
    }
    
    /// Converts meters to kilometers
    private func metersToKilometers(_ meters: Double) -> Double {
        return meters * metersToKm
    }
    
    /// Converts meters to miles
    private func metersToMiles(_ meters: Double) -> Double {
        return meters * metersToMiles
    }
    
    /// Converts miles to kilometers
    private func milesToKilometers(_ miles: Double) -> Double {
        return miles * milesToKm
    }
    
    /// Converts kilometers to miles
    private func kilometersToMiles(_ kilometers: Double) -> Double {
        return kilometers * kmToMiles
    }
    
    // MARK: - Temperature Conversion
    
    /// Converts a known Celsius temperature to the appropriate value based on the active unit system
    func convertKnownCelsius(_ celsius: Double) -> Double {
        switch unitType {
        case .metric:
            return celsius // No conversion needed, return as is
        case .imperial:
            return celsiusToFahrenheit(celsius)
        }
    }
    
    /// Converts a known Fahrenheit temperature to the appropriate value based on the active unit system
    func convertKnownFahrenheit(_ fahrenheit: Double) -> Double {
        switch unitType {
        case .metric:
            return fahrenheitToCelsius(fahrenheit)
        case .imperial:
            return fahrenheit // No conversion needed, return as is
        }
    }
    
    /// Converts Fahrenheit to Celsius
    private func fahrenheitToCelsius(_ fahrenheit: Double) -> Double {
        return (fahrenheit - 32) * 5 / 9
    }
    
    /// Converts Celsius to Fahrenheit
    private func celsiusToFahrenheit(_ celsius: Double) -> Double {
        return celsius * 9 / 5 + 32
    }
    
    // MARK: - System-wide Unit Management
    
    /// Toggles the system-wide unit type between metric and imperial
    func toggleUnitType() {
        unitType = (unitType == .metric) ? .imperial : .metric
    }
    
    /// Sets the system-wide unit type to metric
    func toggleMetric() {
        unitType = .metric
    }
    
    /// Sets the system-wide unit type to imperial
    func toggleImperial() {
        unitType = .imperial
    }
    
    /// Gets the current unit type (returns "metric" or "imperial")
    func getCurrentUnitType() -> String {
        switch unitType {
        case .metric:
            return "metric"
        case .imperial:
            return "imperial"
        }
    }
    
    /// Returns if the current unit type is metric
    func isMetric() -> Bool {
        return unitType == .metric
    }
    
    func getDistanceStringShort() -> String {
        switch unitType {
        case .metric:
            return "km"
        case .imperial:
            return "mi"
        }
    }
}

public func formatDuration(from seconds: Double) -> String {
    let totalMinutes = Int(seconds / 60)
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60

    var durationString = ""

    if hours > 0 {
        durationString += "\(hours) hr"
    }
    if minutes > 0 {
        if !durationString.isEmpty {
            durationString += " "
        }
        durationString += "\(minutes) min"
    }

    return durationString.isEmpty ? "0 min" : durationString
}

func formattedDate(for date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    return dateFormatter.string(from: date)
}
