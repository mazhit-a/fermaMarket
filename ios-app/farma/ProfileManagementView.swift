import SwiftUI

struct ProfileManagementView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var crop_types = ""
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
                TextField("Crop Types", text: $crop_types)
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
        let userid = 9933
        
        guard let url = URL(string: "http://localhost:3000/api/v1/farmers/user/\(userid)") else {
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
                    print("Fetched Personal Info: \(result)") // Debugging
                    if let name = result.name {
                        self.name = name
                    }
                    if let email = result.email {
                        self.email = email
                    }
                    if let phoneNumber = result.phone_number {
                        self.phoneNumber = phoneNumber
                    }
                    if let crop_types = result.crop_types {
                        self.crop_types = crop_types
                    }
                    if let address = result.location {
                        self.address = address
                    }
                    
                    name = result.name ?? ""
                    email = result.email ?? ""
                    phoneNumber = result.phone_number ?? ""
                    crop_types = result.crop_types ?? ""
                    address = result.location ?? ""
                    
                } catch {
                    errorMessage = "Decoding error: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }.resume()
    }
    
    private func updatePersonalInfo(completion: @escaping (Bool) -> Void) {
        let userid = 1

        guard let url = URL(string: "http://localhost:3000/api/v1/farmers/\(userid)") else {
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
        let farmId = 1233

        guard let url = URL(string: "http://localhost:3000/api/v1/farmers/farm/\(farmId)") else {
            errorMessage = "Invalid API URL"
            showAlert = true
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let farmDetails: [String: Any] = [
            "crop_types": crop_types,
            "location": address
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: farmDetails) else {
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
                    errorMessage = "Failed to update farm details"
                    showAlert = true
                    completion(false)
                    return
                }

                completion(true)
            }
        }.resume()
    }


    
    private func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
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
    let crop_types: String?
    let location: String?
}


