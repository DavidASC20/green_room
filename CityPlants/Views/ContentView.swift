import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.1), Color.green.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    VStack(spacing: 10) {
                        Text("Transform Your Room!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.green)
                        
                        Text("Bring nature indoors with personalized plant recommendations and an AR experience.")
                            .font(.body)
                            .foregroundColor(.green.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 50)
                    
                    Image(systemName: "leaf.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.white)
                        .shadow(color: .green, radius: 10, x: 0, y: 10)
                        .padding(.bottom, 20)
                    
                    NavigationLink(destination: ARExperienceView()) {
                        Text("Start AR Experience")
                            .font(.headline)
                            .fontWeight(.medium)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal, 30)
                    
                    NavigationLink(destination: GPTView()) {
                        Text("Get Plant Recommendations")
                            .font(.headline)
                            .fontWeight(.medium)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
            }
            .navigationTitle("Green Room")
            .navigationBarTitleDisplayMode(.inline)
        }
        .accentColor(.green)
    }
}
