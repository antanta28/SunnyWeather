//
//  Dateformatter.swift
//  WeatherApp
//
//  Created by Kirill Fedin on 15.06.2021.
//

import Foundation

struct WeatherDateFormatter {
    static let dateformatter: DateFormatter = {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "EEEE, MMM d"
        return dateformatter
    }()
    
    static let weekdayFormatter: DateFormatter = {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "EEEE"
        return dateformatter
    }()
    
    static let hourFormatter: DateFormatter = {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "ha"
        return dateformatter
    }()
}
