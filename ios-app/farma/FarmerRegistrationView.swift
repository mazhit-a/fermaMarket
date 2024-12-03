import SwiftUI
import Combine

struct FarmerRegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var farmName = ""
    @State private var farmSize = ""
    @State private var farmLocation = ""
    @State private var cropTypes = ""
    @State private var equipment = ""
    @State private var seeds = ""
    @State private var governmentID = ""
    @State private var userLogin = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToLogin = false
    @State private var userLoginConflict = false

    @State private var nameError = ""
    @State private var emailError = ""
    @State private var phoneError = ""
    @State private var farmDetailsError = ""
    @State private var governmentIDError = ""
    @State private var passwordError = ""
    @State private var userLoginError = ""


    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                        .autocapitalization(.words)
                        .onChange(of: name, perform: validateName)
                    if !nameError.isEmpty {
                        Text(nameError).foregroundColor(.red)
                    }

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .onChange(of: email, perform: validateEmail)
                    if !emailError.isEmpty {
                        Text(emailError).foregroundColor(.red)
                    }

                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .onChange(of: phoneNumber, perform: validatePhoneNumber)
                    if !phoneError.isEmpty {
                        Text(phoneError).foregroundColor(.red)
                    }
                }

                Section(header: Text("Verification")) {
                    TextField("Government-Issued ID", text: $governmentID)
                        .onChange(of: governmentID, perform: validateGovernmentID)
                    if !governmentIDError.isEmpty {
                        Text(governmentIDError).foregroundColor(.red)
                    }
                }

                Section(header: Text("Farm Details")) {
                    TextField("Farm Name", text: $farmName)
                        .onChange(of: farmName, perform: validateFarmDetails)
                    if !farmDetailsError.isEmpty {
                        Text(farmDetailsError).foregroundColor(.red)
                    }

                    TextField("Farm Size (in acres)", text: $farmSize)
                        .keyboardType(.decimalPad)
                    TextField("Farm Address", text: $farmLocation)
                    TextField("Types of Crops", text: $cropTypes)
                    TextField("Equipment", text: $equipment)
                    TextField("Types of Seeds", text: $seeds)
                }

                Section(header: Text("Create Your Account")) {
                    TextField("User Login", text: $userLogin)
                        .onChange(of: userLogin, perform: validateUserLogin)
                    if !userLoginError.isEmpty {
                        Text(userLoginError).foregroundColor(.red)
                    }

                    SecureField("Password", text: $password)
                        .onChange(of: password, perform: validatePassword)
                    SecureField("Confirm Password", text: $confirmPassword)
                        .onChange(of: confirmPassword, perform: validatePassword)
                    if !passwordError.isEmpty {
                        Text(passwordError).foregroundColor(.red)
                    }
                }

                Button("Submit Registration") {
                    if validateAllFields() {
                        submitRegistration()
                    }
                }
                .primaryButton()
            }
            .navigationTitle("Farmer Registration")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Registration Status"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if navigateToLogin {
                            dismiss()
                        }
                    }
                )
            }
            .background(
                NavigationLink(
                                destination: ContentView(),
                                isActive: $navigateToLogin,
                                label: { EmptyView() }
                )
                .hidden()
            )
        }
    }

    // Validation functions
    private func validateName(_ value: String) {
        nameError = value.isEmpty ? "Name cannot be empty." : ""
    }

    private func validateEmail(_ value: String) {
        if value.isEmpty {
            emailError = "Email cannot be empty."
        } else if !value.contains("@") || !value.contains(".") {
            emailError = "Invalid email address."
        } else {
            emailError = ""
        }
    }

    private func validatePhoneNumber(_ value: String) {
        let trimmedPhone = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedPhone.isEmpty {
            phoneError = "Phone number cannot be empty."
        } else if trimmedPhone.first == "+" {
            if !trimmedPhone.dropFirst().allSatisfy({ $0.isNumber }) {
                phoneError = "Phone number must contain only numeric digits after '+' symbol."
            } else {
                phoneError = ""
            }
        } else if !trimmedPhone.allSatisfy({ $0.isNumber }) {
            phoneError = "Phone number must contain only numeric digits."
        } else if trimmedPhone.count < 10 {
            phoneError = "Phone number must be at least 10 digits long."
        } else if trimmedPhone.count > 15 {
            phoneError = "Phone number cannot exceed 15 digits."
        } else {
            phoneError = ""
        }
    }

    private func validateGovernmentID(_ value: String) {
        governmentIDError = value.isEmpty ? "Government ID cannot be empty." : ""
    }

    private func validateFarmDetails(_ value: String) {
        farmDetailsError = farmName.isEmpty ? "Farm name cannot be empty." : ""
    }

    private func validatePassword(_ value: String) {
        if password.isEmpty || password.count < 8 {
            passwordError = "Password must be at least 8 characters long."
        } else if password != confirmPassword {
            passwordError = "Passwords do not match."
        } else {
            passwordError = ""
        }
    }

    private func validateAllFields() -> Bool {
        validateName(name)
        validateEmail(email)
        validatePhoneNumber(phoneNumber)
        validateGovernmentID(governmentID)
        validateFarmDetails(farmName)
        validatePassword(password)

        if !nameError.isEmpty || !emailError.isEmpty || !phoneError.isEmpty || !governmentIDError.isEmpty || !passwordError.isEmpty {
            alertMessage = "Please fix errors before submitting."
            showAlert = true
            return false
        }

        return true
    }

    private func submitRegistration() {
        saveUserDetails { success in
            if success {
                self.alertMessage = "Your registration is pending."
                self.navigateToLogin = true
                self.showAlert = true
            } else if userLoginConflict{
                self.alertMessage = "Such username already exists.Please try again"
            }else{
                self.alertMessage = "Failed to save user details. Please try again."
            }
            self.showAlert = true
        }
    }

    private func saveUserDetails(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://localhost:3000/api/v1/pending") else {
            self.alertMessage = "Invalid API URL"
            self.showAlert = true
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userDetails: [String: Any] = [
            "name": name,
            "email": email,
            "phone": phoneNumber,
            "govId": governmentID,
            "farmname": farmName,
            "size": farmSize,
            "address": farmLocation,
            "equipment": equipment,
            "seeds": seeds,
            "crops": cropTypes,
            "userlogin": userLogin,
            "userpassword": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: userDetails) else {
            self.alertMessage = "Failed to encode user details"
            self.showAlert = true
            completion(false)
            return
        }
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.alertMessage = "Network error: \(error.localizedDescription)"
                    self.showAlert = true
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.alertMessage = "No response from server"
                    self.showAlert = true
                    completion(false)
                    return
                }
                
                switch httpResponse.statusCode {
                case 201:
                    self.alertMessage = "Registration successful! Your account is pending approval."
                    completion(true)
                case 409:
                    self.alertMessage = "User login already exists. Please choose a different username."
                    self.userLogin = "" // Clear the conflicting username
                    self.userLoginError = ""
                    self.userLoginConflict = true // Set the conflict flag
                    self.showAlert = true
                    completion(false)
                default:
                    if let data = data, let serverMessage = String(data: data, encoding: .utf8) {
                        self.alertMessage = "Error: \(serverMessage)"
                    } else {
                        self.alertMessage = "An unknown error occurred. Please try again."
                    }
                    self.showAlert = true
                    completion(false)
                }
            }
        }.resume()
    }
    
    private func validateUserLogin(_ value: String) {
            if userLoginConflict {
                userLoginError = ""
            } else if value.isEmpty {
                userLoginError = "Username cannot be empty."
            } else if value.count < 4 {
                userLoginError = "Username must be at least 4 characters long."
            } else if value.contains(" ") {
                userLoginError = "Username cannot contain spaces."
            } else {
                userLoginError = ""
            }
        }

}
