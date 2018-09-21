//
//  PreviewView.swift
//  Cam
//
//  Created by Amir Shayegh on 2018-09-21.
//

import UIKit
import AVFoundation

class PreviewView: UIView {

    var parent: CamViewController?

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    // MARK: Positioning
    func position(in cameraContainer: UIView) {
        self.frame = cameraContainer.frame
        self.center.x = cameraContainer.center.x
        self.center.y = cameraContainer.center.y
        self.centerXAnchor.constraint(equalTo: cameraContainer.centerXAnchor)
        self.centerYAnchor.constraint(equalTo: cameraContainer.centerYAnchor)
        self.translatesAutoresizingMaskIntoConstraints = false
        cameraContainer.addSubview(self)

        // Add constraints
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: cameraContainer.frame.height),
            self.heightAnchor.constraint(equalToConstant: cameraContainer.frame.width),
            ])
    }

}
