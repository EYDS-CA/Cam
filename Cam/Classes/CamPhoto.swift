//
//  CamPhoto.swift
//  Cam
//
//  Created by Amir Shayegh on 2018-09-25.
//

import Foundation
import AVFoundation

public class Photo {
    public var image: UIImage?
    public var timeStamp: CMTime?
    public var metadata: [String : Any]

    init(image: UIImage, timeStamp: CMTime,  metadata: [String : Any]) {
        self.image = image
        self.timeStamp = timeStamp
        self.metadata = metadata
    }
}
