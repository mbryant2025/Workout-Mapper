//
//  Map.swift
//  Workout Mapper
//
//  Created by Michael Bryant on 9/23/24.
//

import SwiftUI
import MapKit
import HealthKit

struct MapView : UIViewRepresentable {
    @Binding var workouts: [(HKWorkout, [HKWorkoutRoute])]
    @State private var selectedPolyline: MKPolyline?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        
        // Enable user interaction for selecting polylines
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleMapTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.removeOverlays(view.overlays)
        
        // Add polylines for each workout route
        for (_, routes) in workouts {
            for route in routes {
                Task {
                    let locations = await getLocationDataForRoute(givenRoute: route)
                    let coordinates = locations.map { $0.coordinate }
                    let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                    view.addOverlay(polyline)
                }
            }
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        // Delegate method to render polylines
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }
            
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.lineWidth = 4.0
            renderer.strokeColor = (polyline == parent.selectedPolyline) ? UIColor.red : UIColor.blue
            
            return renderer
        }
        
        // Handle tap on the map
        @objc func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let mapView = gestureRecognizer.view as! MKMapView
            let touchPoint = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            // Check if a polyline was tapped
            for overlay in mapView.overlays {
                if let polyline = overlay as? MKPolyline {
                    if polyline.contains(coordinate: touchCoordinate) {
                        // Select tapped polyline
                        parent.selectedPolyline = polyline
                        mapView.removeOverlay(polyline)
                        mapView.addOverlay(polyline) // Re-add to refresh with updated color
                        break
                    }
                }
            }
        }
    }
}

// Helper method to check if polyline contains a coordinate
extension MKPolyline {
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        let polylinePath = CGMutablePath()
        var firstPoint = true
        
        for i in 0..<pointCount {
            var coordinate = self.points()[i].coordinate
            
            if firstPoint {
                polylinePath.move(to: CGPoint(x: coordinate.latitude, y: coordinate.longitude))
                firstPoint = false
            } else {
                polylinePath.addLine(to: CGPoint(x: coordinate.latitude, y: coordinate.longitude))
            }
        }
        
        let tapPoint = CGPoint(x: coordinate.latitude, y: coordinate.longitude)
        return polylinePath.contains(tapPoint, using: .winding, transform: .identity)
    }
}
