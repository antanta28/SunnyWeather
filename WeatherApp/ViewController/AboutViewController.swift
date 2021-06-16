//
//  AboutViewController.swift
//  WeatherApp
//
//  Created by Kirill Fedin on 16.06.2021.
//

import UIKit

class AboutViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Weather app by kfedin"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 50)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25)
        label.numberOfLines = 0
        label.text = "Weather application using OpenWeather API and Google"
        return label
    }()
    
    private let imageStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let googleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "powered_by_google_on_white")
        return imageView
    }()
    
    private let openWeatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "powered_by_openweather")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        addSubviews()
    }
}

extension AboutViewController {
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        
        imageStack.addArrangedSubview(googleImageView)
        imageStack.addArrangedSubview(openWeatherImageView)
        view.addSubview(imageStack)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
        ])
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
        ])
        
        imageStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageStack.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            imageStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            imageStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
        ])
    }
}
