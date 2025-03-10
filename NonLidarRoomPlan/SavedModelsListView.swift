import SwiftUI

struct SavedModelsListView: View {
    let models: [URL]
    @Environment(\.presentationMode) var presentationMode // To dismiss the SwiftUI view

    var body: some View {
        NavigationView {
            List(models, id: \.self) { model in
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Dismiss SwiftUI view
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Add slight delay to avoid UIKit warning
                        openSceneKitViewer(for: model)
                    }
                }) {
                    Text(model.lastPathComponent)
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle("Saved 3D Models")
        }
    }

    /// Opens SceneKit Viewer using UIKit
    private func openSceneKitViewer(for model: URL) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let topController = window.rootViewController else {
            return
        }

        let viewerVC = ModelViewerViewController()
        viewerVC.modelURL = model
        topController.present(viewerVC, animated: true)
    }
}
