//
//  HourlyWeatherCollectionViewCell.swift
//  WeatherApp
//
//  Created by Kirill Fedin on 15.06.2021.
//

import UIKit

class HourlyWeatherCollectionViewCell: UICollectionViewCell {
    static let identifier = "HourlyWeatherCollectionViewCell"
    
    // MARK: - Properties
    var hourlyWeather: HourlyWeather! {
        didSet {
            hourLabel.text = hourlyWeather.hour
            weatherImageView.image = UIImage(systemName: hourlyWeather.hourlyIcon)
            temperatureLabel.text = String(hourlyWeather.hourlyTemperature) + "°"
        }
    }
    
    // MARK: - UI
    private let hourLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let weatherImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
//        view.tintColor = .lightGray
        return view
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HourlyWeatherCollectionViewCell {
    private func addSubviews() {
        addSubview(hourLabel)
        addSubview(weatherImageView)
        addSubview(temperatureLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        hourLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hourLabel.topAnchor.constraint(equalTo: topAnchor),
            hourLabel.leftAnchor.constraint(equalTo: leftAnchor),
            hourLabel.rightAnchor.constraint(equalTo: rightAnchor),
            hourLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            temperatureLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            temperatureLabel.leftAnchor.constraint(equalTo: leftAnchor),
            temperatureLabel.rightAnchor.constraint(equalTo: rightAnchor),
            temperatureLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        weatherImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weatherImageView.topAnchor.constraint(equalTo: hourLabel.bottomAnchor),
            weatherImageView.leftAnchor.constraint(equalTo: leftAnchor),
            weatherImageView.rightAnchor.constraint(equalTo: rightAnchor),
            weatherImageView.bottomAnchor.constraint(equalTo: temperatureLabel.topAnchor)
        ])
    }
}
