import SwiftUI

struct ProfileManagementView: View {
    @AppStorage("userID") private var userID: String = "" // Retrieve stored userID (farmerId)
    @AppStorage("farmID") private var farmID: String = ""

    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var farmName = ""
    @State private var address = ""
    @State private var showAlert = false
    @State private var errorMessage = ""

    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                TextField("Phone Number", text: $phoneNumber)
            }

            Section(header: Text("Farm Details")) {
                TextField("Farm Name", text: $farmName)
                TextField("Address", text: $address)
            }

            Button("Save Changes") {
                saveAllChanges()
            }
            .foregroundColor(.white)
            .frame(width: 200, height: 50)
            .background(Color.green)
            .cornerRadius(10)
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            
        }
        .navigationTitle("Profile Management")
        .onAppear {
    
            fetchPersonalInfo()
        }
    }



    private func fetchPersonalInfo() {
        guard !userID.isEmpty else {
            errorMessage = "User ID is missing. Please log in again."
            showAlert = true
            return
        }

        guard let url = URL(string: "http://localhost:3000/api/v1/farmers/user/\(userID)") else {
            errorMessage = "Invalid API URL"
            showAlert = true
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }

                guard let data = data else {
                    errorMessage = "No data received"
                    showAlert = true
                    return
                }

                do {
                    let result = try JSONDecoder().decode(Farmer.self, from: data)
                    print("Fetched Personal Info: \(result)")
                    name = result.name ?? ""
                    email = result.email ?? ""
                    phoneNumber = result.phone_number ?? ""
                    farmName = result.farm_name ?? ""
                    address = result.location ?? ""
                    errorMessage = "" // Clear previous errors
                } catch {
                    errorMessage = "Decoding error: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }.resume()
    }

    
    private func updatePersonalInfo(completion: @escaping (Bool) -> Void) {
                guard !userID.isEmpty else {
                    errorMessage = "User ID is missing. Please log in again."
                    showAlert = true
                    completion(false)
                    return
                }

                guard let url = URL(string: "http://localhost:3000/api/v1/farmers/\(userID)") else {
                    errorMessage = "Invalid API URL"
                    showAlert = true
                    completion(false)
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let personalInfo: [String: Any] = [
                    "name": name,
                    "email": email,
                    "phone_number": phoneNumber
                ]


                guard let jsonData = try? JSONSerialization.data(withJSONObject: personalInfo) else {
                    errorMessage = "Failed to encode JSON"
                    showAlert = true
                    completion(false)
                    return
                }

                request.httpBody = jsonData

                URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            errorMessage = "Network error: \(error.localizedDescription)"
                            showAlert = true
                            completion(false)
                            return
                        }

                        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                            errorMessage = "Failed to update personal info"
                            showAlert = true
                            completion(false)
                            return
                        }

                        completion(true)
                    }
                }.resume()
            }

    private func updateFarmDetails(completion: @escaping (Bool) -> Void) {
        guard !farmID.isEmpty else {
            errorMessage = "Farm ID is missing. Cannot update farm details."
            showAlert = true
            completion(false)
            return
        }

        guard let url = URL(string: "http://localhost:3000/api/v1/farmers/farm/\(farmID)") else {
            errorMessage = "Invalid API URL"
            showAlert = true
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let farmDetails: [String: Any] = [
            "name": farmName,
            "location": address
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: farmDetails) else {
            errorMessage = "Failed to encode JSON"
            showAlert = true
            completion(false)
            return
        }

        print("Farm ID: \(farmID), URL: \(url), Data: \(farmDetails)") // Log farmId and payload

        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    showAlert = true
                    completion(false)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    errorMessage = "Failed to update farm details"
                    showAlert = true
                    completion(false)
                    return
                }

                completion(true)
            }
        }.resume()
    }


    private func saveAllChanges() {
        updatePersonalInfo { personalInfoSuccess in
            if personalInfoSuccess {
                updateFarmDetails { farmDetailsSuccess in
                    if farmDetailsSuccess {
                        errorMessage = "All changes saved successfully!"
                    } else {
                        errorMessage = "Failed to update farm details."
                    }
                    showAlert = true
                }
            } else {
                errorMessage = "Failed to update personal info."
                showAlert = true
            }
        }
    }
}
struct Farmer: Codable {
    let name: String?
    let email: String?
    let phone_number: String?
    let farm_name: String?
    let location: String?
}

struct FarmIdResponse: Codable {
    let farmId: String
}
