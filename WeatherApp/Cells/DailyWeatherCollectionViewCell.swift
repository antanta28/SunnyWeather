//
//  DailyWeatherCollectionViewCell.swift
//  WeatherApp
//
//  Created by Kirill Fedin on 15.06.2021.
//

import UIKit

class DailyWeatherCollectionViewCell: UICollectionViewCell {
    static let identifier = "DailyWeatherCollectionViewCell"
    
    // MARK: - Properties
    var dailyWeather: DailyWeather! {
        didSet {
            dailyImageView.image = UIImage(systemName: dailyWeather.dailyIcon)
            dailyWeekdayLabel.text = dailyWeather.dailyWeekday
            dailyDetailView.text = dailyWeather.dailySummary
            dailyHighLabel.text = String(dailyWeather.dailyHigh) + "°"
            dailyLowLabel.text = String(dailyWeather.dailyLow) + "°"
        }
    }
    // MARK: - UI
    private let dailyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "sun.max")
        return imageView
    }()
    
    private let dailyWeekdayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.text = "Monday"
//        label.backgroundColor = .green
        return label
    }()
    
    private let dailyDetailView: UITextView = {
        let view = UITextView()
        view.isSelectable = false
        view.isScrollEnabled = false
        view.isEditable = false
        view.isUserInteractionEnabled = false
//        view.backgroundColor = .red
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.font = .systemFont(ofSize: 14)
        view.textContainer.maximumNumberOfLines = 3
        view.text = "Rain, rain go away. Come on back another day aaaaa"
        return view
    }()
    
    private let dailyHighLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .medium)
        label.textAlignment = .right
        label.text = "30"
//        label.backgroundColor = .purple
        return label
    }()
    
    private let dailyLowLabel: UILabel = {
        let label = UILabel()
        label.text = "20"
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 22)
//        label.backgroundColor = .blue
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

extension DailyWeatherCollectionViewCell {
    private func addSubviews() {
        addSubview(dailyImageView)
        addSubview(dailyWeekdayLabel)
        addSubview(dailyDetailView)
        addSubview(dailyHighLabel)
        addSubview(dailyLowLabel)
    }
    
    override func layoutSubviews() {
        dailyImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dailyImageView.widthAnchor.constraint(equalToConstant: 70),
            dailyImageView.heightAnchor.constraint(equalToConstant: 70),
            dailyImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            dailyImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10)
        ])
        
        dailyWeekdayLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dailyWeekdayLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            dailyWeekdayLabel.leftAnchor.constraint(equalTo: dailyImageView.rightAnchor, constant: 10),
            dailyWeekdayLabel.rightAnchor.constraint(equalTo: dailyHighLabel.leftAnchor, constant: -5)
        ])
        
        dailyDetailView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dailyDetailView.topAnchor.constraint(equalTo: dailyWeekdayLabel.bottomAnchor, constant: 0),
            dailyDetailView.leftAnchor.constraint(equalTo: dailyImageView.rightAnchor, constant: 10),
            dailyDetailView.rightAnchor.constraint(equalTo: dailyLowLabel.leftAnchor, constant: -5),
            dailyDetailView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        dailyHighLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dailyHighLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            dailyHighLabel.leftAnchor.constraint(equalTo: dailyWeekdayLabel.rightAnchor, constant: 5),
            dailyHighLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10)
        ])
        
        dailyLowLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dailyLowLabel.topAnchor.constraint(equalTo: dailyHighLabel.bottomAnchor, constant: 5),
            dailyLowLabel.leftAnchor.constraint(equalTo: dailyDetailView.rightAnchor, constant: 5),
            dailyLowLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10)
        ])
    }
}
