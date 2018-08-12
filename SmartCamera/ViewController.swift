//
//  ViewController.swift
//  SmartCamera
//
//  Created by Hubert Wang on 12/08/18.
//  Copyright © 2018 Hubert Wang. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var outputLabel: UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    var outputObject = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        outputLabel.bringSubview(toFront: view)
        
        //Turn on the camera
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        captureSession.addInput(captureInput)
        
        captureSession.startRunning()
        
        //Output the camera
        let liveLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        liveLayer.frame = view.frame
        view.layer.addSublayer(liveLayer)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        //        outputLabel.text = outputObject
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        //        Recognizing objects
        guard let model = try? VNCoreMLModel(for: VGG16().model) else {return}
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in

            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}

            guard let firstObservation = results.first else {return}

            DispatchQueue.main.async(execute: {
                self.outputLabel.text = "\(firstObservation.identifier)"
            })

            //            print(firstObservation.identifier, firstObservation.confidence)
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }


}

