//
//  CreateVideoVC.swift
//  MustacheFun
//
//  Created by Nihal Erdal on 8/3/22.
//

import UIKit
import RealityKit
import ARKit
import AVFoundation
import CoreData

class ViewController: UIViewController, NSFetchedResultsControllerDelegate{
  
    var video: Video!
    var dataController : DataController!
    var fetchedResultsController: NSFetchedResultsController<Video>!
  
    var captureSession: AVCaptureSession?
    var camera: AVCaptureDevice?
    var microphone: AVCaptureDevice?
    var videoOutput: AVCaptureMovieFileOutput?
    var preview: AVCaptureVideoPreviewLayer?
    
//    var faceAnchor: Experience.Mustache1?

    @IBOutlet weak var arView: ARView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if configureSession() {
            configurePreview()
            startSession()
            
        }
     
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
       configureSession()
        
        let configuration = ARFaceTrackingConfiguration()
        
//                check if it is supported
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
       
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
        
    func configureDevices(){
        
        camera = nil
        microphone = nil
        
        let session = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInTrueDepthCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.front)
        var devices = session.devices.compactMap({$0})
        let session2 = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInMicrophone], mediaType: AVMediaType.audio, position: .unspecified)
        devices.append(contentsOf: session2.devices.compactMap({$0}))
        
        for device in devices {
            if device.position == .front{
                self.camera = device
            } else if  device.hasMediaType(.audio){
                    self.microphone = device
                }
            }
        }
    
    func configureSession() -> Bool{
        guard let captureSession = captureSession else {return false}
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        configureDevices()
        
        if let camera = camera {
            do {
                let cameraInput = try AVCaptureDeviceInput(device: camera)
                captureSession.addInput(cameraInput)
            }catch{
                error.localizedDescription
                return false
            }
        }
        
        if let microphone = microphone {
            do {
                let audioInput = try AVCaptureDeviceInput(device: microphone)
                captureSession.addInput(audioInput)
            }catch{
                error.localizedDescription
                return false
            }
        }
        
        guard let videoOutput = videoOutput else {return false}
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }else{
            print("error")
            return false
        }
        return true
    }
    
    func configurePreview(){
        
        guard let captureSession = captureSession else {return}

        preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview?.videoGravity = .resizeAspect
        preview?.frame = arView.bounds
        arView.layer.addSublayer(preview!)

    }
    
    func startSession() {
        
        guard let captureSession = captureSession else {return}
        
        if !captureSession.isRunning {
            DispatchQueue.main.async {
                captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        guard let captureSession = captureSession else {return}
        if captureSession.isRunning {
            DispatchQueue.main.async {
                captureSession.stopRunning()
            }
        }
    }
    
    
    @IBAction func mustache1Pressed(_ sender: Any) {
        arView.scene.anchors.removeAll()
        let anchor = try! Experience.loadMustache1()
        arView.scene.anchors.append(anchor)
    }
    
    @IBAction func button2Pressed(_ sender: Any) {
        arView.scene.anchors.removeAll()
        let anchor = try! Experience.loadMustache2()
        arView.scene.anchors.append(anchor)
    }
    
    @IBAction func button3Pressed(_ sender: Any) {
        arView.scene.anchors.removeAll()
        let anchor = try! Experience.loadMustache3()
        arView.scene.anchors.append(anchor)
    }
    
    @IBAction func recordButtonpressed(_ sender: Any) {
        
        print("button pressed")
        recordButton.isEnabled = false
        stopButton.isEnabled = true
        
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        
        if videoOutput?.isRecording == true {
            videoOutput?.stopRecording()
        }
        configureAlert()
    }
    
    func configureAlert(){
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Video Tag", message: "Please enter a tag", preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Enter a tag"
            textField = alertTextField
        }
        
        let actionSave = UIAlertAction(title: "Save", style: .default) { [self] action in
            
            guard let text = textField.text else {return}
            
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileUrl = paths[0].appendingPathComponent(text)
            try? FileManager.default.removeItem(at: fileUrl)
            self.videoOutput?.startRecording(to: fileUrl, recordingDelegate: self)
            
           
            let video = Video(context: self.dataController.viewContext)
            video.creationDate = Date()
            video.tag = text
            video.video = fileUrl.path
            video.preview = nil
            video.duration = 0.0
            
            do {
                try self.dataController.viewContext.save()
            }catch{
                fatalError("Unable to save photos: \(error.localizedDescription)")
            }
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .default) { action in
            self.dismiss(animated:true, completion:  nil)
        }
        
        alert.addAction(actionSave)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController: AVCaptureFileOutputRecordingDelegate{
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
        }
        
    }
}
