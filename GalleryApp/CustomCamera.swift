//
//  CustomCamera.swift
//  GalleryApp
//
//  Created by Abhay Shankar on 04/09/18.
//  Copyright © 2018 Abhay Shankar. All rights reserved.
//

import UIKit
import AVFoundation

class CustomCamera: NSObject {
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    
    func createCaptureSession() {
        self.captureSession = AVCaptureSession()
    }
    func configureCaptureDevices() {
        
//        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front)
//
//        let cameras = session.devices.compactMap { $0 }
        self.frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)

        guard self.frontCamera != nil else { return }
        
//        for camera in cameras {
//            if camera.position == .front {
//                self.frontCamera = camera
//            }
//        }
    }
    func configureDeviceInputs() {
        guard let captureSession = self.captureSession else { return }
        
        if let frontCamera = self.frontCamera {
            self.frontCameraInput = try! AVCaptureDeviceInput(device: frontCamera)
            
            if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
            else { return }
            
        }
            
        else { return }
    }
    
    func configurePhotoOutput()  {
        guard let captureSession = self.captureSession else { return }
        
        self.photoOutput = AVCapturePhotoOutput()
        self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])], completionHandler: nil)
        
        if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
        captureSession.startRunning()
    }
    
    
    func prepare(completionHandler: @escaping () -> Void) {
        DispatchQueue(label: "prepare").async {
            
            self.createCaptureSession()
            self.configureCaptureDevices()
            self.configureDeviceInputs()
            self.configurePhotoOutput()
           
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
    
    func displayPreview(on view: UIView) {
        guard let captureSession = self.captureSession, captureSession.isRunning else { return }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
}
