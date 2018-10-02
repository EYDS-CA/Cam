//
//  CamPhoto.swift
//  Cam
//
//  Created by Amir Shayegh on 2018-09-25.
//

import Foundation
import AVFoundation
import CoreLocation

public class Photo {
    public var image: UIImage?
    public var timeStamp: CMTime?
    public var location: CLLocation?
    public var heading: CLHeading?

    public var metadata: [String : Any]

    init(image: UIImage, timeStamp: CMTime, location: CLLocation?,heading: CLHeading?,metadata: [String : Any]) {
        self.image = image
        self.timeStamp = timeStamp
        self.metadata = metadata
    }
}
