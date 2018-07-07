//
//  BarcodeViewController.swift
//  BookCase
//
//  Created by Craig Grummitt on 6/05/2016.
//  Copyright © 2016 Craig Grummitt. All rights reserved.
//

import UIKit
import AVFoundation

protocol BarcodeViewControllerDelegate {
    func foundBarcode(barcode:String)
}

class BarcodeViewController: UIViewController {
    var captureSession:AVCaptureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate:BarcodeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get video camera
        let cameraDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        guard let videoInput =
            try? AVCaptureDeviceInput(device: cameraDevice!)
            else {
                failed()
                return
        }
        
        //add video camera input to capture session
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {failed();return}
        
        //Bar code detector
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
        } else {failed();return}
        
        //Customize metadata output
        metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13]
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        captureSession.startRunning()
        
        //Add preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.frame
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func failed() {
        let ac = UIAlertController(title: "Barcode detection not supported",
            message: "Your device doesn't support barcode detection.",
            preferredStyle: .alert)
        let alert = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        ac.addAction(alert)
        present(ac, animated: true, completion: nil)
    }
    @IBAction func touchCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
}
extension BarcodeViewController:AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            captureSession.stopRunning()
            delegate?.foundBarcode(barcode: metadataObject.stringValue!)
            dismiss(animated: true, completion: nil)
        }
    }
}
