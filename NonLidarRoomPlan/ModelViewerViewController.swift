import UIKit
import SceneKit

class ModelViewerViewController: UIViewController {
    var modelURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Create SceneKit view
        let sceneView = SCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.allowsCameraControl = true // Enable gestures

        if let modelURL = modelURL {
            let scene = try? SCNScene(url: modelURL, options: nil)
            sceneView.scene = scene
            sceneView.backgroundColor = UIColor.black

            if let scene = scene {
                // 🔹 Add lighting to the scene
                let lightNode = SCNNode()
                let light = SCNLight()
                light.type = .omni
                light.intensity = 1000
                lightNode.light = light
                lightNode.position = SCNVector3(x: 0, y: 5, z: 5)
                scene.rootNode.addChildNode(lightNode)
                
                // Create a sphere to visualize the light position
                let sphereGeometry = SCNSphere(radius: 0.1)
                let sphereMaterial = SCNMaterial()
                sphereMaterial.diffuse.contents = UIColor.yellow // Make it visible
                sphereGeometry.materials = [sphereMaterial]
                let sphereNode = SCNNode(geometry: sphereGeometry)
                sphereNode.position = lightNode.position // Match light position
                let particles = SCNParticleSystem()
                particles.particleImage = UIImage(systemName: "sparkle") // Use a system image
                particles.birthRate = 50
                particles.particleLifeSpan = 2.0
                particles.speedFactor = 0.2
                particles.particleSize = 0.1
                particles.emissionDuration = 0.5
                sphereNode.addParticleSystem(particles)
                scene.rootNode.addChildNode(sphereNode)
                
                let ambientLight = SCNLight()
                ambientLight.type = .ambient
                ambientLight.intensity = 500
                let ambientLightNode = SCNNode()
                ambientLightNode.light = ambientLight
                scene.rootNode.addChildNode(ambientLightNode)
                
                sceneView.scene = scene
            }
        }

        view.addSubview(sceneView)
        
        createDismissButton()
    }
    
    func createDismissButton() {
        
        let showModelButton = UIButton(type: .system)
        showModelButton.setTitle("Dismiss", for: .normal)
        showModelButton.frame = CGRect(x: 20, y: 20, width: 80, height: 50)
        showModelButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        
        // Customize button appearance (optional)
        showModelButton.backgroundColor = UIColor.yellow.withAlphaComponent(0.7)
        showModelButton.setTitleColor(UIColor.black, for: .normal)
        showModelButton.layer.cornerRadius = 10
        
        
        // Add button to the view
        self.view.addSubview(showModelButton)
    }
    
    @objc
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
        
    }
}
