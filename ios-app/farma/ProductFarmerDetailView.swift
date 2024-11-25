import SwiftUI

struct ProductFarmerDetailView: View {
    let product: FarmProduct

    @State private var name: String
    @State private var quantity: Int
    @State private var description: String
    @State private var category: String
    @State private var organicCertification: String
    @State private var price: Int

    @State private var showAlert = false
    @State private var errorMessage: String?

    init(product: FarmProduct) {
        self.product = product
        _name = State(initialValue: product.name)
        _quantity = State(initialValue: product.quantity)
        _description = State(initialValue: product.description)
        _category = State(initialValue: product.category)
        _organicCertification = State(initialValue: product.organic_certification)
        _price = State(initialValue: product.price)
    }

    var body: some View {
        Form {
            Section(header: Text("Product Information")) {
                TextField("Name", text: $name)
                TextField("Quantity", value: $quantity, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                TextField("Description", text: $description)
                TextField("Category", text: $category)
                TextField("Organic Certification", text: $organicCertification)
                TextField("Price", value: $price, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
            }

            Button("Save Changes") {
                saveProductDetails()
            }
            .foregroundColor(.white)
            .frame(width: 200, height: 50)
            .background(Color.green)
            .cornerRadius(10)
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
        }
        .navigationTitle("Edit Product")
    }

    private func saveProductDetails() {
        guard let url = URL(string: "http://localhost:3000/api/v1/products/\(product.productid)") else {
            errorMessage = "Invalid API URL"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let updatedProductData: [String: Any] = [
            "name": name,
            "quantity": quantity,
            "description": description,
            "category": category,
            "organic_certification": organicCertification,
            "price": price
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: updatedProductData)
            request.httpBody = jsonData
        } catch {
            errorMessage = "Failed to encode JSON: \(error.localizedDescription)"
            showAlert = true
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    errorMessage = "Failed to update product details"
                    showAlert = true
                    return
                }

                errorMessage = "Product updated successfully!"
                showAlert = true
            }
        }.resume()
    }
}

