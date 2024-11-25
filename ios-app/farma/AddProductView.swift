import SwiftUI
import PhotosUI

struct AddProductView: View {
    @Binding var products: [FarmProduct]
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var category = ""
    @State private var price = ""
    @State private var quantity = ""
    @State private var description = ""
    @State private var isOrganic = false
    @State private var selectedImage: UIImage?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToMainFarmerTab = false
    @State private var isImagePickerPresented = false
    let farmid = "1233"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Product Name", text: $name)
                TextField("Category (e.g., vegetables, fruits)", text: $category)
                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)
                TextField("Quantity", text: $quantity)
                    .keyboardType(.numberPad)
                TextField("Description", text: $description)
                Toggle("Is Organic", isOn: $isOrganic)

                Button("Select Image") {
                    isImagePickerPresented = true
                }
                .foregroundColor(.green)

                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }

                Button("Add Product") {
                    submitProduct()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(8)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Product Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("Add Product")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }

            NavigationLink(
                destination: MainFarmerTabView(),
                isActive: $navigateToMainFarmerTab
            ) {
                EmptyView()
            }
        }
    }

    private func submitProduct() {
        guard let url = URL(string: "http://localhost:3000/api/v1/products") else {
            alertMessage = "Invalid API URL"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=Boundary", forHTTPHeaderField: "Content-Type")

        var body = Data()
        let boundary = "Boundary"

        let textFields: [String: String] = [
            "farmer_id": farmid,
            "name": name,
            "quantity": quantity,
            "description": description,
            "category": category,
            "organic_certification": isOrganic ? "true" : "false",
            "price": price
        ]

        for (key, value) in textFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        if let selectedImage = selectedImage,
           let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"product.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    alertMessage = "Invalid response from server"
                    showAlert = true
                    return
                }

                if httpResponse.statusCode == 201 {
                    if let data = data, let addedProduct = try? JSONDecoder().decode(FarmProduct.self, from: data) {
                        products.append(addedProduct)
                    }
                    alertMessage = "Product added successfully!"
                    navigateToMainFarmerTab = true
                } else {
                    alertMessage = "Failed to add product. Status code: \(httpResponse.statusCode)"
                }

                showAlert = true
            }
        }.resume()
    }
}
