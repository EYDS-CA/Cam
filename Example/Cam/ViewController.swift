//
//  ViewController.swift
//  Cam
//
//  Created by amirshayegh on 09/21/2018.
//  Copyright (c) 2018 amirshayegh. All rights reserved.
//

import UIKit
import Cam

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func action(_ sender: UIButton) {
        // Create a Cam object
        let cam = Cam()
        // Call display
        cam.display(on: self) { (photo) in
            // Procss Photo object
            if let photo = photo {
                // Example: displaying image on an imageview for 2 seconds
                let imageView = UIImageView(frame: self.view.frame)
                imageView.contentMode = .scaleAspectFit
                imageView.image = photo.image
                self.view.addSubview(imageView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    imageView.removeFromSuperview()
                })
            }
        }
    }
}
