//
//  UIViewExtention.swift
//  Cam
//
//  Created by Amir Shayegh on 2018-09-21.
//
import Foundation
import UIKit

extension UIView {

    // Find parent vc
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController?
            }
        }
        return nil
    }

    // Load a nib
    class func fromNib<T: UIView>() -> T {
        return Cam.bundle.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }

    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }


}

extension UIDeviceOrientation {
    func getUIImageOrientationFromDevice() -> UIImage.Orientation {
        // return CGImagePropertyOrientation based on Device Orientation
        // This extented function has been determined based on experimentation with how an UIImage gets displayed.
        switch self {
        case UIDeviceOrientation.portrait, .faceUp: return UIImage.Orientation.right
        case UIDeviceOrientation.portraitUpsideDown, .faceDown: return UIImage.Orientation.left
        case UIDeviceOrientation.landscapeLeft: return UIImage.Orientation.up // this is the base orientation
        case UIDeviceOrientation.landscapeRight: return UIImage.Orientation.down
        case UIDeviceOrientation.unknown: return UIImage.Orientation.up
        }
    }
}
