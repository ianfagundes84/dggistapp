//
//  ScannerViewController.swift
//  GistApp
//
//  Created by Ian Fagundes on 24/03/21.
//

import UIKit
import Vision
import AVFoundation

class ScannerViewController: UIViewController {

    var captureSession = AVCaptureSession()
    var comments: Comment!
    
    lazy var detectBarcodeRequest = VNDetectBarcodesRequest { request, error in
        guard error == nil else {
            self.showAlert(withTitle: "Barcode error", message: error?.localizedDescription ?? "error")
            return
        }
        self.processClassification(request)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: Delete this call
        checkPermissions()
        setupCameraLiveView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentsSegue" {
            if let destinationVC = segue.destination as? CommentsTableViewController {
                destinationVC.comments = comments ?? []
            }
        }
    }
    
    //MARK: - Permissions
    //TODO: Direct to setings
    private func checkPermissions() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [self] enable in
                if !enable {
                    showPermissionsAlert()
                }
            }
        case .denied, .restricted:
            showPermissionsAlert()
        default:
            return
        }
    }
    
    //MARK: - SetupCameraLive (Input, Output)
    private func setupCameraLiveView() {
        //input region
        captureSession.sessionPreset = .hd1280x720
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        
        guard let device = videoDevice, let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(videoDeviceInput) else {
            showAlert(withTitle: "Cannot Find Camera", message: "There seems to be a problem with the camera.")
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        
        //output region
        let captureOutput = AVCaptureVideoDataOutput()
        
        captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        captureSession.addOutput(captureOutput)
        
        //configure preview
        configurePreviewLayer()
        
        captureSession.startRunning()
    }
    
    //MARK: - Classification Algorith
    func processClassification(_ request: VNRequest) {
        guard let barcodes = request.results else { return }
        DispatchQueue.main.async { [self] in
            if captureSession.isRunning {
                view.layer.sublayers?.removeSubrange(1...)
                
                for barcode in barcodes {
                    guard
                        let potentialQRCode = barcode as? VNBarcodeObservation,
                        potentialQRCode.symbology == .QR,
                        potentialQRCode.confidence > 0.9
                        else { return }
                    self.observationHandler(payload: potentialQRCode.payloadStringValue)
                }
            }
        }
    }
    
    func observationHandler(payload: String?) {
        if let _ = payload {
            captureSession.stopRunning()
            APIManager.shared.getComments { result in
                switch result {
                case .success(let comments):
                    self.comments = comments
                    self.performSegue(withIdentifier: "commentsSegue", sender: nil)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

//MARK: - AVCaptureDelegate
extension ScannerViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard  let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let imageHandlerRequest = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right)
        
        do {
            try imageHandlerRequest.perform([detectBarcodeRequest])
        } catch {
            print(error)
        }
    }
}

//MARK: - Extension Alerts, Configure preview
extension ScannerViewController {
  private func configurePreviewLayer() {
    let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    cameraPreviewLayer.videoGravity = .resizeAspectFill
    cameraPreviewLayer.connection?.videoOrientation = .portrait
    cameraPreviewLayer.frame = view.frame
    view.layer.insertSublayer(cameraPreviewLayer, at: 0)
  }
  
  private func showAlert(withTitle title: String, message: String) {
    DispatchQueue.main.async {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: .default))
      self.present(alertController, animated: true)
    }
  }
  
  private func showPermissionsAlert() {
    showAlert(
      withTitle: "Camera Permissions",
      message: "Please open Settings and grant permission for this app to use your camera.")
  }
}
