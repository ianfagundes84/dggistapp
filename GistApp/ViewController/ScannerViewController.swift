//
//  ScannerViewController.swift
//  GistApp
//
//  Created by Ian Fagundes on 24/03/21.
//

import UIKit
import Vision
import AVFoundation
import TransitionButton
import Lottie

enum StringScannedError: Error {
    case isNotURL
    case urlIsNotValid
}

class ScannerViewController: CustomTransitionViewController {
    
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
        navigationController?.title = "Scanner"
        
        //TODO: Delete this call
        checkPermissions()
        setupCameraLiveView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        customizeNavBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentsSegue" {
            if let destinationVC = segue.destination as? CommentsTableViewController {
                destinationVC.comments = comments ?? []
                destinationVC.reference = self
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
        
        captureSession.stopRunning()
        
        if let existentGist = payload {
            do {
                let stringToCompare = try splitter(existentGist)
                if stringToCompare == "\(APIConstants.gistID)" {
                    APIManager.shared.getComments { result in
                        switch result {
                        case .success(let comments):
                            self.comments = comments
                            self.performSegue(withIdentifier: "commentsSegue", sender: nil)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                } else {
                    scannerAlertError()
                }
            } catch  {
                scannerAlertError()
            }
        }
    }
    
    func splitter(_ existentGist: String) throws -> String? {
        
        let countFirstSplit = existentGist.split(separator: "/").count
        
        if countFirstSplit > 2 {
            if existentGist.split(separator: "/")[2].split(separator: ".").count > 1 {
                return "\(existentGist.split(separator: "/")[2].split(separator: ".")[0])"
            }
            throw StringScannedError.isNotURL
        }
        throw StringScannedError.isNotURL
    }
    
    func scannerAlertError() {
        let ac = UIAlertController(title: "Feedback", message: "Code used is not the right one", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Exit", style: .destructive) { [weak self] action in
            self?.navigationController?.setNavigationBarHidden(true, animated: true)
            self?.navigationController?.popViewController(animated: true)
        }
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    @IBAction func dismissViewController(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func restartTapped() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.popViewController(animated: true)
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
    
    private func customizeNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemIndigo
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(restartTapped))
    }
}

extension ScannerViewController: ScannerProtocol {
    func restartCaptureSession() {
        captureSession.startRunning()
    }
}

