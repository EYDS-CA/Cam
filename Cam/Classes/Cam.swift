//
//  Cam.swift
//  Cam
//
//  Created by Amir Shayegh on 2018-09-21.
//

import Foundation
import UIKit

@available(iOS 11.0, *)

public class Cam {

    public init() {}

    static var bundle: Bundle {
        let podBundle = Bundle(for: CamViewController.self)

        if let bundleURL = podBundle.url(forResource: "Cam", withExtension: "bundle"), let b = Bundle(url: bundleURL) {
            return b
        } else {
            print("Fatal Error: Could not find bundle for Cam Framework")
            fatalError()
        }
    }

    // Picker view controller
    public lazy var camVC: CamViewController = {
        return UIStoryboard(name: "Cam", bundle: Cam.bundle).instantiateViewController(withIdentifier: " Cam") as! CamViewController
    }()
}
