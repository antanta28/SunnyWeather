//
//  WeatherLocationCell.swift
//  WeatherApp
//
//  Created by Kirill Fedin on 21.05.2021.
//

import UIKit

final class WeatherLocationCell: UITableViewCell {
    static let identifier = "WeatherLocationCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
