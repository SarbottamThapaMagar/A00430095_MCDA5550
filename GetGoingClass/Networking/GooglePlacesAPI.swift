//
//  GooglePlacesAPI.swift
//  GetGoingClass
//
//  Created by Alla Bondarenko on 2019-01-21.
//  Copyright © 2019 SMU. All rights reserved.
//

import Foundation
import CoreLocation

class GooglePlacesAPI {

    class func requestPlaces(_ query: String, radius: Double, completion: @escaping(_ status: Int, _ json: [String: Any]?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.textPlaceSearch

      
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "key", value: Constants.apiKey)
        ]
        
        if radius > 0.0 {
            urlComponents.queryItems?.append(URLQueryItem(name: "radius", value: "\(Int(radius))"))
        }
        
        if let url = urlComponents.url {
            print("url value from GoogleAPI = \(url)")

            NetworkingLayer.getRequest(with: url, timeoutInterval: 500) { (status, data) in

                if let responseData = data,
                    let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    completion(status, jsonResponse)
                } else {
                    completion(status, nil)
                }
            }
        }
    }

    class func requestPlacesNearby(for coordinate: CLLocationCoordinate2D, rankby: String?, radius: Double, _ query: String?, completion: @escaping(_ status: Int, _ json: [String: Any]?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.nearbySearch

        print("radius vaule from the GooglePlacesAPi \(radius)")
        urlComponents.queryItems = [
            URLQueryItem(name: "location", value: "\(coordinate.latitude),\(coordinate.longitude)"),
            URLQueryItem(name: "key", value: Constants.apiKey)
        ]

        if let keyword = query {
            urlComponents.queryItems?.append(URLQueryItem(name: "keyword", value: keyword))

        }
        
        if rankby == "Distance"  {
            urlComponents.queryItems?.append(URLQueryItem(name:"rankby",value: "distance"))
        }else {
            urlComponents.queryItems?.append(URLQueryItem(name: "radius", value: "\(Int(radius))"))
            urlComponents.queryItems?.append(URLQueryItem(name: "rankby", value: "prominence"))

        }
        

        if let url = urlComponents.url {
            print("url value from GoogleAPI = \(url)")

            NetworkingLayer.getRequest(with: url, timeoutInterval: 500) { (status, data) in

                if let responseData = data,
                    let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    completion(status, jsonResponse)
                } else {
                    completion(status, nil)
                }
            }
        }
    }

    class func requestPlaceDetails(for placeID: String, completion: @escaping(_ status: Int, _ json: [String: Any]?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = Constants.scheme
        urlComponents.host = Constants.host
        urlComponents.path = Constants.placeDetails

        urlComponents.queryItems = [
            URLQueryItem(name: "placeid", value: placeID),
            URLQueryItem(name: "key", value: Constants.apiKey)
        ]

        if let url = urlComponents.url {
            NetworkingLayer.getRequest(with: url, timeoutInterval: 500) { (status, data) in

                if let responseData = data,
                    let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    completion(status, jsonResponse)
                } else {
                    completion(status, nil)
                }
            }
        }
    }
}
