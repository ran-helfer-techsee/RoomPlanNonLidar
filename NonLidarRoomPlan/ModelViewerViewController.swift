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
        }

        view.addSubview(sceneView)
    }
}
