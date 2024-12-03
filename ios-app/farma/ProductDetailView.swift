import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cartManager: CartManager
    @State private var showOfferSheet = false // State for showing the offer sheet

    var body: some View {
        VStack {
            // Display the product image
            AsyncImage(url: URL(string: product.image_url)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else if phase.error != nil {
                    Text("Image Error")
                        .foregroundColor(.red)
                        .frame(width: 150, height: 150)
                } else {
                    ProgressView()
                        .frame(width: 150, height: 150)
                }
            }

            // Product details
            Text(product.name)
                .font(.title)
                .padding()
            
            Text("Farm: \(product.farm_name)")
                .font(.body)
                .padding()
            Text(product.description)
                .font(.body)
                .padding()

            Text("Price: ₸\(product.price) per piece")
                .font(.subheadline)
                .padding()

            Text("Stock: \(product.quantity) items")
                .font(.subheadline)
                .padding()

            Spacer()

            // Add to Cart Button
            Button(action: {
                cartManager.addToCart(product: product)
            }) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                        .font(.title)
                    Text("Add to Cart")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }

            // Request Offer Button
            Button(action: {
                showOfferSheet = true // Show the offer sheet
            }) {
                HStack {
                    Image(systemName: "tag")
                        .font(.title)
                    Text("Request Offer")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
        }
        .navigationTitle(product.name)
        .padding()
        .sheet(isPresented: $showOfferSheet) {
            OfferRequestView(product: product)
        }
    }
}

