//
//  CameraManager.swift
//  GalleryApp
//
//  Created by Abhay Shankar on 05/09/18.
//  Copyright © 2018 Abhay Shankar. All rights reserved.
//

import UIKit
import AVFoundation


extension CameraManager{
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
}
class CameraManager: NSObject {
    var previewLayer : AVCaptureVideoPreviewLayer?
    var videoConnection : AVCaptureConnection?
    
    private var session : AVCaptureSession?
    private var captureDevice : AVCaptureDevice?
    
    func initializeCamera()throws {
        if let session = session{
            session.stopRunning()
            self.session = nil
        }
        
        self.session = AVCaptureSession.init()
        captureDevice = nil
        
        for device in AVCaptureDevice.devices(){
            if (device.position == .front) {
                captureDevice = device;
            }
        }
        if captureDevice == nil{
            for device in AVCaptureDevice.devices(){
                if (device.position == .back) {
                    captureDevice = device;
                }
            }
        }
        
        if captureDevice == nil{
            throw CameraControllerError.noCamerasAvailable
        }
        
        do{
            let deviceInput = try AVCaptureDeviceInput.init(device: captureDevice!)

            self.session?.sessionPreset = AVCaptureSession.Preset.photo;
            self.session?.addInput(deviceInput)
            self.previewLayer = AVCaptureVideoPreviewLayer.init(session: self.session!)
            self.previewLayer?.videoGravity = .resizeAspectFill
            self.session?.startRunning()
        }catch let error{
            throw error
        }
    }
    
    func stopSession() {
        self.session?.stopRunning()
    }
    
    func startSession() {
        if let session = self.session, !session.isRunning{
            session.startRunning()
        }
    }
}
