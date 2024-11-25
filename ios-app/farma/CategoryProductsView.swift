import SwiftUI

struct CategoryProductsView: View {
    let category: String
    @State private var products: [Product] = []
    @State private var errorMessage: String?
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        VStack {
            if products.isEmpty {
                Text("Loading products...")
                    .padding()
            } else {
                List(products, id: \.productid) { product in
                    ProductCard(product: product, cartManager: cartManager)
                }
            }
        }
        .navigationTitle(category)
        .onAppear(perform: fetchProducts)
    }

    private func fetchProducts() {
        guard let url = URL(string: "http://localhost:3000/api/v1/products?category=\(category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            errorMessage = "Invalid product URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let products = try JSONDecoder().decode([Product].self, from: data)
                    DispatchQueue.main.async {
                        self.products = products
                    }
                } catch {
                    print("Error decoding products: \(error)")
                }
            }
        }.resume()
    }
}
