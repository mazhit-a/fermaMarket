import SwiftUI

struct HomePageView: View {
    @State private var randomProducts: [Product] = []
    @State private var categories: [String] = []
    @State private var errorMessage: String?
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("TOP Products")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if !randomProducts.isEmpty {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack {
                                                    ForEach(randomProducts, id: \.productid) { product in
                                                        NavigationLink(destination: ProductDetailView(product: product)) {
                                                            ProductCard(product: product, cartManager: cartManager)
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)
                                        } else {
                        Text("Loading products...")
                            .padding(.horizontal)
                    }

                    Divider().padding(.vertical)

                    Text("Categories")
                        .font(.headline)
                        .padding(.horizontal)

                    if !categories.isEmpty {
                        ForEach(categories, id: \.self) {
                            category in NavigationLink(destination: CategoryProductsView(category: category)) {
                                Text(category)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    else {
                        Text("Loading categories...")
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("FERMA")
            .onAppear(perform: fetchHomePageData)
        }
    }

    private func fetchHomePageData() {
        fetchRandomProducts()
        fetchCategories()
    }

    private func fetchRandomProducts() {
        print("d")
        guard let url = URL(string: "http://localhost:3000/api/v1/products/random-products") else {
            errorMessage = "Invalid product URL"
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let products = try JSONDecoder().decode([Product].self, from: data)
                    DispatchQueue.main.async {
                        self.randomProducts = products
                    }
                    print("dada")
                } catch {
                    print("Error decoding products: \(error)")
                }
            }
        }.resume()
    }

    private func fetchCategories() {
        guard let url = URL(string: "http://localhost:3000/api/v1/products/categories") else {
            errorMessage = "Invalid categories URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let categories = try JSONDecoder().decode([String].self, from: data)
                    DispatchQueue.main.async {
                        self.categories = categories
                    }
                } catch {
                    print("Error decoding categories: \(error)")
                }
            }
        }.resume()
    }
}


struct ProductCard: View {
    let product: Product
    @ObservedObject var cartManager: CartManager

    var body: some View {
        VStack {
            if let url = URL(string: product.image_url) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 150, height: 150)
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
                        } else {
                            Text("No Image")
                                .frame(width: 150, height: 150)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

            Text(product.name)
                .font(.headline)
            Text("$\(product.price/product.quantity) / pc.")
                .font(.subheadline)
            Text("\(product.quantity) in stock")
                .font(.subheadline)
            
            Button(action: {
                    cartManager.addToCart(product: product)
                }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .font(.title)
                }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 1)
        .frame(width: 170)
        
        
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}


struct Product: Codable {
    let productid: Int
    let farmid: Int
    let name: String
    let quantity: Int
    let description: String
    let category: String
    let organic_certification: String
    let price: Int
    let image_url: String
}

struct Category: Codable {
    let category: String
}
