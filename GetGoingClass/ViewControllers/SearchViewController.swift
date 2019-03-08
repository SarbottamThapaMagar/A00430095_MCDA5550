//
//  SearchViewController.swift
//  GetGoingClass
//
//  Created by Alla Bondarenko on 2019-01-16.
//  Copyright © 2019 SMU. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var presentFilters: UIButton!
    
    // MARK: - Properties
    var searchParameter: String?
    var currentLocation: CLLocationCoordinate2D?
    var defaultValue: Bool = true
    var radiusFilterValue: Double?
    var rankBy: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = true
        searchTextField.delegate = self
        
       // presentFilters.setNeedsDisplay()
        print("value before boolean \(defaultValue) methods call from overload.....")

        self.loadFilterSavedData()
        self.filterChanged()
        print("........value after boolean \(defaultValue) methods call from overload")
        
    }

    //MARK: - Activity Indicator

    func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        searchButton.isEnabled = false
    }

    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        searchButton.isEnabled = true
    }

//saving data to UserDefaults
    func loadFilterSavedData(){
        let preferences = UserDefaults.standard
        if preferences.string(forKey: "rankby") != nil {
            let rankby = preferences.string(forKey: "rankby")
            let defaultVal = preferences.bool(forKey: "defaultValue")
            rankBy = rankby
            defaultValue = defaultVal
            print("rankby value from shred preference = \(rankby!)")
        }
    }
    
    func filterChanged(){
        
        if defaultValue {
        
            let filterBtn = #imageLiteral(resourceName: "filtersDefault")
            presentFilters.setImage(filterBtn, for: .normal)
//            presentFilters.becomeFirstResponder()
          // presentFilters.reload
            radiusFilterValue = 1000.0 // default radius set to 1000.0
//            rankBy = "prominence"
        }else {
//            loadFilterSavedData()
            let filterBtn = #imageLiteral(resourceName: "filters")
            presentFilters.setImage(filterBtn, for: .normal)
//            presentFilters.becomeFirstResponder()
//            presentFilters.reloadInputViews()
        }
        
    }
    
    @IBAction func loadLastSavedResults(_ sender: UIButton) {
        guard let places = loadPlacesFromLocalStorage() else {
            presentErrorAlert(message: "No results were previously stored")
            return
        }
        presentSearchResults(places: places)
    }

    @IBAction func presentFilters(_ sender: UIButton) {
//        performSegue(withIdentifier: "FiltersSegue", sender: self)
        guard let filtersViewController = UIStoryboard(name: "Filters", bundle: nil).instantiateViewController(withIdentifier: "FiltersViewController") as? FiltersViewController else { return }
        filtersViewController.delegate = self
        present(filtersViewController, animated: true, completion: nil)
       filterChanged()
    }
    
    @IBAction func segmentedObserver(_ sender: UISegmentedControl) {
        print("segmented control option was changed to \(sender.selectedSegmentIndex)")
        if sender.selectedSegmentIndex == 1 {
            LocationService.shared.startUpdatingLocation()
            LocationService.shared.delegate = self
        }
    }

    @IBAction func searchButtonAction(_ sender: UIButton) {
        print("search button was tapped")
        guard let query = searchTextField.text else {
            print("query is nil")
            return
        }

        searchTextField.resignFirstResponder()
//        presentFilters.resignFirstResponder()

        showActivityIndicator()
        loadFilterSavedData()

        switch segmentControl.selectedSegmentIndex {
        case 0:
            GooglePlacesAPI.requestPlaces(query, radius: radiusFilterValue!) { (status, json) in
               // print(json ?? "")
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                }
                guard let jsonObj = json else { return }
                let results = APIParser.parseNearbySearchResults(jsonObj: jsonObj)

                self.savePlacesToLocalStorage(places: results)

                if results.isEmpty {
                    // TODO: - Present an alert
                    // On the main thread!
                    DispatchQueue.main.async {
                        self.presentErrorAlert(message: "No results")
                    }
                } else {
                    self.presentSearchResults(places: results)
                }
            }
        case 1:
            guard let location = currentLocation else { return }
            //radius should be made dynamic
        
            GooglePlacesAPI.requestPlacesNearby(for: location, rankby: rankBy ?? "prominence",radius: radiusFilterValue!, query) { (status, json) in
             //   print(json ?? "")
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                }
                guard let jsonObj = json else { return }
                let results = APIParser.parseNearbySearchResults(jsonObj: jsonObj)
                self.savePlacesToLocalStorage(places: results)

                if results.isEmpty {
                    // TODO: - Present an alert
                    // On the main thread!
                    DispatchQueue.main.async {
                        self.presentErrorAlert(message: "No results")
                    }
                } else {
                    self.presentSearchResults(places: results)
                }
            }
        default:
            break
        }

    }

    // MARK: - Navigation methods

    func presentSearchResults(places: [PlaceDetails]) {
        guard let searchResultsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsViewController") as? SearchResultsViewController else { return }

        searchResultsViewController.places = places
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(searchResultsViewController, animated: true)
        }
    }

    func presentErrorAlert(title: String = "Error", message: String?) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let okButtonAction = UIAlertAction(title: "Ok",
                                     style: .default,
                                     handler: nil)
        alert.addAction(okButtonAction)
        present(alert, animated: true)
    }

    // MARK: - NSCoding

    func savePlacesToLocalStorage(places: [PlaceDetails]) {
        // save data to the local storage
        NSKeyedArchiver.archiveRootObject(places, toFile: Constants.ArchiveURL.path)
    }

    func loadPlacesFromLocalStorage() -> [PlaceDetails]? {
        // pull data from the local storage
        return NSKeyedUnarchiver.unarchiveObject(withFile: Constants.ArchiveURL.path) as? [PlaceDetails]
    }
}

extension SearchViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchTextField.resignFirstResponder()
            print("textFieldShouldReturn")
            return true
        }
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == searchTextField {
            searchParameter = textField.text
            print(textField.text ?? "")
        }
    }
}

extension SearchViewController: LocationServiceDelegate {
    func didUpdateLocation(location: CLLocation) {
        print("latitude \(location.coordinate.latitude) longitude \(location.coordinate.longitude)")
        currentLocation = location.coordinate
    }
}


extension SearchViewController: FilterViewControllerDelegates {
    func filterStateChange(state: Bool) {
        defaultValue = state
        print("default state: \(state)")
    }
    
    
    func getFilterRadiusValues(radius: Double) {
        radiusFilterValue = radius
        if radius > 0.0 {
        print("radius value is \(radius) from SearchViewController")
        }else {
            print("default value of radius is not changed = \(radius)")
        }
    }
    
    func getFilterOpenByValues(open: Bool) {
        if open {
            print("defualt value of open is not changed = \(open)")

        }else {
            print("open value = \(open) from SearchViewController")

        }
    }
    
    func getFilterRankByValues(rankby: String) {
        
        rankBy = rankby
        if rankby.elementsEqual("Distance"){
            print("rankby value from SearchViewController \(rankby)")
        }else {
            print("default value of rankBy is not changed = \(rankby)")

        }
    }
    
}
