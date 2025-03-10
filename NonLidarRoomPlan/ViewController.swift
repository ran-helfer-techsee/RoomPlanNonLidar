//
//  ViewController.swift
//  NonLidarRoomPlan
//
//  Created by Ran Helfer on 11/02/2025.
//

import UIKit
import ARKit
import SceneKit
import SwiftUI

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var lastTappedLocation: SCNVector3?
    var roomNodes: [SCNNode] = []
    var markerNodes: [SCNNode] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        // Create and add tap gesture recognizer to the sceneView
          let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addRoomCorner(_:)))
          sceneView.addGestureRecognizer(tapGesture)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
        
        // Create the clear button programmatically for all nodes
        createClearButton()
        
        createShow3DModelButton()
        
        createShow3SavedModelsButton()

        
        sceneView.play(nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Restart the session if needed
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate methods
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Update the scene if necessary
    }
    
    @IBAction func addRoomCorner(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: sceneView)
        guard let query = sceneView.raycastQuery(from: tapLocation, allowing: .existingPlaneGeometry, alignment: .horizontal) else {
            return
        }

        let results = sceneView.session.raycast(query)

        if let result = results.first {
            let position = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
            placeRoomMarker(at: position)
        }
    }

    func placeRoomMarker(at position: SCNVector3) {
        // Create a marker (small sphere)
        let marker = SCNSphere(radius: 0.03)
        let markerNode = SCNNode(geometry: marker)
        markerNode.position = position
        sceneView.scene.rootNode.addChildNode(markerNode)
        markerNodes.append(markerNode)
        
        if let lastPosition = lastTappedLocation {
            let distance = distanceBetween(lastPosition, position)
            print("Distance between points: \(distance) meters")
            
            // Optionally, create walls or boundaries here.
            addWallBetween(lastPosition, position)
        }

        // Update lastTappedLocation
        lastTappedLocation = position
    }
    
    func distanceBetween(_ point1: SCNVector3, _ point2: SCNVector3) -> Float {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        let dz = point2.z - point1.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }

    func addWallBetween(_ start: SCNVector3, _ end: SCNVector3) {
        // Compute midpoint
        let midpoint = SCNVector3(
            (start.x + end.x) / 2,
            (start.y + end.y) / 2,
            (start.z + end.z) / 2
        )

        // Compute wall length
        let dx = end.x - start.x
        let dy = end.y - start.y
        let dz = end.z - start.z
        let wallLength = sqrt(dx * dx + dy * dy + dz * dz)

        // Create the wall geometry
        let wallGeometry = SCNBox(width: 0.1, height: 2.0, length: CGFloat(wallLength), chamferRadius: 0.0)

        // Set material
        let wallMaterial = SCNMaterial()
        wallMaterial.diffuse.contents = UIColor.yellow.withAlphaComponent(0.5) // Semi-transparent gray
        wallGeometry.materials = [wallMaterial]

        // Create wall node and position it
        let wallNode = SCNNode(geometry: wallGeometry)
        wallNode.position = midpoint

        // Compute the direction vector (normalized)
        let direction = SCNVector3(dx / wallLength, dy / wallLength, dz / wallLength)

        // Default axis (SceneKit's SCNBox is aligned with Z by default)
        let defaultAxis = SCNVector3(0, 0, 1)

        // Compute rotation axis using cross product
        let rotationAxis = SCNVector3(
            defaultAxis.y * direction.z - defaultAxis.z * direction.y,
            defaultAxis.z * direction.x - defaultAxis.x * direction.z,
            defaultAxis.x * direction.y - defaultAxis.y * direction.x
        )

        // Compute rotation angle using dot product
        let dotProduct = defaultAxis.x * direction.x + defaultAxis.y * direction.y + defaultAxis.z * direction.z
        let angle = acos(dotProduct) // Angle in radians

        // Apply rotation using SCNVector4 (axis-angle representation)
        wallNode.rotation = SCNVector4(rotationAxis.x, rotationAxis.y, rotationAxis.z, angle)

        self.roomNodes.append(wallNode)
        
        // Add wall to the scene
        sceneView.scene.rootNode.addChildNode(wallNode)
        
        let labelNode = createWallLabel(text: String(format: "%.1f", wallLength))
        
        labelNode.position = SCNVector3(0, 1.0, 0) // Offset label above the wall
        wallNode.addChildNode(labelNode)
    }

    func createWallLabel(text: String) -> SCNNode {
        let textGeometry = SCNText(string: text, extrusionDepth: 0.02) // Make text thinner
        textGeometry.font = UIFont.systemFont(ofSize: 2.0) // Increase font size
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white

        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3(0.1, 0.1, 0.1) // Increase scale

        // Ensure text faces the camera
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .all
        textNode.constraints = [billboardConstraint]

        return textNode
    }

    
    // MARK: - Clear All Nodes (Programmatically)
    @objc func clearAllNodes() {
        
        guard (roomNodes + markerNodes).isEmpty == false else {
            return
        }
        
        for node in (roomNodes + markerNodes) {
            node.geometry = nil
            node.removeFromParentNode()
        }
        
        // Clear the array storing the room nodes
        markerNodes = []
        roomNodes = []
        lastTappedLocation = nil
        
        print("All nodes cleared.")
    }
    
    // MARK: - Create Clear Button Programmatically
    func createClearButton() {
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("Clear All", for: .normal)
        clearButton.frame = CGRect(x: 20, y: 40, width: 100, height: 50)
        clearButton.addTarget(self, action: #selector(clearAllNodes), for: .touchUpInside)
        
        // Customize button appearance (optional)
        clearButton.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        clearButton.setTitleColor(UIColor.white, for: .normal)
        clearButton.layer.cornerRadius = 10
        
        // Add button to the view
        self.view.addSubview(clearButton)
    }
    
    // MARK: - Clear All Nodes (Programmatically)
    @objc func show3DModel() {
        let modelVC = ModelViewController()
        modelVC.wallNodes = roomNodes // Pass the created walls to the new view controller
        present(modelVC, animated: true, completion: nil)
    }
    
    func createShow3DModelButton() {
        
        let showModelButton = UIButton(type: .system)
        showModelButton.setTitle("Show", for: .normal)
        showModelButton.frame = CGRect(x: 140, y: 40, width: 100, height: 50)
        showModelButton.addTarget(self, action: #selector(show3DModel), for: .touchUpInside)
        
        // Customize button appearance (optional)
        showModelButton.backgroundColor = UIColor.green.withAlphaComponent(0.7)
        showModelButton.setTitleColor(UIColor.white, for: .normal)
        showModelButton.layer.cornerRadius = 10
        
        // Add button to the view
        self.view.addSubview(showModelButton)
    }
    
    func createShow3SavedModelsButton() {
        guard listSavedModels().count > 0 else  {
            return
        }
        
        let showModelButton = UIButton(type: .system)
        showModelButton.setTitle("List", for: .normal)
        showModelButton.frame = CGRect(x: 250, y: 40, width: 80, height: 50)
        showModelButton.addTarget(self, action: #selector(showPrevious3DModelList), for: .touchUpInside)
        
        // Customize button appearance (optional)
        showModelButton.backgroundColor = UIColor.yellow.withAlphaComponent(0.7)
        showModelButton.setTitleColor(UIColor.black, for: .normal)
        showModelButton.layer.cornerRadius = 10
        
        
        // Add button to the view
        self.view.addSubview(showModelButton)
    }
    
    @objc func showPrevious3DModelList() {
        let savedModels = listSavedModels()
          let swiftUIView = SavedModelsListView(models: savedModels)
          let hostingController = UIHostingController(rootView: swiftUIView)
          
          present(hostingController, animated: true)
    }
    
    func listSavedModels() -> [URL] {
        let fileManager = FileManager.default
        let directoryURL = fileManager.temporaryDirectory  // Or any other directory where you save the files

        do {
            // Get all files in the directory
            let allFiles = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)

            // Filter the files for USDZ files
            let usdzFiles = allFiles.filter { $0.pathExtension == "usdz" }

            return usdzFiles
        } catch {
            print("Failed to list files: \(error)")
            return []
        }
    }
}
