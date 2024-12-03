import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var showOrderPlacementView = false // State to handle navigation to OrderPlacementView
    @State private var stockError: String? // State to display stock error messages

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
                            Text("₸\(item.product.price * item.quantity)")
                        }
                    }
                }
                .listStyle(PlainListStyle())

                // Total price section
                HStack {
                    Text("Total:")
                        .font(.headline)
                    Spacer()
                    Text("₸\(cartManager.totalPrice())")
                        .font(.headline)
                }
                .padding()

                // Place Order Button
                Button(action: {
                    if checkStockAvailability() {
                        showOrderPlacementView = true // Trigger navigation if stock is sufficient
                    }
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
                .disabled(cartManager.items.isEmpty) // Disable button if the cart is empty

                // Display stock error if any
                if let error = stockError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }

                // NavigationLink to OrderPlacementView
                NavigationLink(
                    destination: OrderPlacementView().environmentObject(cartManager),
                    isActive: $showOrderPlacementView
                ) {
                    EmptyView()
                }
            }
        }
        .navigationTitle("Cart")
    }

    /// Function to check stock availability for all items in the cart
    private func checkStockAvailability() -> Bool {
        for item in cartManager.items {
            if item.quantity > item.product.quantity {
                stockError = "The selected quantity for \(item.product.name) exceeds the available stock (\(item.product.quantity) available)."
                return false
            }
        }
        stockError = nil // Clear any previous errors
        return true
    }
}
