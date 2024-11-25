import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showOrderConfirmation = false // State to handle order confirmation

    var body: some View {
        VStack {
            if cartManager.items.isEmpty {
                Text("Your cart is empty.")
                    .font(.headline)
                    .padding()
            } else {
                // Display the cart items
                List {
                    ForEach(cartManager.items) { item in
                        HStack {
                            AsyncImage(url: URL(string: item.product.image_url)) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                } else if phase.error != nil {
                                    Text("Image Error")
                                        .foregroundColor(.red)
                                        .frame(width: 50, height: 50)
                                } else {
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                }
                            }
                            Text(item.product.name)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Text("Qty: \(item.quantity)")
                            Text("$\(item.product.price / item.product.quantity * item.quantity)")
                        }
                    }
                }
                .listStyle(PlainListStyle())

                // Total price section
                HStack {
                    Text("Total:")
                        .font(.headline)
                    Spacer()
                    Text("$\(cartManager.totalPrice())")
                        .font(.headline)
                }
                .padding()

                // Place Order Button
                Button(action: {
                    placeOrder()
                }) {
                    Text("Place Order")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .alert(isPresented: $showOrderConfirmation) {
                    Alert(
                        title: Text("Order Placed"),
                        message: Text("Thank you for your order!"),
                        dismissButton: .default(Text("OK"), action: {
                            cartManager.clearCart() // Clear the cart after placing the order
                        })
                    )
                }
            }
        }
        .navigationTitle("Cart")
    }

    private func placeOrder() {
        // Simulate order placement logic
        showOrderConfirmation = true
    }
}
