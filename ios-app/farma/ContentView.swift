import SwiftUI

struct ContentView: View {
   
    @State private var showLogin = false
    @State private var showRegister = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to Farmer Market")
                    .font(.largeTitle)
                    .padding()
                
                Button("Login") {
                    showLogin = true
                }
                .primaryButton()
                .sheet(isPresented: $showLogin) {
                    LoginView()
                }
                
                Button("Register") {
                    showRegister = true
                }
                .primaryButton()
                .sheet(isPresented: $showRegister) {
                    RegisterView()
                }
            }
        }
    }
}


