import SwiftUI
import Foundation

struct Plant: Identifiable, Decodable {
    var id = UUID()
    var name: String  // This will be set manually from the dictionary keys
    var scientific_name: String
    var light: String
    var maintenance: String
    var placement: String
    var watering: String
    var toxic_to_pets: Bool
    var justification: String?  // Optional if not provided by GPT
    var png: String
    var usdz: String
}

// Helper struct to decode the details of each plant
struct PlantDetails: Decodable {
    var scientific_name: String
    var light_level: String
    var maintenance_level: String
    var placement: String
    var watering_frequency: String
    var toxic_to_pets: Bool
    var png: String
    var usdz: String
}

struct PlantCardView: View {
    let plant: Plant
    
    var body: some View {
        VStack(alignment: .leading) {
            // Display the PNG image of the plant, falling back to a placeholder if unavailable
            ZStack {
                if let uiImage = UIImage(named: plant.png) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit() // Ensure image fits without clipping
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(10)
                        .padding(.horizontal) // Optional: Adds padding for centering
                } else {
                    // Fallback placeholder if image is not found
                    Rectangle()
                        .fill(Color.green.opacity(0.1))
                        .frame(height: 150)
                        .overlay(
                            Image(systemName: "leaf.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.green.opacity(0.7))
                        )
                        .cornerRadius(10)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center) // Centers the image horizontally

            // Plant Info
            VStack(alignment: .leading, spacing: 8) {
                Text(plant.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(plant.scientific_name)
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.secondary)
                
                Divider()
                
                // Light, Maintenance, and Watering
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Text("☀️")
                            .frame(width: 20) // Fixed width for alignment
                        Text("Light:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(plant.light)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack(alignment: .top) {
                        Text("✂️")
                            .frame(width: 20) // Fixed width for alignment
                        Text("Maintenance:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(plant.maintenance)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack(alignment: .top) {
                        Text("💧")
                            .frame(width: 20) // Fixed width for alignment
                        Text("Watering:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(plant.watering)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.bottom, 8)
                
                // Justification Section
                if let justification = plant.justification {
                    Divider()
                        .padding(.vertical, 4)
                    
                    Text("Analysis")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.bottom, 2)
                    
                    Text(justification)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                        .padding(.bottom, 8)
                }
                
                // Placement Section
                Divider()
                    .padding(.vertical, 4)
                
                Text("Placement")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 2)
                
                Text(plant.placement)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
        .padding([.horizontal, .bottom])
    }
}
