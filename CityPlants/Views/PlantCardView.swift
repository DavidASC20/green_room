import SwiftUI
import Foundation

struct Plant: Identifiable, Decodable {
    var id = UUID()
    var name: String
    var scientific_name: String
    var light: String
    var maintenance: String
    var placement: String
    var watering: String
    var toxic_to_pets: Bool
    var justification: String?
    var png: String
    var usdz: String
}


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
            ZStack {
                if let uiImage = UIImage(named: plant.png) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(10)
                        .padding(.horizontal)
                } else {
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
            .frame(maxWidth: .infinity, alignment: .center)
            
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
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Text("☀️")
                            .frame(width: 20)
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
                            .frame(width: 20)
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
                            .frame(width: 20)
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
