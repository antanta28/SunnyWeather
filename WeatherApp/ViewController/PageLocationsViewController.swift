//
//  PageLocationsViewController.swift
//  WeatherApp
//
//  Created by Kirill Fedin on 22.05.2021.
//

import UIKit

class PageLocationsViewController: UIPageViewController {
    // MARK: - Properties
    var weatherLocations: [WeatherLocation] = []
    
    // MARK: - Init
    override init(
        transitionStyle style: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey : Any]? = nil
    ) {
        super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        delegate = self
        dataSource = self
        
        loadLocations()
        
        setViewControllers(
            [createLocationDetailViewController(forPage: 0)],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }

    // MARK: - Helpers
    func createLocationDetailViewController(forPage page: Int) -> LocationDetailViewController {
        let detailViewController = LocationDetailViewController(locationIndex: page)
        return detailViewController
    }
    
    private func loadLocations() {
        guard let locationsEncoded = UserDefaults.standard.value(forKey: "weatherLocations") as? Data else {
            weatherLocations.append(.init(name: "Unknown", latitude: 0, longitude: 0))
            return
        }
        
        let decoder = JSONDecoder()
        if let weatherLocations = try? decoder.decode(Array<WeatherLocation>.self, from: locationsEncoded) {
            self.weatherLocations = weatherLocations
        } else {
            print("Error: Couldn't decode data from userdefaults")
        }
        
        if weatherLocations.isEmpty {
            weatherLocations.append(.init(name: "Unknown", latitude: 0, longitude: 0))
        }
    }
}

extension PageLocationsViewController: UIPageViewControllerDelegate {
    
}

extension PageLocationsViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        if let currentViewController = viewController as? LocationDetailViewController {
            if currentViewController.locationIndex > 0 {
                return createLocationDetailViewController(forPage: currentViewController.locationIndex - 1)
            }
        }
        return nil
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        if let currentViewController = viewController as? LocationDetailViewController {
            if currentViewController.locationIndex < weatherLocations.count - 1 {
                return createLocationDetailViewController(forPage: currentViewController.locationIndex + 1)
            }
        }
        return nil
    }
}
