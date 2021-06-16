//
//  ViewController.swift
//  WeatherApp
//
//  Created by Kirill Fedin on 21.05.2021.
//

import UIKit
import GooglePlaces

class LocationListViewController: UIViewController {
    // MARK: - Properties
    var weatherLocations = [WeatherLocation]()
    var selectedLocationIndex = 0
    
    var completion: ((_ selectedIndex: Int,  _ weatherLocations: [WeatherLocation]) -> ())?
    
    // MARK: - UI
    private let bottomToolbar: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.directionalLayoutMargins = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        return button
    }()
    
    private let addLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Location", for: .normal)
        button.addTarget(self, action: #selector(addLocationTapped), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        return button
    }()
    
    private let tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        viewWillAddSubviews()
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(
            WeatherLocationCell.self,
            forCellReuseIdentifier: WeatherLocationCell.identifier
        )
    }
    
    // MARK: - Debug
    
    // MARK: - Selectors
    @objc
    private func addLocationTapped() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // return data type
        let fields: GMSPlaceField = GMSPlaceField(
            rawValue: UInt(GMSPlaceField.name.rawValue)
                | UInt(GMSPlaceField.placeID.rawValue)
                | UInt(GMSPlaceField.coordinate.rawValue)
        )
        autocompleteController.placeFields = fields
        
        // filters
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @objc
    private func editTapped() {
        if tableView.isEditing {
            editButtonItem.title = "Edit"
            tableView.setEditing(false, animated: true)
        } else {
            editButtonItem.title = "Done"
            tableView.setEditing(true, animated: true)
        }
    }
    
    // MARK: - Helpers
    private func saveLocations() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(weatherLocations) {
            UserDefaults.standard.set(encoded, forKey: "weatherLocations")
        } else {
            print("Error: Saving encoded didn't work!")
        }
    }
}

// MARK: - Layout
extension LocationListViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomToolbar.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomToolbar.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor),
        ])
    }
    private func viewWillAddSubviews() {
        bottomToolbar.addArrangedSubview(editButton)
        bottomToolbar.addArrangedSubview(addLocationButton)
        view.addSubview(bottomToolbar)
        view.addSubview(tableView)
    }
}

// MARK: - UITableViewDataSource
extension LocationListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weatherLocation = weatherLocations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: WeatherLocationCell.identifier,
            for: indexPath
        )
        cell.textLabel?.text = weatherLocation.name
        cell.detailTextLabel?.text = "Lat: \(weatherLocation.latitude), lng: \(weatherLocation.longitude)"
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LocationListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            weatherLocations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        moveRowAt sourceIndexPath: IndexPath,
        to destinationIndexPath: IndexPath
    ) {
        let itemToMove = weatherLocations[sourceIndexPath.row]
        weatherLocations.remove(at: sourceIndexPath.row)
        weatherLocations.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        completion?(indexPath.row, weatherLocations)
        
        saveLocations()
        dismiss(animated: true)
    }
    
    // MARK: - tableview methods to freeze first cell
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0 ? true : false
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0 ? true : false
    }
    func tableView(
        _ tableView: UITableView,
        targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
        toProposedIndexPath proposedDestinationIndexPath: IndexPath
    ) -> IndexPath {
        return (proposedDestinationIndexPath.row == 0 ? sourceIndexPath : proposedDestinationIndexPath)
    }
}

// MARK: - GMSAutocompleteViewControllerDelegate
extension LocationListViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(
        _ viewController: GMSAutocompleteViewController,
        didAutocompleteWith place: GMSPlace
    ) {
        let newLocation = WeatherLocation(
            name: place.name ?? "Unknown Location",
            latitude: place.coordinate.latitude,
            longitude: place.coordinate.longitude
        )
        weatherLocations.append(newLocation)
        tableView.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(
        _ viewController: GMSAutocompleteViewController,
        didFailAutocompleteWithError error: Error
    ) {
        print(#function, "error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}
