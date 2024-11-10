import SwiftUI
import ARKit
import RealityKit

struct ARExperienceView: View {
    @State private var isPlacingModel = false
    @State private var selectedEntity: ModelEntity?
    @State private var selectedModelName: String?
    @State private var isPlaneDetected = false
    @State private var plantName: String?
    @State private var isViewAllPresented = false
    @State private var isPlantSelectionExpanded = false
    @State private var showPlaneDetectionPrompt = false
    @State private var isInfoExpanded = false
    @State private var descriptionText: String = ""
    @State private var isLoading = false
    @State private var currentText = ""
    @State private var typingIndex = 0

    let plantModels = [
        "aloe.usdz", "areca.usdz", "arrowhead.usdz", "bamboopalm.usdz",
        "banana.usdz", "bostonfern.usdz", "cactus.usdz", "calathea.usdz",
        "castiron.usdz", "chineseevergreen.usdz", "croton.usdz",
        "dieffenbachia.usdz", "dracaena.usdz", "echeveria.usdz",
        "fiddle.usdz", "garden.usdz", "goldenpothos.usdz", "haworthia.usdz",
        "heartleaf.usdz", "ivy.usdz", "jade.usdz", "ladypalm.usdz",
        "maidenhair.usdz", "money.usdz", "parlorpalm.usdz", "peacelily.usdz",
        "peperomia.usdz", "philodendron.usdz", "pothos.usdz",
        "prayer.usdz", "queenfern.usdz", "rubber.usdz", "silverpothos.usdz",
        "snakeplant.usdz", "spiderplant.usdz", "succulent.usdz",
        "weep.usdz", "yucca.usdz", "zz.usdz"
    ]
    
    let customPlantNames: [String: String] = [
            "aloe.usdz": "Aloe Vera",
            "areca.usdz": "Areca Palm",
            "arrowhead.usdz": "Arrowhead Plant",
            "bamboopalm.usdz": "Bamboo Palm",
            "banana.usdz": "Banana Plant",
            "bostonfern.usdz": "Boston Fern",
            "cactus.usdz": "Cactus",
            "calathea.usdz": "Calathea",
            "castiron.usdz": "Cast Iron Plant",
            "chineseevergreen.usdz": "Chinese Evergreen",
            "croton.usdz": "Croton",
            "dieffenbachia.usdz": "Dieffenbachia",
            "dracaena.usdz": "Dracaena",
            "echeveria.usdz": "Echeveria",
            "fiddle.usdz": "Fiddle Leaf Fig",
            "garden.usdz": "Garden Plant",
            "goldenpothos.usdz": "Golden Pothos",
            "haworthia.usdz": "Haworthia",
            "heartleaf.usdz": "Heartleaf Philodendron",
            "ivy.usdz": "English Ivy",
            "jade.usdz": "Jade Plant",
            "ladypalm.usdz": "Lady Palm",
            "maidenhair.usdz": "Maidenhair Fern",
            "money.usdz": "Money Tree",
            "parlorpalm.usdz": "Parlor Palm",
            "peacelily.usdz": "Peace Lily",
            "peperomia.usdz": "Peperomia",
            "philodendron.usdz": "Philodendron",
            "pothos.usdz": "Pothos",
            "prayer.usdz": "Prayer Plant",
            "queenfern.usdz": "Queen Fern",
            "rubber.usdz": "Rubber Plant",
            "silverpothos.usdz": "Silver Pothos",
            "snakeplant.usdz": "Snake Plant",
            "spiderplant.usdz": "Spider Plant",
            "succulent.usdz": "Succulent",
            "weep.usdz": "Weeping Fig",
            "yucca.usdz": "Yucca",
            "zz.usdz": "ZZ Plant",
            "Aloe": "Aloe Vera",
            "Areca": "Areca Palm",
            "Arrowhead": "Arrowhead Plant",
            "Bamboopalm": "Bamboo Palm",
            "Banana": "Banana Plant",
            "Bostonfern": "Boston Fern",
            "Cactus": "Cactus",
            "Calathea": "Calathea",
            "Castiron": "Cast Iron Plant",
            "Chineseevergreen": "Chinese Evergreen",
            "Croton": "Croton",
            "Dieffenbachia": "Dieffenbachia",
            "Dracaena": "Dracaena",
            "Echeveria": "Echeveria",
            "Fiddle": "Fiddle Leaf Fig",
            "Garden": "Garden Plant",
            "Goldenpothos": "Golden Pothos",
            "Haworthia": "Haworthia",
            "Heartleaf": "Heartleaf Philodendron",
            "Ivy": "English Ivy",
            "Jade": "Jade Plant",
            "Ladypalm": "Lady Palm",
            "Maidenhair": "Maidenhair Fern",
            "Money": "Money Tree",
            "Parlorpalm": "Parlor Palm",
            "Peacelily": "Peace Lily",
            "Peperomia": "Peperomia",
            "Philodendron": "Philodendron",
            "Pothos": "Pothos",
            "Prayer": "Prayer Plant",
            "Queenfern": "Queen Fern",
            "Rubber": "Rubber Plant",
            "Silverpothos": "Silver Pothos",
            "Snakeplant": "Snake Plant",
            "Spiderplant": "Spider Plant",
            "Succulent": "Succulent",
            "Weep": "Weeping Fig",
            "Yucca": "Yucca",
            "Zz": "ZZ Plant"
        ]

    var initialRecommendedPlants: Set<String>?
    @State private var selectedPlants: Set<String>

    init(initialRecommendedPlants: Set<String>? = nil) {
        self.initialRecommendedPlants = initialRecommendedPlants
        _selectedPlants = State(initialValue: initialRecommendedPlants ?? ["aloe.usdz", "zz.usdz", "cactus.usdz", "areca.usdz", "arrowhead.usdz"])
    }

    var displayedPlantName: String? {
        guard let fileName = plantName else { return nil }
        return customPlantNames[fileName] ?? fileName
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ARViewContainer(
                isPlacingModel: $isPlacingModel,
                selectedEntity: $selectedEntity,
                selectedModelName: $selectedModelName,
                isPlaneDetected: $isPlaneDetected,
                plantName: $plantName,
                showPlaneDetectionPrompt: $showPlaneDetectionPrompt,
                isPlantSelectionExpanded: $isPlantSelectionExpanded
            )
            .edgesIgnoringSafeArea(.all)

            if let selectedPlantName = displayedPlantName, selectedEntity != nil {
                VStack(alignment: .center, spacing: 5) {
                    HStack(spacing: 8) {
                        Text("🌱 Selected:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(selectedPlantName)
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .bold()
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                        Button(action: {
                            selectedEntity?.removeFromParent()
                            selectedEntity = nil
                            plantName = nil
                            isInfoExpanded = false
                        }) {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                    }
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green.opacity(0.6)]), startPoint: .top, endPoint: .bottom))
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            withAnimation {
                                isInfoExpanded.toggle()
                            }
                            if isInfoExpanded, let plantName = displayedPlantName {
                                isLoading = true
                                fetchPlantInfo(plantName: plantName) { description, placement in
                                    DispatchQueue.main.async {
                                        self.descriptionText = description ?? "No description available."
                                        self.isLoading = false
                                        self.typingIndex = 0
                                        startTypingAnimation()
                                    }
                                }
                            }
                        }) {
                            HStack {
                                Text("🪴 More Info")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                Spacer()
                                Image(systemName: isInfoExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                        }

                        if isInfoExpanded {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .green))
                                    .scaleEffect(1.2)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            } else {
                                Text(currentText)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .frame(maxWidth: 300)
                }
                .padding(.top, 20)
                .frame(maxWidth: .infinity, alignment: .top)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPlantSelectionExpanded.toggle()
                        }
                    }) {
                        Text(isPlantSelectionExpanded ? "Hide Plants" : "Show Plants")
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    Spacer()
                }
                .padding(.bottom, 10)

                ZStack {
                    if isPlantSelectionExpanded {
                        plantSelectionView
                            .transition(.opacity)
                    }
                }
                .frame(height: isPlantSelectionExpanded ? nil : 0)
                .clipped()

                if selectedModelName != nil && isPlantSelectionExpanded {
                    Button("Add Plant 🌱") {
                        isPlacingModel.toggle()
                    }
                    .padding(8)
                    .background(isPlaneDetected ? Color.green.opacity(0.8) : Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(!isPlaneDetected)
                    .padding(.bottom, 20)
                    .fontWeight(.bold)
                }
            }

            if showPlaneDetectionPrompt && isPlantSelectionExpanded {
                VStack {
                    Text("Point your camera at a flat surface")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .transition(.opacity)
                        .animation(.easeInOut)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
            }
        }
    }

    var plantSelectionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(Array(selectedPlants), id: \.self) { modelName in
                    Button(action: {
                        selectedModelName = modelName
                        plantName = modelName
                        showPlaneDetectionPrompt = !isPlaneDetected && isPlantSelectionExpanded
                    }) {
                        VStack {
                            Image(modelName.replacingOccurrences(of: ".usdz", with: ""))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 90, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 5)
                            Text(customPlantNames[modelName] ?? modelName.replacingOccurrences(of: ".usdz", with: "").capitalized)
                                .font(.caption)
                                .foregroundColor(selectedModelName == modelName ? .green : .primary)
                        }
                        .padding(8)
                        .background(selectedModelName == modelName ? Color.green.opacity(0.2) : Color.white.opacity(0.6))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                }

                Button(action: {
                    isViewAllPresented = true
                }) {
                    Text("View All")
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: 100, height: 90)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .sheet(isPresented: $isViewAllPresented) {
                    PlantSelectionView(
                        plantModels: plantModels,
                        customPlantNames: customPlantNames,
                        selectedPlants: $selectedPlants,
                        isViewAllPresented: $isViewAllPresented
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    func startTypingAnimation() {
        currentText = ""
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            if typingIndex < descriptionText.count {
                let index = descriptionText.index(descriptionText.startIndex, offsetBy: typingIndex)
                currentText.append(descriptionText[index])
                typingIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }

    func fetchPlantInfo(plantName: String, completion: @escaping (String?, String?) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }

        let message = [
            "role": "user",
            "content": "Provide a 1-2 sentence description and the best placement for the plant named \(plantName)."
        ]

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [message],
            "max_tokens": 200
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else { return }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching plant info: \(error)")
                completion(nil, nil)
                return
            }
            
            guard let data = data,
                  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let choices = jsonResponse["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                completion(nil, nil)
                return
            }
            
            completion(content, nil)
        }.resume()
    }
}






struct PlantSelectionView: View {
    let plantModels: [String]
    let customPlantNames: [String: String]
    @Binding var selectedPlants: Set<String>
    @Binding var isViewAllPresented: Bool
    @State private var searchQuery = ""
    
    var filteredPlantModels: [String] {
        if searchQuery.isEmpty {
            return plantModels
        } else {
            return plantModels.filter { $0.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search plants...", text: $searchQuery)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .foregroundColor(.primary)
                
                List(filteredPlantModels, id: \.self) { modelName in
                    Button(action: {
                        if selectedPlants.contains(modelName) {
                            selectedPlants.remove(modelName)
                        } else {
                            selectedPlants.insert(modelName)
                        }
                    }) {
                        HStack {
                            Image(modelName.replacingOccurrences(of: ".usdz", with: ""))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 75, height: 75)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 4)
                            
                            Text(customPlantNames[modelName] ?? modelName.replacingOccurrences(of: ".usdz", with: "").capitalized)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.leading, 10)
                            
                            Spacer()
                            
                            if selectedPlants.contains(modelName) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(selectedPlants.contains(modelName) ? Color.green.opacity(0.15) : Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: selectedPlants.contains(modelName) ? 3 : 1)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Select Plants")
            .navigationBarItems(trailing: Button("Close") {
                isViewAllPresented = false
            })
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
        }
    }
}


struct ARViewContainer: UIViewRepresentable {
    @Binding var isPlacingModel: Bool
    @Binding var selectedEntity: ModelEntity?
    @Binding var selectedModelName: String?
    @Binding var isPlaneDetected: Bool
    @Binding var plantName: String?
    @Binding var showPlaneDetectionPrompt: Bool
    @Binding var isPlantSelectionExpanded: Bool


    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.run(config)
        
        arView.session.delegate = context.coordinator
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didTapEntity(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didPanARView(_:)))
        arView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didPinchARView(_:)))
        arView.addGestureRecognizer(pinchGesture)
        
        context.coordinator.arView = arView
        context.coordinator.isPlacingModel = $isPlacingModel
        context.coordinator.selectedEntity = $selectedEntity
        context.coordinator.selectedModelName = $selectedModelName
        context.coordinator.isPlaneDetected = $isPlaneDetected
        context.coordinator.plantName = $plantName
        context.coordinator.showPlaneDetectionPrompt = $showPlaneDetectionPrompt // Pass prompt binding
        context.coordinator.isPlantSelectionExpanded = $isPlantSelectionExpanded


        
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
    var selectedModelName: Binding<String?>?
    var isPlaneDetected: Binding<Bool>?
    var plantName: Binding<String?>?
    var showPlaneDetectionPrompt: Binding<Bool>?
    var isPlantSelectionExpanded: Binding<Bool>?

    

    
    @objc func didTapEntity(_ sender: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        
        let tapLocation = sender.location(in: arView)
        
        if let entity = arView.entity(at: tapLocation) as? ModelEntity {
            selectedEntity?.wrappedValue = entity
            plantName?.wrappedValue = entity.name.replacingOccurrences(of: ".usdz", with: "").capitalized
        } else {
            plantName?.wrappedValue = nil
            selectedEntity?.wrappedValue = nil
        }
    }

    func placeModel() {
        guard let arView = arView, let modelName = selectedModelName?.wrappedValue else { return }
        
        if let result = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal).first {
            do {
                let plantEntity = try ModelEntity.loadModel(named: modelName)
                plantEntity.scale = SIMD3(0.002, 0.002, 0.002)
                plantEntity.generateCollisionShapes(recursive: true)
                plantEntity.name = modelName
                
                let anchorEntity = AnchorEntity(world: result.worldTransform.translation)
                anchorEntity.addChild(plantEntity)
                arView.scene.addAnchor(anchorEntity)
                
                selectedEntity?.wrappedValue = plantEntity
                isPlacingModel?.wrappedValue = false
            } catch {
                print("Error loading model: \(error)")
            }
        }
    }
    
    @objc func didPanARView(_ sender: UIPanGestureRecognizer) {
        guard let arView = arView, let selectedEntity = selectedEntity?.wrappedValue else { return }
        
        let panLocation = sender.location(in: arView)
        
        if let result = arView.raycast(from: panLocation, allowing: .estimatedPlane, alignment: .horizontal).first {
            selectedEntity.setPosition(result.worldTransform.translation, relativeTo: nil)
        }
    }

    @objc func didPinchARView(_ sender: UIPinchGestureRecognizer) {
        guard let selectedEntity = selectedEntity?.wrappedValue else { return }
        
        if sender.state == .changed {
            let pinchScale = Float(sender.scale)
            selectedEntity.scale *= SIMD3(pinchScale, pinchScale, pinchScale)
            sender.scale = 1.0
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let arView = arView else { return }
        
        if let _ = arView.raycast(from: arView.center, allowing: .existingPlaneGeometry, alignment: .horizontal).first {
            isPlaneDetected?.wrappedValue = true
            showPlaneDetectionPrompt?.wrappedValue = false // Hide prompt if plane detected
        } else {
            isPlaneDetected?.wrappedValue = false
            // Show prompt if no plane is detected, a plant is selected, and plant selection is expanded
            showPlaneDetectionPrompt?.wrappedValue = selectedModelName?.wrappedValue != nil && isPlantSelectionExpanded?.wrappedValue == true
        }
        
        if isPlacingModel?.wrappedValue == true {
            placeModel()
        }
    }
}

extension float4x4 {
    var translation: SIMD3<Float> {
        return SIMD3(self.columns.3.x, self.columns.3.y, self.columns.3.z)
    }
}
