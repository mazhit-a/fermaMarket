import SwiftUI

enum Destination: Hashable {
    case farmerDashboard
    case productSearch
}

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var loginError = false
    @State private var errorMessage = ""
    @State private var navigationDestination: Destination? = nil
    
    @AppStorage("userID") private var userID: String = ""
    @AppStorage("farmID") private var farmID: String = "" // Store farmID persistently

    var body: some View {
        NavigationStack {
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 140)
                    .padding(.vertical, 32)

                Text("Login")
                    .font(.largeTitle)
                    .padding()

                TextField("Username", text: $username)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal, 20)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal, 20)

                Button("Login") {
                    handleLogin()
                }
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(Color.green)
                .cornerRadius(10)
                .padding()
                .alert(isPresented: $loginError) {
                    Alert(
                        title: Text("Login Failed"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }

                NavigationLink(tag: Destination.farmerDashboard, selection: $navigationDestination) {
                    MainFarmerTabView()
                } label: {
                    EmptyView()
                }

                NavigationLink(tag: Destination.productSearch, selection: $navigationDestination) {
                    MainTabView()
                } label: {
                    EmptyView()
                }
            }
            .padding()
        }
    }

    private func handleLogin() {
        guard let url = URL(string: "http://localhost:3000/api/v1/login") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "login": username,
            "password": password
        ]
        
        guard let jsonData = try? JSONEncoder().encode(body) else {
            print("Failed to encode JSON")
            return
        }
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            print("Raw server response:", String(data: data, encoding: .utf8) ?? "Invalid response")
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(LoginResponse.self, from: data)
                
                DispatchQueue.main.async {
                    if result.success {
                        userID = String(result.userId) // Save the correct farmer ID
                        print("User ID saved: \(userID)")
                        fetchFarmId(for: userID) // Fetch and save the farm ID
                        if result.userType == "farmer" {
                            navigationDestination = .farmerDashboard
                        } else if result.userType == "buyer" {
                            navigationDestination = .productSearch
                        }
                    } else {
                        loginError = true
                        errorMessage = "Error: \(result.userType)"
                    }
                }
            } catch {
                print("Decoding error:", error.localizedDescription)
                DispatchQueue.main.async {
                    loginError = true
                    errorMessage = "Invalid server response."
                }
            }
        }.resume()
    
    }
    
    private func fetchFarmId(for farmerID: String) {
        guard let url = URL(string: "http://localhost:3000/api/v1/farmers/farms/\(farmerID)") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error:", error?.localizedDescription ?? "Unknown error")
                return
            }

            print("Raw server response:", String(data: data, encoding: .utf8) ?? "Invalid response")

            do {
                // Decode farmId as an integer
                let result = try JSONDecoder().decode([String: Int].self, from: data)
                if let fetchedFarmId = result["farmId"] {
                    DispatchQueue.main.async {
                        // Save farmId to @AppStorage
                        farmID = String(fetchedFarmId)
                        print("Farm ID saved: \(farmID)")
                    }
                } else {
                    print("Farm ID not found in response")
                }
            } catch {
                print("Decoding error:", error.localizedDescription)
            }
        }.resume()
    }
}

struct LoginResponse: Codable {
    let success: Bool
    let userType: String
    let userId: Int
    let farmId: Int? // Optional because buyers won’t have a farmId
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
