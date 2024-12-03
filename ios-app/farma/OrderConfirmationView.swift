import SwiftUI

struct OrderConfirmationView: View {
    @EnvironmentObject var cartManager: CartManager
    let orderID: Int?
    let deliveryDate = "december 3"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Order Successful!")
                .font(.title)
                .foregroundColor(.green)
                .padding()

            if let orderID = orderID {
                Text("Order ID: \(orderID)")
                    .font(.headline)
            }
            
            Text("Estimated Delivery Date: \(deliveryDate)")
                .foregroundColor(.gray)

            Spacer()

            Button(action: {
                // Navigate back to MainTabView
                if let window = UIApplication.shared.windows.first {
                    window.rootViewController = UIHostingController(rootView: MainTabView().environmentObject(cartManager))
                    window.makeKeyAndVisible()
                }
            }) {
                Text("Go to Homepage")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true) // Prevent going back to order placement
    }
}
