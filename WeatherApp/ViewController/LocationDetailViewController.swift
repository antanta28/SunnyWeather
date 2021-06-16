//
//  LocationDetailViewController.swift
//  WeatherApp
//
//  Created by Kirill Fedin on 21.05.2021.
//

import UIKit
import CoreLocation

final class LocationDetailViewController: UIViewController {
    // MARK: - Properties
    private var weatherDetail: WeatherDetail!
    public var locationIndex: Int
    private var locationManager: CLLocationManager!
    
    // MARK: - UI
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    // MARK: - ToolBar
    private let bottomToolbar: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        return stack
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .systemTeal
        pageControl.currentPageIndicatorTintColor = .label
        pageControl.addTarget(self, action: #selector(pageControlTapped), for: .valueChanged)
        return pageControl
    }()
    
    private let aboutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("About", for: .normal)
        button.addTarget(self, action: #selector(aboutButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        return button
    }()
    
    private let locationsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Locations", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.addTarget(self, action: #selector(locationsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Weather top
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    // right side
    private let labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        return stack
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .right
        label.textColor = .white
        return label
    }()
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .right
        label.textColor = .white
        return label
    }()
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 100)
        label.textAlignment = .right
        label.textColor = .white
        return label
    }()
    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .right
        label.textColor = .white
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    // left side
    private let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: Init
    init(locationIndex: Int) {
        self.locationIndex = locationIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        viewWillAddSubviews()
        
        populateUserInterface()
        
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if locationIndex == 0 {
            getLocation()
        }
    }
    
    // MARK: - Selectors
    @objc
    private func pageControlTapped(sender: UIPageControl) {
        if let pageViewController = UIApplication.shared
            .windows.first?.rootViewController as? PageLocationsViewController {
            let direction: UIPageViewController.NavigationDirection = sender.currentPage > locationIndex ? .forward : .reverse
            
            pageViewController.setViewControllers(
                [pageViewController.createLocationDetailViewController(forPage: sender.currentPage)],
                direction: direction,
                animated: true
            )
        }
    }
    
    @objc
    private func aboutButtonTapped() {
        let viewController = AboutViewController()
        present(viewController, animated: true, completion: nil)
    }
    
    @objc
    private func locationsButtonTapped() {
        guard let pageViewController = UIApplication.shared
                .windows.first?.rootViewController as? PageLocationsViewController else {
            return
        }
        
        let viewController = LocationListViewController()
        viewController.weatherLocations = pageViewController.weatherLocations
        viewController.modalPresentationStyle = .fullScreen
        
        viewController.completion = { (selectedIndex, weatherLocations) in
            pageViewController.weatherLocations = weatherLocations
            pageViewController.setViewControllers(
                [pageViewController.createLocationDetailViewController(forPage: selectedIndex)],
                direction: .forward,
                animated: false
            )
        }
        
        present(viewController, animated: true)
    }
    
    // MARK: - Helpers
    private func populateUserInterface() {
        if let pageViewController = UIApplication.shared
            .windows.first?.rootViewController as? PageLocationsViewController {
            let weatherLocation = pageViewController.weatherLocations[locationIndex]
            weatherDetail = WeatherDetail(
                name: weatherLocation.name,
                latitude: weatherLocation.latitude,
                longitude: weatherLocation.longitude)
            
            pageControl.numberOfPages = pageViewController.weatherLocations.count
            pageControl.currentPage = locationIndex
            
            weatherDetail.getData {
                DispatchQueue.main.async {
                    WeatherDateFormatter.dateformatter.timeZone = TimeZone(identifier: self.weatherDetail.timezone)
                    let usableDate = Date(timeIntervalSince1970: self.weatherDetail.currentTime)
                    self.dateLabel.text = WeatherDateFormatter.dateformatter.string(from: usableDate)
                    
                    self.locationLabel.text = self.weatherDetail.name
                    self.temperatureLabel.text = "\(self.weatherDetail.temperature)°"
                    self.detailsLabel.text = self.weatherDetail.details
                    self.weatherImageView.image = UIImage(systemName: self.weatherDetail.dayIcon)
                    
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    
    // MARK: - UICollectionView
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionKind = WeatherSection(rawValue: sectionIndex) else {
                return nil
            }
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let groupSize: NSCollectionLayoutSize = sectionKind == .daily ?
                .init(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80)) :
                .init(
                    widthDimension: .fractionalWidth(0.3),
                    heightDimension: .fractionalHeight(0.3))
            
            let group: NSCollectionLayoutGroup = sectionKind == .daily ?
                .horizontal(layoutSize: groupSize, subitem: item, count: 1) :
                .vertical(layoutSize: groupSize, subitem: item, count: 1)

            
            let section = NSCollectionLayoutSection(group: group)
            if sectionKind == .hourly {
                section.orthogonalScrollingBehavior = .continuous
            }
            
            section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
            return section
        }
        
        return layout
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            DailyWeatherCollectionViewCell.self,
            forCellWithReuseIdentifier: DailyWeatherCollectionViewCell.identifier)
        collectionView.register(
            HourlyWeatherCollectionViewCell.self,
            forCellWithReuseIdentifier: HourlyWeatherCollectionViewCell.identifier)
        
        collectionView.backgroundColor = .systemBackground
    }
}

// MARK: - Layout
extension LocationDetailViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomToolbar.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomToolbar.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.4)
        ])
        
        weatherImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weatherImageView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            weatherImageView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 20),
            weatherImageView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            weatherImageView.rightAnchor.constraint(equalTo: labelsStack.leftAnchor)
        ])
        
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            labelsStack.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -20),
            labelsStack.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            labelsStack.widthAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 0.6)
        ])
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor),
        ])
    }
    
    private func viewWillAddSubviews() {
        bottomToolbar.addArrangedSubview(aboutButton)
        bottomToolbar.addArrangedSubview(pageControl)
        bottomToolbar.addArrangedSubview(locationsButton)
        view.addSubview(bottomToolbar)
        
        view.addSubview(backgroundView)
        view.addSubview(collectionView)
        
        view.addSubview(weatherImageView)
        view.addSubview(labelsStack)
        for label in [dateLabel, locationLabel, temperatureLabel, detailsLabel] {
            label.translatesAutoresizingMaskIntoConstraints = false
            labelsStack.addArrangedSubview(label)
        }
    }
}

extension LocationDetailViewController: UICollectionViewDelegate {
    
}

extension LocationDetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        WeatherSection.allCases.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return section == 0 ? weatherDetail.hourlyWeatherData.count : weatherDetail.dailyWeatherData.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HourlyWeatherCollectionViewCell.identifier,
                for: indexPath
            ) as? HourlyWeatherCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let hourlyWeatherData = weatherDetail.hourlyWeatherData[indexPath.row]
            cell.hourlyWeather = hourlyWeatherData
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DailyWeatherCollectionViewCell.identifier,
                for: indexPath
            ) as? DailyWeatherCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let weatherData = weatherDetail.dailyWeatherData[indexPath.row]
            cell.dailyWeather = weatherData
            
            return cell
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationDetailViewController: CLLocationManagerDelegate {
    private func getLocation() {
        // Creation a CLLocationManager will automatically check authorization
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    private func handleAuthenticationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.alertWithCancel(
                title: "Location services denied",
                message: "May be parential controls are restricting location use in this app."
            )
        case .denied:
            showAlertToPrivacySettings(
                title: "User has not authorized locaiton services",
                message: "Select 'Settings' below to open device settings."
            )
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("Dev alert: unknown case of status in \(#function) \(status)")
        }
    }
    
    private func showAlertToPrivacySettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print(#function, "Something went wrong getting the UIApplication.openSettingsURL")
            return
        }
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        handleAuthenticationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last ?? CLLocation()
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { placemarks, error in
            var locationName = ""
            if placemarks != nil {
                let placemark = placemarks?.last
                locationName = placemark?.name ?? "Location Unknown"
            } else {
                locationName = "Couldn't find location"
            }
            
            print("LocationName: ", locationName)
            
            // Update weatherLocations[0] with current location
            let coordinates = currentLocation.coordinate
            let pageViewController = UIApplication.shared.windows.first?.rootViewController as? PageLocationsViewController
            pageViewController?.weatherLocations[self.locationIndex].latitude = coordinates.latitude
            pageViewController?.weatherLocations[self.locationIndex].longitude = coordinates.longitude
            pageViewController?.weatherLocations[self.locationIndex].name = locationName
            
            self.populateUserInterface()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error.localizedDescription, "Failed to get device location")
    }
}
