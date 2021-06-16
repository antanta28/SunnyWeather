//
//  WeatherLocation.swift
//  WeatherApp
//
//  Created by Kirill Fedin on 21.05.2021.
//

import Foundation

class WeatherLocation: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
