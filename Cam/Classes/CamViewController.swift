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

    // MARK: Variables
    var captureSession: AVCaptureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    // MARK: Outlet
    @IBOutlet weak var cameraContainer: UIView!
    @IBOutlet weak var captureButton: UIButton!

    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
         captureSession.stopRunning()
    }
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setup(for: .back)
    }

    // MARK: Outlet Actions
    @IBAction func captureAction(_ sender: UIButton) {

    }

    func setup(for position: AVCaptureDevice.Position) {
        captureSession.beginConfiguration()
        setInput(forDevice: position)
        setOutput()
        setPreviewView()
        captureSession.startRunning()
    }

    func setPreviewView() {
        let preview: PreviewView = UIView.fromNib()
        preview.videoPreviewLayer.session = self.captureSession
        preview.position(in: cameraContainer)
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
        let photoOutput = AVCapturePhotoOutput()
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.isLivePhotoCaptureEnabled = false
        guard self.captureSession.canAddOutput(photoOutput) else { return }
        self.captureSession.sessionPreset = .photo
        self.captureSession.addOutput(photoOutput)
        self.captureSession.commitConfiguration()
//        self.captureSession.startRunning()
    }

    func getCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera,
                                                for: .video, position: position) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video, position: position) {
            return device
        } else {
            fatalError("Missing expected back camera device.")
        }
    }

}
