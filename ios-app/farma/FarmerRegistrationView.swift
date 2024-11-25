import SwiftUI
import Combine

struct FarmerRegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var farmAddress = ""
    @State private var farmSize = ""
    @State private var cropTypes = ""
    @State private var governmentID = ""
    @State private var userLogin = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToLogin = false
    @State private var governmentIDError = ""
    @State private var passwordError = ""
    @State private var emailError = ""
    
    private var emailPublisher = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupEmailValidation()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                        .autocapitalization(.words)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .onChange(of: email) { emailPublisher.send($0) }
                    if !emailError.isEmpty {
                        Text(emailError).foregroundColor(.red)
                    }
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .onChange(of: phoneNumber) { _ in validatePhoneNumber() }
                }

                Section(header: Text("Verification")) {
                    TextField("Government-Issued ID", text: $governmentID)
                        .onChange(of: governmentID) { _ in validateGovernmentID() }
                    if !governmentIDError.isEmpty {
                        Text(governmentIDError).foregroundColor(.red)
                    }
                }

                Section(header: Text("Farm Details")) {
                    TextField("Farm Address", text: $farmAddress)
                    TextField("Farm Size (in acres)", text: $farmSize)
                        .keyboardType(.decimalPad)
                    TextField("Types of Crops", text: $cropTypes)
                }

                Section(header: Text("Create Your Account")) {
                    TextField("User Login", text: $userLogin)
                    SecureField("Password", text: $password)
                        .onChange(of: password) { _ in validatePassword() }
                    SecureField("Confirm Password", text: $confirmPassword)
                        .onChange(of: confirmPassword) { _ in validatePassword() }
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
        }
    }

    private func setupEmailValidation() {
        var cancellables = Set<AnyCancellable>()
        emailPublisher
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { email in
                self.validateEmail(email: email)
            }
            .store(in: &cancellables)
    }


    private func validateGovernmentID() {
        governmentIDError = governmentID.isEmpty ? "Government ID cannot be empty." : ""
    }

    private func validateEmail(email: String) {
        if email.isEmpty {
            emailError = "Email cannot be empty."
        } else if !email.contains("@") || !email.contains(".") {
            emailError = "Invalid email address."
        } else {
            emailError = ""
        }
    }

    private func validatePhoneNumber() {
        if phoneNumber.isEmpty || phoneNumber.count < 10 || !phoneNumber.allSatisfy({ $0.isNumber }) {
            alertMessage = "Invalid phone number."
            showAlert = true
        }
    }

    private func validatePassword() {
        if password.isEmpty || password.count < 8 {
            passwordError = "Password must be at least 8 characters long."
        } else if password != confirmPassword {
            passwordError = "Passwords do not match."
        } else {
            passwordError = ""
        }
    }

    private func validateAllFields() -> Bool {
        if name.isEmpty || email.isEmpty || phoneNumber.isEmpty || farmAddress.isEmpty || farmSize.isEmpty || cropTypes.isEmpty || governmentID.isEmpty || userLogin.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            alertMessage = "All fields are required."
            showAlert = true
            return false
        }

        if !emailError.isEmpty || !passwordError.isEmpty || !governmentIDError.isEmpty {
            alertMessage = "Please fix errors before proceeding."
            showAlert = true
            return false
        }

        return true
    }

    private func submitRegistration() {
        saveUserDetails { success in
            if success {
                self.alertMessage = "Your registration is pending."
                self.navigateToLogin = false
            } else {
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
            "address": farmAddress,
            "size": farmSize,
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
                    print("Error: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    print("Failed with status code or no response.")
                    completion(false)
                    return
                }

                print("Registration successful!")
                completion(true)
            }
        }.resume()
    }
}



