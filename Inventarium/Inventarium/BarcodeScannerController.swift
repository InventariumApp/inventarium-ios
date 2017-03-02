//
//  BarcodeScannerController.swift
//  Inventarium
//
//  Created by Michael Rosenfield on 3/2/17.
//  Copyright © 2017 Inventarium. All rights reserved.
//

import UIKit
import AVFoundation

class BarcodeScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var barcodeFrameView:UIView?
    
    @IBOutlet weak var topbar: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get instance of AVCaptureDevice class to initialize a device object
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeEAN13Code]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: topbar)
            
            // Start video capture 
            captureSession?.startRunning()
            
            // Initialize barcode Frame to highlight the barcode
            barcodeFrameView = UIView()
            
            if let barcodeFrameView = barcodeFrameView {
                barcodeFrameView.layer.borderColor = UIColor.green.cgColor
                barcodeFrameView.layer.borderWidth = 2
                view.addSubview(barcodeFrameView)
                view.bringSubview(toFront: barcodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            barcodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No barcode is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeEAN13Code || metadataObj.type == AVMetadataObjectTypeUPCECode {
            // If the found metadata is equal to the barcode metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            barcodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
