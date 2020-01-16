//
//  Formatters.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 05/07/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static let shortTimeStyle: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        return timeFormatter
    }()
}

extension NumberFormatter {
    
    static let decimalStyle: NumberFormatter = {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .decimal
        numFormatter.minimumFractionDigits = 2
        numFormatter.maximumFractionDigits = 2
        return numFormatter
    }()
}
