//
//  CreateVideoVC.swift
//  MustacheFun
//
//  Created by Nihal Erdal on 8/3/22.
//

import UIKit
import RealityKit
import ARKit
import AVKit

class ViewController: UIViewController {
    
    
    var faceAnchor: Experience.Mustache1?

    @IBOutlet weak var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        let configuration = ARFaceTrackingConfiguration()
        
//                check if it is supported
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
       
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
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
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
    }
    
}

