//
//  Cam.swift
//  Cam
//
//  Created by Amir Shayegh on 2018-09-21.
//

import Foundation
import UIKit

class Cam {
    lazy var cam: CamViewController = {
    return UIStoryboard(name: "Cam", bundle: Bundle.main).instantiateViewController(withIdentifier: "Cam") as! CamViewController
    }()
}
