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
    
    var camera: AVCaptureDevice?
    var microphone: AVCaptureDevice?
    
    var captureSession = AVCaptureSession()
    var videoOutput =  AVCaptureMovieFileOutput()
    var preview = AVCaptureVideoPreviewLayer()
    
    @IBOutlet weak var arView: ARView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        recordButton.isEnabled = true
        stopButton.isEnabled = false
        
        let configuration = ARFaceTrackingConfiguration()
        
        //check if it is supported
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        if configureSession() {
            configurePreview()
        }
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
    
    func configureSession() -> Bool {
    
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        configureDevices()
        
        if let camera = camera {
            do {
                let cameraInput = try AVCaptureDeviceInput(device: camera)
                captureSession.addInput(cameraInput)
            } catch {
                error.localizedDescription
                return false
            }
        }
        
        if let microphone = microphone {
            do {
                let audioInput = try AVCaptureDeviceInput(device: microphone)
                captureSession.addInput(audioInput)
            } catch {
                error.localizedDescription
                return false
            }
        }
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }else{
            print("error")
            return false
        }
        return true
    }
    
    func configurePreview(){
        preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.videoGravity = .resizeAspect
        preview.frame = arView.bounds
        arView.layer.addSublayer(preview)
    }
    
    func tempURL()-> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileUrl = paths[0].appendingPathComponent("output.mov")
        try? FileManager.default.removeItem(at: fileUrl)
        return fileUrl
    }
    
    func getDuration(url: URL) -> String {
        let duration = AVURLAsset(url: url).duration.seconds
        print(duration)
        
        let time: String
        if duration > 3600 {
            time = String(format:"%dh %dm %ds",
                          Int(duration/3600),
                          Int((duration/60).truncatingRemainder(dividingBy: 60)),
                          Int(duration.truncatingRemainder(dividingBy: 60)))
        } else {
            time = String(format:"%dm %ds",
                          Int((duration/60).truncatingRemainder(dividingBy: 60)),
                          Int(duration.truncatingRemainder(dividingBy: 60)))
        }
        print(time)
        return time
    }
    
    func startRecording(){
        
        if videoOutput.isRecording == true{
            stopRecording()
        }else{
            let outputURL = tempURL()
            videoOutput.startRecording(to: outputURL, recordingDelegate: self)
        }
    }
    
    func stopRecording(){
        
        if self.videoOutput.isRecording == true {
            videoOutput.stopRecording()
            arView.session.pause()
        }else{
            return
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
        startRecording()
        
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        stopRecording()
        configureAlert()
    }
    
    func videoSnapshot(filePathLocal: String) -> UIImage? {
         let vidURL = URL(fileURLWithPath:filePathLocal as String)
         let asset = AVURLAsset(url: vidURL)
         let generator = AVAssetImageGenerator(asset: asset)
         generator.appliesPreferredTrackTransform = true
         let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
         do {
             let image = try generator.copyCGImage(at: timestamp, actualTime: nil)
             return UIImage(cgImage: image)
         }
         catch let error as NSError
         {
             print("Image generation failed with error \(error)")
             return nil
         }
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
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let video = Video(context: appDelegate.dataController.viewContext)
            video.creationDate = Date()
            video.tag = text
            video.video = tempURL().path
            video.preview = videoSnapshot(filePathLocal: tempURL().path)?.pngData()
            video.duration = getDuration(url: tempURL())
            
            do {
                try appDelegate.dataController.viewContext.save()
            }catch{
                fatalError("Unable to save photos: \(error.localizedDescription)")
            }
            
            dismiss(animated: true, completion: nil)
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
