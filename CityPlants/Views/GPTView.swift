import SwiftUI
import PhotosUI

let API_KEY = "sk-FuD_geHbQ3CD-45NzHVJO1kYliSJIuuQf4dVBTGz8pT3BlbkFJm7cAZ1nOPfciOOMPGg149pO8NDzHEP-X1fN6IdnzoA"

struct GPTView: View {
    @State private var recommendedPlants: [Plant] = []
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker: Bool = false
    @State private var showCameraPicker: Bool = false
    @State private var analysisResult: String? = nil
    @State private var isAnalyzing: Bool = false
    
    
    @State private var hasPet: Bool = false
    @State private var selectedMaintenanceLevel: String = "Low"
    private let maintenanceLevels = ["Low", "Moderate", "High"]
    
    
    @State private var lightLevel: String = "Medium"
    @State private var roomSize: String = "Medium"
    private let lightLevels = ["High", "Medium", "Low"]
    private let roomSizes = ["Large", "Medium", "Small"]
    
    
    @State private var navigateToRecommendations = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("🔍 Room Analysis")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.vertical, 10)
                    .background(Color.green.opacity(0.1).cornerRadius(8))
                    .padding(.top, 10)
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    if isAnalyzing {
                        ProgressView("Analyzing image...")
                            .padding()
                            .foregroundColor(.gray)
                    } else if let result = analysisResult {
                        Text("🧠 Room AI Analysis")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.top, 10)
                        
                        Text(result)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .scaleEffect(analysisResult != nil ? 1 : 0.5)
                            .opacity(analysisResult != nil ? 1 : 0)
                            .animation(.easeInOut(duration: 0.4), value: analysisResult)
                    }
                } else {
                    Text("Upload a picture of your room or take a photo to get plant placement recommendations.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                if analysisResult == nil {
                    HStack(spacing: 16) {
                        Button(action: { showImagePicker = true }) {
                            Text("🖼️ Upload")
                                .font(.headline)
                                .fontWeight(.medium)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: { showCameraPicker = true }) {
                            Text("📷 Take Photo")
                                .font(.headline)
                                .fontWeight(.medium)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(sourceType: .photoLibrary, image: $selectedImage, onImagePicked: startImageAnalysis)
                    }
                    .sheet(isPresented: $showCameraPicker) {
                        ImagePicker(sourceType: .camera, image: $selectedImage, onImagePicked: startImageAnalysis)
                    }
                }
                
                if analysisResult != nil {
                    // Room setting options with emojis
                    HStack {
                        Text("🌞 Light Level:")
                            .font(.headline)
                        Picker("Light Level", selection: $lightLevel) {
                            ForEach(lightLevels, id: \.self) { level in
                                Text(level).tag(level)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("📏 Room Size:")
                            .font(.headline)
                        Picker("Room Size", selection: $roomSize) {
                            ForEach(roomSizes, id: \.self) { size in
                                Text(size).tag(size)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("🐾 Pet-friendly:")
                            .font(.headline)
                        Picker("Pet-friendly", selection: $hasPet) {
                            Text("Yes").tag(true)
                            Text("No").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("✂️ Maintenance Level:")
                            .font(.headline)
                        Picker("Maintenance Level", selection: $selectedMaintenanceLevel) {
                            ForEach(maintenanceLevels, id: \.self) { level in
                                Text(level).tag(level)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(
                        destination: PlantRecommendationView(
                            roomSize: roomSize,
                            lightLevel: lightLevel,
                            maintenanceLevel: selectedMaintenanceLevel,
                            hasPet: hasPet
                        ),
                        isActive: $navigateToRecommendations
                    ) {
                        EmptyView()
                    }
                    
                    Button(action: { navigateToRecommendations = true }) {
                        Text("🌿 Plant Recommendations")
                            .font(.headline)
                            .fontWeight(.medium)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func extractLightingAndRoomSize(from analysis: String) {
        if analysis.contains("high light") {
            lightLevel = "High"
        } else if analysis.contains("medium light") {
            lightLevel = "Medium"
        } else if analysis.contains("low light") {
            lightLevel = "Low"
        }
        
        if analysis.contains("large size") {
            roomSize = "Large"
        } else if analysis.contains("medium size") {
            roomSize = "Medium"
        } else if analysis.contains("small size") {
            roomSize = "Small"
        }
    }
    
    func startImageAnalysis() {
        isAnalyzing = true
        analysisResult = nil
        
        if let image = selectedImage, let base64Image = image.resizedAndCompressedBase64() {
            analyzeImageWithGPT(base64Image: base64Image) { result in
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.analysisResult = result
                }
                self.isAnalyzing = false
                if let result = result {
                    extractLightingAndRoomSize(from: result)
                }
            }
        }
    }


    
    func analyzeImageWithGPT(base64Image: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Error: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "Give me a verbose two sentence analysis of the room. In the first sentence, write out the size of the room and the lighting available High: Lots of direct or indirect sunlight. Medium: Partial sunlight or bright artificial light. Low: Minimal sunlight or artificial light only. Room Size - Large, medium, and small.  If there are lots of windows, there are lots of sunlight, and vice versa. In the second sentence, talk about potential places to put houseplants.  Be realistic, discern between natural and artificial light levels.  Be honest about the size of the room, as smaller rooms cannot have larger plants.  Do not include any names of plants, just put areas where plants can go.  In the first sentence, make sure to include 'high light' if light levels are high, 'medium light' if they are medium, and 'low light' in the response, as well as 'large size', 'medium size', and 'small size' for the room size."],
                ["role": "user", "content": "Analyze this room image provided in Base64 format and respond based on its content. \(base64Image)"]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: .fragmentsAllowed)
        
        print("Request Sent: \(Date())")
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("Response Received: \(Date())")
            
            if let data = data {
                let responseDataString = String(data: data, encoding: .utf8) ?? "N/A"
                print("Raw Response Data: \(responseDataString)")
            }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion("Failed to analyze the image due to an error.")
                }
                return
            }
            
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                print("Successfully parsed response content")
                DispatchQueue.main.async {
                    completion(content)
                }
            } else {
                print("Failed to parse response content")
                DispatchQueue.main.async {
                    completion("Failed to analyze the image.")
                }
            }
        }.resume()
    }
    

}

extension UIImage {
    func resizedAndCompressedBase64(targetSize: CGSize = CGSize(width: 400, height: 300), compressionQuality: CGFloat = 0.2) -> String? {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        self.draw(in: CGRect(origin: .zero, size: targetSize))
        
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext(),
              let imageData = resizedImage.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    enum SourceType {
        case camera, photoLibrary
    }
    
    var sourceType: SourceType
    @Binding var image: UIImage?
    var onImagePicked: () -> Void
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType == .camera ? .camera : .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.onImagePicked()
            }
        }
    }
}
