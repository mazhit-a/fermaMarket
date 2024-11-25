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
                        title: Text(errorMessage),
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

            do {
                let result = try JSONDecoder().decode(LoginResponse.self, from: data)
                print("Login Result: \(result)")

                DispatchQueue.main.async {
                    if result.success {
                        if result.user_type == "farmer" {
                            navigationDestination = .farmerDashboard
                        } else if result.user_type == "buyer" {
                            navigationDestination = .productSearch
                        }
                    } else {
                        loginError = true
                        errorMessage = result.user_type
                    }
                }
            } catch {
                print("Decoding error:", error.localizedDescription)
            }
        }.resume()
    }
}

struct LoginResponse: Codable {
    let success: Bool
    let user_type: String
}

struct LoginView_Previews: PreviewProvider{
    static var previews: some View {
        LoginView()
    }
}

