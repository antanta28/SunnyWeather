//
//  UIViewController+Alert.swift
//  WeatherApp
//
//  Created by Kirill Fedin on 16.06.2021.
//

import UIKit

extension UIViewController {
    func alertWithCancel(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
