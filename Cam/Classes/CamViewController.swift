//
//  CamViewController.swift
//  Cam
//
//  Created by Amir Shayegh on 2018-09-21.
//

import UIKit
import AVFoundation

enum CamMode {
    case Video
    case Photo
}

@available(iOS 11.0, *)
public class CamViewController: UIViewController {

    // MARK: Constants
    let shadowColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
    let notification = UINotificationFeedbackGenerator()
    let whiteScreenTag = 52
    let imagePreviewTag = 53
    let animationDuration: Double = 0.2

    var displayPadding: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 100
        } else {
            return 0
        }
    }

    // MARK: Variables
    var captureSession: AVCaptureSession = AVCaptureSession()
    var photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    var videoPreviewLayer: PreviewView?
    var picPreview: UIView?
    var imageOrientation: AVCaptureVideoOrientation?
    var deviceOrientationOnCapture: UIDeviceOrientation?

    var flashEnabled: Bool = false
    var hasFlash: Bool = false

    var taken: AVCapturePhoto?

    var primaryColor: UIColor = .white
    var textColor: UIColor = .black

    var callBack: ((_ photo: Photo?)-> Void)?

    var previewing: Bool = false

    // MARK: Outlet
    @IBOutlet weak var cameraContainere: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!

    override public func viewDidLoad() {
        super.viewDidLoad()
        style()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }


    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setup(for: .back)
        makeCircle(view: captureButton)
    }

    // MARK: Outlet Actions
    @IBAction func closeAction(_ sender: Any) {
        if previewing {
            guard let videoPreview = videoPreviewLayer, let imageView = self.view.viewWithTag(imagePreviewTag) as? UIImageView else {return}
            UIView.animate(withDuration: animationDuration, animations: {
                videoPreview.alpha = 1
                imageView.alpha = 0
                self.captureButton.setTitle("Capture", for: .normal)
                self.closeButton.setTitle("Cancel", for: .normal)
                self.view.layoutIfNeeded()
            }) { (done) in
                self.previewing = false
                imageView.removeFromSuperview()
            }
        } else {
            self.taken = nil
            self.close()
        }
    }

    @IBAction func captureAction(_ sender: Any) {
        if previewing {
            close()
        } else {
            guard let parent = self.parent, let parentView = parent.view else {return}
            self.captureButton.isEnabled = false
            self.imageOrientation = getVideoOrientation(size: parentView.frame.size)
            let settings = setPhotoSettings()
            self.deviceOrientationOnCapture = UIDevice.current.orientation
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    func setup(for position: AVCaptureDevice.Position) {
        captureSession.beginConfiguration()
        setInput(forDevice: position)
        setOutput()
        setPreviewView()
        captureSession.startRunning()
    }

    func setPreviewView() {
        self.view.layoutIfNeeded()
        guard let parent = self.parent, let parentView = parent.view else {return}
        let preview: PreviewView = UIView.fromNib()
        preview.videoPreviewLayer.session = self.captureSession
        preview.position(in: cameraContainere, behind: captureButton)
        self.videoPreviewLayer = preview
        setVideoOrientation(for: parentView.frame.size)
        self.view.addSubview(captureButton)
        self.view.addSubview(closeButton)
        styleContainer(layer: preview)
        preview.clipsToBounds = true
        addPreviewConstraints(to: preview)
    }


    func setInput(forDevice position: AVCaptureDevice.Position) {
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: getCamera(for: position)),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
    }

    // Note: Currently only supports photo.
    /*
     In order to support video or video and photo,
     add both AVCapturePhotoOutput and AVCaptureMovieFileOutput to session.
     https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/setting_up_a_capture_session
     Also note the for video, we would have to change input to record from the microphone too.
     */
    func setOutput() {
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.isLivePhotoCaptureEnabled = false
        guard self.captureSession.canAddOutput(photoOutput) else { return }
        self.captureSession.sessionPreset = .photo
        self.captureSession.addOutput(photoOutput)
        self.captureSession.commitConfiguration()
        captureSession.startRunning()
    }

    func setPhotoSettings() -> AVCapturePhotoSettings {
        var photoSettings: AVCapturePhotoSettings = AVCapturePhotoSettings()
        if self.photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
            photoSettings = AVCapturePhotoSettings(format:
                [AVVideoCodecKey: AVVideoCodecType.jpeg])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }
        if flashEnabled, hasFlash {
            photoSettings.flashMode = .on
        } else {
            photoSettings.flashMode = .off
        }
        photoSettings.isAutoStillImageStabilizationEnabled =
            self.photoOutput.isStillImageStabilizationSupported
        return photoSettings
    }

    func getCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera,
                                                for: .video, position: position) {
            self.hasFlash = device.hasFlash
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video, position: position) {
            self.hasFlash = device.hasFlash
            return device
        } else {
            fatalError("Missing expected back camera device.")
        }
    }

    // MARK: Screen rotation
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.view.layoutIfNeeded()
        setVideoOrientation(for: size)
        place(with: size)
    }

    func setVideoOrientation(for size: CGSize) {
        if let preview = self.videoPreviewLayer, let connection = preview.videoPreviewLayer.connection {
            connection.videoOrientation = getVideoOrientation(size: size)
        }
    }

    func getVideoOrientation(size: CGSize) -> AVCaptureVideoOrientation {
        self.view.layoutIfNeeded()
        if size.width > size.height {
            if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                return .landscapeRight
            } else {
                return .landscapeLeft
            }
        } else {
            //portrait
            if UIDevice.current.orientation == UIDeviceOrientation.portrait {
                return .portrait
            } else {
                return .portraitUpsideDown
            }
        }
    }

    // MARK: White Screen
    func whiteScreen() -> UIView? {
        guard let p = parent else {return nil}
        let view = UIView(frame: CGRect(x: 0, y: 0, width: p.view.frame.width, height: p.view.frame.height))
        view.center.y = p.view.center.y
        view.center.x = p.view.center.x
        view.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:0.5)
        view.alpha = 1
        view.tag = whiteScreenTag

        return view
    }

    func setWhiteScreen() {
        guard let p = parent, let screen = whiteScreen() else {return}
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.cancelled(_:)))
        screen.alpha = 0
        p.view.insertSubview(screen, belowSubview: self.view)
        screen.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            screen.trailingAnchor.constraint(equalTo: p.view.trailingAnchor),
            screen.leadingAnchor.constraint(equalTo: p.view.leadingAnchor),
            screen.topAnchor.constraint(equalTo: p.view.topAnchor),
            screen.bottomAnchor.constraint(equalTo: p.view.bottomAnchor)
            ])
        screen.addGestureRecognizer(tap)
        UIView.animate(withDuration: animationDuration, animations: {
            screen.alpha = 1
        })
    }

    func removeWhiteScreen() {
        guard let p = parent else {return}
        if let viewWithTag = p.view.viewWithTag(whiteScreenTag) {
            viewWithTag.removeFromSuperview()
        }
    }

    @objc func cancelled(_ sender: UISwipeGestureRecognizer) {
        self.taken = nil
        close()
    }


    // MARK: Display and remove
    func display(on parent: UIViewController, buttonAndBackgroundColor: UIColor? = .white, buttonTextColor: UIColor? = .black, then: @escaping (_ photo: Photo?)-> Void) {
        self.callBack = then

        if let primary = buttonAndBackgroundColor {
            self.primaryColor = primary
        }
        if let textClr = buttonTextColor {
            self.textColor = textClr
        }
        
        style()

        parent.addChild(self)
        positionPreAnimation(in: parent)
        parent.view.addSubview(self.view)
        self.didMove(toParent: parent)
        setWhiteScreen()
        UIView.animate(withDuration: animationDuration, animations: {
            self.position(in: parent)
        })
    }

    func close() {
        guard let p = parent else {return}
        self.captureSession.stopRunning()
        UIView.animate(withDuration: animationDuration, animations: {
            self.positionPreAnimation(in: p)
            if let whiteScreen = p.view.viewWithTag(self.whiteScreenTag) {
                whiteScreen.alpha = 0
            }
        }) { (done) in
            self.remove()
        }
    }

    func remove() {
        notification.notificationOccurred(.error)
        if let pic = self.picPreview {
            pic.removeFromSuperview()
        }
        self.removeWhiteScreen()
        self.view.removeFromSuperview()
        self.removeFromParent()
        self.didMove(toParent: nil)
        self.dismiss(animated: true, completion: nil)
        if let callback = self.callBack {
            return callback(convert(photo: taken))
        }
    }

    // MARK: Placement
    func positionPreAnimation(in parentVC: UIViewController ) {
        let parentHeight = parentVC.view.frame.size.height
        let suggested = getFrame(for: parentVC.view.frame.size)

        view.frame = CGRect(x: 0, y: parentHeight, width: suggested.width, height: suggested.height)
        view.center.x = parentVC.view.center.x
        view.centerXAnchor.constraint(equalTo: parentVC.view.centerXAnchor)
        self.view.layoutIfNeeded()
    }

    func position(in parentVC: UIViewController ) {
        let parentHeight = parentVC.view.frame.size.height
        let suggested = getFrame(for: parentVC.view.frame.size)

        view.frame = CGRect(x: 0, y: parentHeight - suggested.height , width: suggested.width, height: suggested.height)
        view.center.x = parentVC.view.center.x
        view.translatesAutoresizingMaskIntoConstraints = false
        let heightAnchor = view.heightAnchor.constraint(equalToConstant: suggested.height)
        heightAnchor.priority = .init(750)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: parentVC.view.centerXAnchor),
            view.widthAnchor.constraint(equalToConstant: suggested.width),
            heightAnchor,
            view.bottomAnchor.constraint(equalTo: parentVC.view.bottomAnchor),
            view.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: parentVC.view.topAnchor, multiplier: 5)
        ])

        self.view.layoutIfNeeded()
    }

    func place(with size: CGSize) {
        let suggested = getFrame(for: size)
        self.view.frame = CGRect(x: 0, y: size.height - suggested.height , width: suggested.width, height: suggested.height)
        self.view.layoutIfNeeded()
    }

    func getFrame(for size: CGSize) -> CGRect {
        self.view.layoutIfNeeded()
        if size.width > size.height {
            //landscape
            let basicHeight = size.height - displayPadding
            let width = (basicHeight * 4) / 3
            return CGRect(x: 0, y: 0, width: width, height: basicHeight)
        } else {
            //portrait
            let width =  size.width - displayPadding
            let height = (width * 4) / 3
            return CGRect(x: 0, y: 0, width: width, height: height)
        }
    }

    func addPreviewConstraints(to: UIView) {
        to.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            to.leadingAnchor.constraint(equalTo: self.cameraContainere.leadingAnchor),
            to.trailingAnchor.constraint(equalTo: self.cameraContainere.trailingAnchor),
            to.bottomAnchor.constraint(equalTo: self.cameraContainere.bottomAnchor)
        ])
    }

    func addImagePreviewConstraints(to: UIView) {
        to.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            to.leadingAnchor.constraint(equalTo: self.cameraContainere.leadingAnchor),
            to.trailingAnchor.constraint(equalTo: self.cameraContainere.trailingAnchor),
            to.bottomAnchor.constraint(equalTo: self.cameraContainere.bottomAnchor),
            to.topAnchor.constraint(equalTo: self.cameraContainere.topAnchor)
        ])
    }

    // MARK: Style
    func style() {
        if self.captureButton == nil {return}
        self.cameraContainere.backgroundColor = primaryColor
        cameraContainere.clipsToBounds = true
        self.view.clipsToBounds = true
        styleContainer(layer: cameraContainere)
        makeCircle(view: captureButton)
        captureButton.setTitleColor(textColor, for: .normal)
        captureButton.backgroundColor = primaryColor
        styleContainer(layer: self.view)
    }

    func styleContainer(layer: UIView) {
        roundTopCorners(view: layer)
        addShadow(to: view.layer, opacity: 0.4, height: 2)
    }

    func addShadow(to layer: CALayer, opacity: Float, height: Int, radius: CGFloat? = 10) {
        layer.borderColor = shadowColor
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowColor = shadowColor
        layer.shadowOpacity = opacity
        var r: CGFloat = 10
        if let radius = radius {
            r = radius
        }
        layer.shadowRadius = r
    }

    func makeCircle(view: UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
    }

    func roundTopCorners(view: UIView) {
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

    func convert(photo: AVCapturePhoto?) -> Photo? {
        guard let photo = photo, let cgImageRepresentation = photo.cgImageRepresentation(), let orientationOnCapture = deviceOrientationOnCapture else {
            return nil
        }

        let cgImage = cgImageRepresentation.takeUnretainedValue()

        guard let copy = cgImage.copy() else {
            return nil
        }

        let img = UIImage(cgImage: copy, scale: 1.0, orientation: orientationOnCapture.getUIImageOrientationFromDevice())

        let processed = Photo(image: img, timeStamp: photo.timestamp, metadata: photo.metadata)

        return processed
    }

    func showPreview(of avCapturePhoto: AVCapturePhoto) {
        guard let photo = convert(photo: avCapturePhoto), let image = photo.image, let videoPreview = videoPreviewLayer else {return}
        let imageView = UIImageView(frame: self.cameraContainere.frame)
        imageView.tag = imagePreviewTag
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
//        self.view.insertSubview(imageView, aboveSubview: videoPreview)
//        self.view.addSubview(imageView)
//        self.view.addSubview(captureButton)
//        self.view.addSubview(closeButton)

        previewing = true
        self.view.insertSubview(imageView, aboveSubview: videoPreview)
        addImagePreviewConstraints(to: imageView)
        UIView.animate(withDuration: animationDuration, animations: {
            videoPreview.alpha = 0
            self.captureButton.setTitle("Accept", for: .normal)
            self.closeButton.setTitle("Back", for: .normal)
            self.view.layoutIfNeeded()
        }) { (done) in
            self.view.addSubview(self.captureButton)
            self.view.addSubview(self.closeButton)
        }
    }

}

extension CamViewController: AVCapturePhotoCaptureDelegate {

    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("taken")
        self.taken = photo
        showPreview(of: photo)
        self.captureButton.isEnabled = true
//        close()
    }
}
