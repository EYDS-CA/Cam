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
        let cam = Cam()
        cam.display(on: self, buttonAndBackgroundColor: UIColor.blue, buttonTextColor: UIColor.white) { (photo) in
            if let photo = photo {
                let imageView = UIImageView(frame: self.view.frame)
                imageView.contentMode = .scaleAspectFit
                imageView.image = photo.image
                self.view.addSubview(imageView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    //                        imageView.image = nil
                    imageView.removeFromSuperview()
                })
            }
        }
    }

}
