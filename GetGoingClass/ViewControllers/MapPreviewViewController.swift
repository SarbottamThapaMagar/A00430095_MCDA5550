//
//  MapPreviewViewController.swift
//  GetGoingClass
//
//  Created by MCDA5550 on 2019-03-04.
//  Copyright © 2019 SMU. All rights reserved.
//

import UIKit
import MapKit

class MapPreviewViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var placesOfInterest: [PlaceDetails]!

    @IBAction func exitButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
  
//        self.title = "Map View"
//        self.navigationController?.navigationBar.prefersLargeTitles = true
//        self.navigationItem.largeTitleDisplayMode = .always
        setMapViewCoordinate()
        

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func setMapViewCoordinate() {
        
        mapView.delegate = self

        for place in placesOfInterest {
            
            guard let coordinate = place.coordinate else { return }
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            centerMapOnLocation(location: coordinate)
            
            // indicates in blue user's current location if available
            mapView.showsUserLocation = true
        }
       
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let radius = 5000
        
        let distance = CLLocationDistance(Double(radius) * 2)
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: distance, longitudinalMeters: distance)
        
        mapView.setRegion(region, animated: true)
    }
    

}

extension MapPreviewViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "reusablePin")
        // allowing to show extra information in the pin view
        view.canShowCallout = true
        // "i" button
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        view.pinTintColor = UIColor.blue
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation
        
        let launchingOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit]
        if let coordinate = location?.coordinate {
            location?.mapItem(coordinate: coordinate).openInMaps(launchOptions: launchingOptions)
        }
    }
    
    
}

//extension MKAnnotation {
//
////    func mapItem(coordinate: CLLocationCoordinate2D) -> MKMapItem {
////        let placemark = MKPlacemark(coordinate: coordinate)
////        return MKMapItem(placemark: placemark)
////}
//
//}
