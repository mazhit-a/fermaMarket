import SwiftUI

struct ProductSearchView: View {
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All Products"
    @State private var selectedLocation: String = "All Locations"
    @State private var categories: [String] = []
    @State private var locations: [String] = []
    @State private var filteredProducts: [Product] = []
    @State private var allProducts: [Product] = []
    @State private var farms: [Farm] = []
    @State private var errorMessage: String?
    @State private var selectedSortOrder: String = "None"
    @EnvironmentObject var cartManager: CartManager

    private let sortOptions = ["None", "Price: Low to High", "Price: High to Low"]

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar with Filters
                HStack {
                    TextField("Search products...", text: $searchText)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 40)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)

                    // Category Filter
                    Picker("Category", selection: $selectedCategory) {
                        Text("All Products").tag("All Products")
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()

                // Location Filter
                Picker("Location", selection: $selectedLocation) {
                    Text("All Locations").tag("All Locations")
                    ForEach(locations, id: \.self) { location in
                        Text(location).tag(location)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()

                // Sort Order Picker for Price
                Picker("Sort By", selection: $selectedSortOrder) {
                    ForEach(sortOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Display Products based on search, filter, and sort
                List(filteredProducts, id: \.productid) { product in
                    NavigationLink(destination: ProductDetailView(product: product)) {
                        ProductCard(product: product, cartManager: cartManager)
                    }
                }
                .onAppear(perform: fetchCategoriesAndProducts)
                .onChange(of: searchText) { _ in
                    filterProducts()
                }
                .onChange(of: selectedCategory) { _ in
                    filterProducts()
                }
                .onChange(of: selectedLocation) { _ in
                    filterProducts()
                }
                .onChange(of: selectedSortOrder) { _ in
                    filterProducts()
                }
            }
            .navigationTitle("Search Products")
        }
    }

    // Fetch categories, products, and farm locations
    private func fetchCategoriesAndProducts() {
        fetchCategories()
        fetchAllProducts()
        fetchFarms()
    }

    // Fetch all product categories
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

    // Fetch all products
    private func fetchAllProducts() {
        guard let url = URL(string: "http://localhost:3000/api/v1/products") else {
            errorMessage = "Invalid products URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let products = try JSONDecoder().decode([Product].self, from: data)
                    DispatchQueue.main.async {
                        self.allProducts = products
                        self.filterProducts()
                    }
                } catch {
                    print("Error decoding products: \(error)")
                }
            }
        }.resume()
    }

    // Fetch farm data to get locations
    private func fetchFarms() {
        guard let url = URL(string: "http://localhost:3000/api/v1/farms/locations") else {
            errorMessage = "Invalid farms URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let farms = try JSONDecoder().decode([Farm].self, from: data)
                    DispatchQueue.main.async {
                        self.farms = farms
                        self.locations = farms.map { $0.location }
                    }
                } catch {
                    print("Error decoding farms: \(error)")
                }
            }
        }.resume()
    }

    // Filter and sort products based on search text, category, location, and sort order
    private func filterProducts() {
        filteredProducts = allProducts.filter { product in
            let matchesSearchText = product.name.lowercased().contains(searchText.lowercased()) || searchText.isEmpty
            let matchesCategory = selectedCategory == "All Products" || product.category == selectedCategory
            let matchesLocation = selectedLocation == "All Locations" || farmLocation(for: product.farmid) == selectedLocation
            return matchesSearchText && matchesCategory && matchesLocation
        }

        // Sort the filtered products based on the selected price order
        switch selectedSortOrder {
        case "Price: Low to High":
            filteredProducts.sort { $0.price < $1.price }
        case "Price: High to Low":
            filteredProducts.sort { $0.price > $1.price }
        default:
            break
        }
    }

    // Helper function to get farm location by farmId
    private func farmLocation(for farmid: Int) -> String {
        return farms.first(where: { $0.farmid == farmid })?.location ?? "Unknown"
    }
}

struct ProductSearchView_Previews: PreviewProvider {
    static var previews: some View {
        ProductSearchView()
    }
}

struct Farm: Decodable {
    let farmid: Int
    let location: String
}
