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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func action(_ sender: UIButton) {
        let cam = Cam()
        let vc = cam.camVC
        self.present(vc, animated: true, completion: nil)
    }

}
