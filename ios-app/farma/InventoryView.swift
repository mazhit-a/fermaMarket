import SwiftUI

struct InventoryView: View {
    @State private var allProducts: [FarmProduct] = []
    @State private var errorMessage: String?
    let farmid = "3948"

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Your Inventory:")
                    .font(.system(size: 36))
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.top, 16)

                if let error = errorMessage {
                   Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if allProducts.isEmpty {
                    Text("No products yet...")
                        .padding(.horizontal)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(allProducts, id: \.productid) { product in
                                NavigationLink(destination: ProductFarmerDetailView(product: product)) {
                                    ProductFarmerView(product: product, onChange: { updatedProduct in
                                        handleProductChange(updatedProduct)
                                    })
                                }
                                .frame(height: 200)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.3)))
                                .shadow(radius: 5)
                            }
                        }
                        .padding(.horizontal)
                    }
                 }
            }
            .navigationTitle("Welcome, farmer!")
            .onAppear {
                fetchAllProducts()
            }
        }
    }

    private func fetchAllProducts() {
        guard let url = URL(string: "http://localhost:3000/api/v1/products?farmer_id=\(farmid)") else {
            errorMessage = "Invalid products URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching products: \(error.localizedDescription)"
                }
                return
            }

            if let data = data {
                do {
                    let products = try JSONDecoder().decode([FarmProduct].self, from: data)
                    DispatchQueue.main.async {
                        self.allProducts = products
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error decoding products: \(error.localizedDescription)"
                    }
                }
            }
        }.resume()
    }

    private func handleProductChange(_ product: FarmProduct) {
        guard let url = URL(string: "http://localhost:3000/api/v1/products/\(product.productid)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let updatedProductData: [String: Any] = [
            "name": product.name,
            "quantity": product.quantity,
            "description": product.description,
            "category": product.category,
            "organic_certification": product.organic_certification,
            "price": product.price
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: updatedProductData)
            request.httpBody = jsonData
        } catch {
            print("Error encoding data: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error updating product: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Product updated successfully")
                DispatchQueue.main.async {
                    fetchAllProducts()
                }
            } else {
                print("Failed to update product")
            }
        }.resume()
    }
}

