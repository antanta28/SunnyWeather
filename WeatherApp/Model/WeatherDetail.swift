//
//  WeatherDetail.swift
//  WeatherApp
//
//  Created by Kirill Fedin on 15.06.2021.
//

import Foundation

class WeatherDetail: WeatherLocation {
    // MARK: - Decoding Struct
    private struct Result: Codable {
        var timezone: String
        var current: Current
        var daily: [Daily]
        var hourly: [Hourly]
    }
    
    private struct Current: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    private struct Weather: Codable {
        var description: String
        var icon: String
        var id: Int
    }
    
    
    private struct Daily: Codable {
        var dt: TimeInterval
        var temp: Temp
        var weather: [Weather]
    }
    
    private struct Hourly: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    private struct Temp: Codable {
        var max: Double
        var min: Double
    }
    
    // MARK: - Properties
    var timezone = ""
    var currentTime = 0.0
    var temperature = 0
    var details = ""
    var dayIcon = ""
    
    var dailyWeatherData: [DailyWeather] = []
    var hourlyWeatherData: [HourlyWeather] = []
    
    // MARK: - Function
    func getData(completion: @escaping () -> Void) {
        let urlString = API_URL.weatherAPI + "?lat=\(latitude)&lon=\(longitude)" +
            "&exclude=minutely&units=metric&appid=\(APIKeys.openWeatherKey)"
//        print("Accesing the url \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print(#function, "Something wrong with url from \(urlString).")
            completion()
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print(#function, "Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print(#function, "Something wrong with data")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(Result.self, from: data)
                self.timezone = result.timezone
                self.currentTime = result.current.dt
                self.temperature = Int(result.current.temp.rounded())
                self.details = result.current.weather[0].description
                self.dayIcon = self.iconFromWeather(id: result.current.weather[0].id, icon: result.current.weather[0].icon)
                
                self.processDailyWeather(from: result)
                self.processHourlyWeather(from: result)
                
            } catch {
                print(#function, "JSON error: \(error.localizedDescription)")
            }
            
            completion()
        }
        
        task.resume()
    }
    
    // MARK: - Private Helpers
    private func processDailyWeather(from result: Result) {
        // get no more than 24hrs of hourly data
        for index in 0..<result.daily.count {
            let weekdayDate = Date(timeIntervalSince1970: result.daily[index].dt)
            WeatherDateFormatter.weekdayFormatter.timeZone = TimeZone(identifier: result.timezone)
            let dailyWeekday = WeatherDateFormatter.weekdayFormatter.string(from: weekdayDate)
            
            let dailyIcon = self.iconFromWeather(
                id: result.daily[index].weather[0].id,
                icon: result.daily[index].weather[0].icon)
            let dailyDetail = result.daily[index].weather[0].description
            let dailyHigh = Int(result.daily[index].temp.max.rounded())
            let dailyLow = Int(result.daily[index].temp.min.rounded())
            
            let dailyWeather = DailyWeather(
                dailyIcon: dailyIcon,
                dailyWeekday: dailyWeekday,
                dailySummary: dailyDetail,
                dailyHigh: dailyHigh,
                dailyLow: dailyLow)
            
            self.dailyWeatherData.append(dailyWeather)
        }
    }
    
    private func processHourlyWeather(from result: Result) {
        let lastHour = min(24, result.hourly.count)
        if lastHour > 0 {
            for index in 1...lastHour {
                let hourlyDate = Date(timeIntervalSince1970: result.hourly[index].dt)
                WeatherDateFormatter.hourFormatter.timeZone = TimeZone(identifier: result.timezone)
                let hour = WeatherDateFormatter.hourFormatter.string(from: hourlyDate)
                
                let hourlyIcon = self.iconFromWeather(
                    id: result.hourly[index].weather[0].id,
                    icon: result.hourly[index].weather[0].icon)
                let hourlyTemperature = Int(result.hourly[index].temp.rounded())
                
                let hourlyWeather = HourlyWeather(hour: hour, hourlyTemperature: hourlyTemperature, hourlyIcon: hourlyIcon)
                self.hourlyWeatherData.append(hourlyWeather)
            }
        }
    }
    
    // MARK: - Utils
    private func iconFromWeather(id: Int, icon: String) -> String {
        switch id {
        case 200...299:
            return "cloud.bolt.rain.fill"
        case 300...399:
            return "cloud.drizzle.fill"
        case 500, 501, 520, 521, 531:
            return "cloud.rain.fill"
        case 502, 503, 504, 522:
            return "cloud.heavyrain.fill"
        case 511, 611...616:
            return "sleet.fill"
        case 600...602, 620...622:
            return "cloud.snow.fill"
        case 701, 711, 741:
            return "cloud.fog.fill"
        case 721:
            return (icon.hasSuffix("d") ? "sun.haze.fill" : "cloud.fog.fill")
        case 731, 751, 761, 762:
            return (icon.hasSuffix("d") ? "sun.dust.fill" : "cloud.fog.fill")
        case 771:
            return "wind"
        case 781:
            return "tornado"
        case 800:
            return (icon.hasSuffix("d") ? "sun.max.fill" : "moon.fill")
        case 801, 802:
            return (icon.hasSuffix("d") ? "cloud.sun.fill" : "cloud.moon.fill")
        case 803, 804:
            return "cloud.fill"
        default:
            return "questionmark"
        }
    }
}
