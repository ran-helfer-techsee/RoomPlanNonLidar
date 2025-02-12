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
        light.type = .omni
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 5, z: 5)
        scene.rootNode.addChildNode(lightNode)
        
        // Add a camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 2, z: 5)
        scene.rootNode.addChildNode(cameraNode)
    }
}
