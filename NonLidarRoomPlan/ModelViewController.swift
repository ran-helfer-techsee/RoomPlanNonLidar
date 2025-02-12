//
//  ModelViewController.swift
//  NonLidarRoomPlan
//
//  Created by Ran Helfer on 12/02/2025.
//

import UIKit
import SceneKit

class ModelViewController: UIViewController {
    
    var sceneView: SCNView!
    var wallNodes: [SCNNode] = [] // Walls from the main scene
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create Scene View
        sceneView = SCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(sceneView)
        
        // Create a new scene
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.allowsCameraControl = true // Enable user interaction
        sceneView.backgroundColor = UIColor.black
        
        // Add walls to scene
        for wallNode in wallNodes {
            let clonedWall = wallNode.clone()
            scene.rootNode.addChildNode(clonedWall)
        }
        
        // Add a light source
        let lightNode = SCNNode()
        let light = SCNLight()
        light.type = .ambient
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 5, z: 5)
        scene.rootNode.addChildNode(lightNode)
        
        setupCamera(in: sceneView.scene!)
        
        createCloseButton()
    }
    
    
    // MARK: - Setup Camera
    // TODO: - set initial position better
    func setupCamera(in scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // Set the camera a bit higher and further back
        cameraNode.position = SCNVector3(x: 0, y: 2.5, z: 5)
        
        // Aim the camera toward the center of the scene
        let targetPosition = SCNVector3(x: 0, y: 1, z: 0) // Adjust if needed
        cameraNode.look(at: targetPosition)
        
        // Set camera properties for better visibility
        cameraNode.camera?.fieldOfView = 70 // Adjust if needed
        cameraNode.camera?.automaticallyAdjustsZRange = true
        
        scene.rootNode.addChildNode(cameraNode)
    }

    
    // MARK: - Create Close Button
    func createCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.frame = CGRect(x: 20, y: 40, width: 80, height: 40)
        closeButton.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 8
        closeButton.addTarget(self, action: #selector(closeViewController), for: .touchUpInside)
        
        view.addSubview(closeButton)
    }

    // MARK: - Dismiss ModelViewController
    @objc func closeViewController() {
        dismiss(animated: true, completion: nil)
    }

}
