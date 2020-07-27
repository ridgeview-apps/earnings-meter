//
//  ViewExtensions.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 05/07/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import Foundation
import SwiftUI

typealias ActionHandler = () -> Void

extension View {
    
    var asAnyView: AnyView {
        AnyView(self)
    }

    func uiTableViewDismissMode(_ dismissMode: UIScrollView.KeyboardDismissMode) -> some View {
        introspectTableView { tableView in
            tableView.keyboardDismissMode = .onDrag
        }
    }
    
    func uiTableViewBackgroundColor(_ color: UIColor) -> some View {
        introspectTableView { tableView in
            tableView.backgroundColor = color
        }
    }
}
