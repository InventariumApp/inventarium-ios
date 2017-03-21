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
    var barcodenum:String? = nil
    var product:String? = nil

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
    
    func lookupBarcode(barcode:String, completion: @escaping (_ result : String?)->()) {
        //let barcode = "0008817013220" // TODO: REMOVE!
        let barcodeEndpoint: String = "http://159.203.166.121:8080/product_name?barcode=\(barcode)"
        guard let url = URL(string: barcodeEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession.shared

        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                // now we have the todo
                // let's just print it to prove we can access it
                
                guard let productName = todo["clean_nm"] as? String else {
                    print("Could not get product name from JSON")
                    return
                }
                
//                var result:String = ""
//                
//                if let productBrand = todo["brand_nm"] as? String {
//                    result = "\(productBrand) \(productName)"
//                } else {
//                    result = productName
//                }
                
                completion(productName)
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
        // gtin_nm
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            barcodeFrameView?.frame = CGRect.zero
            return
        }
        
        if barcodenum == nil {
            messageLabel.text = "No barcode is detected"
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeEAN13Code || metadataObj.type == AVMetadataObjectTypeUPCECode {
            // If the found metadata is equal to the barcode metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            barcodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                if barcodenum != metadataObj.stringValue {
                    self.messageLabel.text = "Barcode Detected"
                    lookupBarcode(barcode: metadataObj.stringValue) { product  in
                        if let product = product {
                            print(product)
                            DispatchQueue.main.async {
                                self.product = product
                                self.performSegue(withIdentifier: "barcodeToAddItemSegue", sender: self)
                            }
                        }
                    }
                    barcodenum = metadataObj.stringValue
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "barcodeToAddItemSegue" {
            let navigationViewController = (segue.destination as! UINavigationController)
            let newItemTableViewController = navigationViewController.topViewController as! NewItemTableViewController
            print("%@$## \(self.product)")
            newItemTableViewController.prefilledItemName = self.product!
            navigationViewController.view.tintColor = UIColor.black
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
