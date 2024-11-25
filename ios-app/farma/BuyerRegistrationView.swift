import SwiftUI

enum RegistrationDestination: Hashable {
    case loginView
    case registerView
}

struct BuyerRegistrationView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var deliveryAddress: String = ""
    @State private var preferredPaymentMethod: String = "Credit Card"
    @State private var userLogin: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var nameError = ""
    @State private var emailError = ""
    @State private var phoneError = ""
    @State private var passwordError = ""
    
    @State private var registrationDestination: RegistrationDestination? = nil
    @State private var registrationError = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                        .onChange(of: name) { _ in validateName() }
                    if !nameError.isEmpty {
                        Text(nameError).foregroundColor(.red)
                    }
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .onChange(of: email) { _ in validateEmail() }
                    if !emailError.isEmpty {
                        Text(emailError).foregroundColor(.red)
                    }
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .onChange(of: phoneNumber) { _ in validatePhoneNumber() }
                    if !phoneError.isEmpty {
                        Text(phoneError).foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Delivery Information")) {
                    TextField("Delivery Address", text: $deliveryAddress)
                }
                
                Section(header: Text("Payment Information")) {
                    Picker("Preferred Payment Method", selection: $preferredPaymentMethod) {
                        Text("Credit Card").tag("Credit Card")
                        Text("Debit Card").tag("Debit Card")
                        Text("Cash on Delivery").tag("Cash on Delivery")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                TextField("User Login", text: $userLogin)
                SecureField("Password", text: $password)
                    .onChange(of: password) { _ in validatePassword() }
                SecureField("Confirm Password", text: $confirmPassword)
                    .onChange(of: confirmPassword) { _ in validatePassword() }
                if !passwordError.isEmpty {
                    Text(passwordError).foregroundColor(.red)
                }
                
                Button("Submit Registration") {
                    if validateAllFields() {
                        handleRegistration()
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(validateAllFields() ? Color.green : Color.gray)
                .cornerRadius(10)
                .disabled(!validateAllFields())
                
                // Navigation Links
                NavigationLink(tag: RegistrationDestination.loginView, selection: $registrationDestination) {
                    LoginView()
                } label: {
                    EmptyView()
                }
                
                NavigationLink(tag: RegistrationDestination.registerView, selection: $registrationDestination) {
                    RegisterView()
                } label: {
                    EmptyView()
                }
            }
            .navigationTitle("Buyer Registration")
            .alert("Registration Failed", isPresented: $registrationError) {
                Button("OK", action: {})
            } message: {
                Text("There was an error registering your account. Please try again.")
            }
        }
    }
    
    private func validateName() {
        nameError = name.isEmpty ? "Name cannot be empty." : ""
    }
    
    private func validateEmail() {
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
            phoneError = "Invalid phone number."
        } else {
            phoneError = ""
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
        if name.isEmpty || email.isEmpty || phoneNumber.isEmpty || deliveryAddress.isEmpty || userLogin.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            return false
        }
        
        if !emailError.isEmpty || !phoneError.isEmpty || !passwordError.isEmpty {
            return false
        }
        
        return true
    }
    
    private func handleRegistration() {
        guard let url = URL(string: "http://localhost:3000/api/v1/buyers") else {
            print("Invalid API URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userDetails: [String: Any] = [
            "name": name,
            "email": email,
            "phone_number": phoneNumber,
            "delivery_address": deliveryAddress,
            "preferred_payment": preferredPaymentMethod,
            "userLogin": userLogin,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: userDetails) else {
            print("Failed to encode user details")
            return
        }
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    registrationError = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    registrationError = true
                    return
                }
                
                // Registration successful
                registrationDestination = .loginView
            }
        }.resume()
    }
}

