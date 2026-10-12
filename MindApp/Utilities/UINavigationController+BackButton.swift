//
//  UINavigationController+BackButton.swift
//  MindApp
//
//  Created by Michael Slavev on 16.03.2024.
//

import UIKit

extension UINavigationController {
    // Remove back button text
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
    }
}
