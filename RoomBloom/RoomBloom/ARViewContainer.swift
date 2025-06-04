//
//  ARViewContainer.swift
//  RoomBloom
//
//  Created by Jakob Mösenbacher on 28.04.25.
//

import SwiftUI
import UIKit

struct ARViewContainer: UIViewControllerRepresentable {
    let imageName: String

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = ViewController()
        vc.modelName = imageName  // Übergabe des Namens
        let navController = UINavigationController(rootViewController: vc)
        return navController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Kein Update nötig
    }
}
