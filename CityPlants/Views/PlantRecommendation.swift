import SwiftUI

struct PlantRecommendationView: View {
    var roomSize: String
    var lightLevel: String
    var maintenanceLevel: String
    var hasPet: Bool
    @State private var recommendedPlants: [Plant] = []
    @State private var isLoading: Bool = true
    @State private var showDetails: Bool = true
    
    var body: some View {
        VStack {
            Text("Recommended Plants")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.top)
            
            Divider()
                .padding(.vertical, 10)
            
            // Collapsible Information Section
            VStack(spacing: 8) {
                HStack {
                    Text("Room Details")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showDetails.toggle()
                        }
                    }) {
                        Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)
                
                if showDetails {
                    VStack(spacing: 8) {
                        InfoRow(label: "Room Size", value: roomSize, icon: "square.grid.3x3.fill")
                        InfoRow(label: "Light Level", value: lightLevel, icon: "sun.max.fill")
                        InfoRow(label: "Maintenance Level", value: maintenanceLevel, icon: "scissors")
                        InfoRow(label: "Pet-friendly", value: hasPet ? "Yes" : "No", icon: "pawprint.fill")
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .background(Color(UIColor.systemGroupedBackground).opacity(0.5))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
            }
            .padding(.horizontal)

            if isLoading {
                ProgressView("Loading recommendations...")  // Loading animation
                    .padding()
            } else if !recommendedPlants.isEmpty {
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(recommendedPlants) { plant in
                            PlantCardView(plant: plant)
                                .padding(.horizontal)
                        }
                        
                        // NavigationLink to ARExperienceView after the plant recommendations
                        NavigationLink(destination: ARExperienceView(
                            initialRecommendedPlants: Set(recommendedPlants.map{$0.usdz})
                        )) {
                            Text("Open With AR")
                                .font(.headline)
                                .fontWeight(.medium)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
            } else {
                Text("No recommendations found.")
                    .padding()
            }
        }
        .padding(.horizontal)
        .onAppear {
            fetchPlantRecommendations()
        }
    }
    
    // MARK: - InfoRow Component
    struct InfoRow: View {
        let label: String
        let value: String
        let icon: String
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.green)
                    .frame(width: 30, height: 30)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(value)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
    private func fetchPlantRecommendations() {
        guard let plantsJSON = loadPlantsJSON() else {
            print("Failed to load plants.json")
            self.isLoading = false
            return
        }
        
        let prompt = """
        I will give you four settings: room size, light level, maintenance level, and if toxic to pets.  If its toxic to pets, do not flaunt it, only mention it if it isnt toxic to pets 
        From there, I want you to choose at most 5 plants that best fit the description from the JSON I provide.  Use your best judgement and keep in mind the settings given to you. 
        Return only the name of the plants, along with a justification based on the settings provided for each of them.  Separate the name and justification with a -, and each entry with ---, do not include newlines or bold the plants.
        
        An example is "Snake Plant - Snake Plant is a low-maintenance plant that thrives in varying light conditions, can tolerate high light levels, fitting your criteria perfectly --- Rubber Plant - Rubber Plant prefers bright indirect light and has low to medium maintenance needs;
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": prompt],
                ["role": "user", "content": """
                    Room size: \(roomSize)
                    Light level: \(lightLevel)
                    Maintenance level: \(maintenanceLevel)
                    Pet-friendly: \(hasPet ? "Yes" : "No")
                    Plants JSON: \(plantsJSON)
                    """]
            ]
        ]
        
        sendGPTRequest(with: requestBody, allPlants: parsePlants(from: plantsJSON))
    }
    
    private func sendGPTRequest(with requestBody: [String: Any], allPlants: [Plant]) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Error: Invalid URL")
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: .fragmentsAllowed)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            // Print raw data received from GPT for debugging
            if let rawDataString = String(data: data, encoding: .utf8) {
                print("Raw GPT Response: \(rawDataString)")
            }
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = jsonResponse["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                DispatchQueue.main.async {
                    let recommendations = self.parsePlantNamesAndJustifications(from: content)
                                    
                    self.recommendedPlants = allPlants.compactMap { plant in
                        if let recommendation = recommendations.first(where: { $0.name == plant.name }) {
                            var plantWithJustification = plant
                            plantWithJustification.justification = recommendation.justification
                            return plantWithJustification
                        }
                        return nil
                    }
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    print("Failed to parse GPT response")
                    self.isLoading = false
                }
            }
        }.resume()
    }

    
    private func parsePlantNamesAndJustifications(from content: String) -> [(name: String, justification: String)] {
           let plantEntries = content.components(separatedBy: " --- ")
           var result: [(name: String, justification: String)] = []

           for entry in plantEntries {
               let components = entry.components(separatedBy: " - ")
               if components.count >= 2 {
                   let name = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                   let justification = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                   result.append((name: name, justification: justification))
               }
           }
           
           return result
       }

    
    private func loadPlantsJSON() -> String? {
        if let url = Bundle.main.url(forResource: "plants", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    private func parsePlants(from jsonString: String) -> [Plant] {
        guard let data = jsonString.data(using: .utf8) else {
            print("Failed to convert JSON string to data")
            return []
        }
        
        let decoder = JSONDecoder()
        do {
            let plantDictionary = try decoder.decode([String: PlantDetails].self, from: data)
            
            let plants = plantDictionary.map { (name, details) in
                Plant(
                    name: name,
                    scientific_name: details.scientific_name,
                    light: details.light_level,
                    maintenance: details.maintenance_level,
                    placement: details.placement,
                    watering: details.watering_frequency,
                    toxic_to_pets: details.toxic_to_pets,
                    png: details.png,
                    usdz: details.usdz
                )
            }
            print(plants)
            return plants
        } catch {
            print("Failed to decode JSON:", error)
            return []
        }
    }

}
