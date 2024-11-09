import SwiftUI
import ARKit
import RealityKit

struct ContentView: View {
    @State private var isPlacingModel = false
    @State private var selectedEntity: ModelEntity?
    @State private var selectedModelName: String = "plant.usdz"  // Default model selection
    
    var body: some View {
        ZStack {
            ARViewContainer(isPlacingModel: $isPlacingModel, selectedEntity: $selectedEntity, selectedModelName: $selectedModelName)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Delete button overlay that only shows if an entity is selected
                if selectedEntity != nil {
                    Button(action: {
                        selectedEntity?.removeFromParent()
                        selectedEntity = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.largeTitle)
                            .padding()
                    }
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                }
                
                // Plant selection and Add Button
                HStack {
                    Picker("Select Plant", selection: $selectedModelName) {
                        Text("Plant").tag("pancakes.usdz")
                        Text("Tulip").tag("flower_tulip.usdz")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    Button("Add Selected Plant") {
                        isPlacingModel.toggle()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var isPlacingModel: Bool
    @Binding var selectedEntity: ModelEntity?
    @Binding var selectedModelName: String
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Set up AR session
        let config = ARWorldTrackingConfiguration()
        
        // Enable horizontal plane detection
        config.planeDetection = [.horizontal]
        
        // Enable environment texturing
        config.environmentTexturing = .automatic
        
        // Run the AR session
        arView.session.run(config)
        
        // Set AR session delegate
        arView.session.delegate = context.coordinator
        
        // Add gesture recognizers
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didPanARView(_:)))
        arView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didPinchARView(_:)))
        arView.addGestureRecognizer(pinchGesture)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didTapEntity(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        context.coordinator.arView = arView
        context.coordinator.isPlacingModel = $isPlacingModel
        context.coordinator.selectedEntity = $selectedEntity
        context.coordinator.selectedModelName = $selectedModelName
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}

class Coordinator: NSObject, ARSessionDelegate {
    var arView: ARView?
    var selectedEntity: Binding<ModelEntity?>?
    var isPlacingModel: Binding<Bool>?
    var selectedModelName: Binding<String>?

    // Place the model when the "Add Selected Plant" button is tapped
    func placeModel() {
        guard let arView = arView, let modelName = selectedModelName?.wrappedValue else { return }
        
        // Perform a raycast to find a horizontal plane
        if let result = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal).first {
            do {
                let plantEntity = try ModelEntity.loadModel(named: modelName)
                
                // Set initial small scale
                plantEntity.scale = SIMD3(0.05, 0.05, 0.05)
                
                // Enable touch interactions by generating collision shapes
                plantEntity.generateCollisionShapes(recursive: true)
                
                // Place the model at the raycast result position
                let anchorEntity = AnchorEntity(world: result.worldTransform.translation)
                anchorEntity.addChild(plantEntity)
                arView.scene.addAnchor(anchorEntity)
                
                // Set the newly placed model as the active entity
                selectedEntity?.wrappedValue = plantEntity
                isPlacingModel?.wrappedValue = false
            } catch {
                print("Error loading model: \(error)")
            }
        }
    }
    
    // Enable dragging to move the object
    @objc func didPanARView(_ sender: UIPanGestureRecognizer) {
        guard let arView = arView, let selectedEntity = selectedEntity?.wrappedValue else { return }
        
        let panLocation = sender.location(in: arView)
        
        // Raycast from screen point to determine the new position for more accurate dragging
        if let result = arView.raycast(from: panLocation, allowing: .estimatedPlane, alignment: .horizontal).first {
            selectedEntity.setPosition(result.worldTransform.translation, relativeTo: nil)
        }
    }
    
    // Enable pinch gesture for resizing
    @objc func didPinchARView(_ sender: UIPinchGestureRecognizer) {
        guard let selectedEntity = selectedEntity?.wrappedValue else { return }
        
        if sender.state == .changed {
            let pinchScale = Float(sender.scale)
            selectedEntity.scale *= SIMD3(pinchScale, pinchScale, pinchScale)
            sender.scale = 1.0
        }
    }
    
    // Handle tap to select an entity without immediately deleting it
    @objc func didTapEntity(_ sender: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        
        let tapLocation = sender.location(in: arView)
        
        // Check if an entity was tapped
        if let entity = arView.entity(at: tapLocation) as? ModelEntity {
            // Set the tapped entity as the selected entity to show the delete button
            selectedEntity?.wrappedValue = entity
        } else {
            // If no entity was tapped, deselect any selected entity
            selectedEntity?.wrappedValue = nil
        }
    }
    
    // ARSessionDelegate method to detect plane updates and automatically place the model if `isPlacingModel` is true
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if isPlacingModel?.wrappedValue == true {
            placeModel()
        }
    }
}

extension float4x4 {
    /// Convenience to get the translation vector from a `float4x4` matrix.
    var translation: SIMD3<Float> {
        return SIMD3(self.columns.3.x, self.columns.3.y, self.columns.3.z)
    }
}
