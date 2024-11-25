import SwiftUI


struct RegisterView: View {
    @State private var selectedRole: String = "Farmer"
    //@Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Register as:")
                    .font(.title)
                    .padding()
                
                Picker("Select Role", selection: $selectedRole) {
                    Text("Farmer").tag("Farmer")
                    Text("Buyer").tag("Buyer")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedRole == "Farmer" {
                    NavigationLink(destination: FarmerRegistrationView()) {
                        Text("Register as Farmer")
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)

                    }
                } else {
                    NavigationLink(destination: BuyerRegistrationView()) {
                        Text("Register as Buyer")
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)

                    }
                }
            }
            .navigationTitle("Register")
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}



