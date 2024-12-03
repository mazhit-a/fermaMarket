import SwiftUI

struct InventoryView: View {
    @State private var allProducts: [FarmProduct] = []
    @State private var lowStockProducts: [FarmProduct] = []
    @State private var errorMessage: String?
    @State private var showLowStockAlert = false
    @AppStorage("farmID") private var farmID: String = ""

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
                    Text("Loading products...")
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
                                .background(RoundedRectangle(cornerRadius: 12)
                                                .fill(product.quantity < 5 ? Color.red.opacity(0.3) : Color.green.opacity(0.3)))
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
            .alert(isPresented: $showLowStockAlert) {
                Alert(
                    title: Text("Low Stock Alert"),
                    message: Text("You have products with low stock. Please restock them."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func fetchAllProducts() {
        guard !farmID.isEmpty else {
            errorMessage = "Farm ID is missing. Please log in again."
            return
        }

        guard let url = URL(string: "http://localhost:3000/api/v1/products/fari?farmer_id=\(farmID)") else {
            errorMessage = "Invalid products URL"
            return
        }

        print("Fetching products for Farm ID: \(farmID)")

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
                        self.lowStockProducts = products.filter { $0.quantity < 5 }
                        self.showLowStockAlert = !self.lowStockProducts.isEmpty
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
