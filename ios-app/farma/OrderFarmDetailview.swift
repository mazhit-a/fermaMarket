import SwiftUI

struct OrderFarmDetailView: View {
    @State var items: [OrderFarmItem]
    let buyerID: Int
    let onUpdate: () -> Void

    @State private var showAlert = false
    @State private var alertMessage: String?
    @State private var isLoading = false
    
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Updating Items...")
                    .padding()
            } else {
                List {
                    Section(header: Text("Buyer Details")) {
                        Text("Buyer Name: \(items.first?.buyer_name ?? "Unknown")")
                            .fontWeight(.bold)
                        Text("Buyer ID: \(buyerID)")
                    }

                    Section(header: Text("Order Items")) {
                        ForEach(items) { item in
                            VStack(alignment: .leading, spacing: 5) {
                                if let imageUrl = item.image_url, let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 100, height: 100)
                                    }
                                } else {
                                    Rectangle()
                                        .fill(Color.gray)
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                }

                                Text("Product: \(item.product_name)")
                                    .font(.headline)
                                Text("Quantity: \(item.quantity)")
                                Text("Status: \(item.status)")
                                    .fontWeight(.bold)
                                    .foregroundColor(item.status == "confirmed" || item.status == "Confirmed" ? .green : (item.status == "rejected" || item.status == "Rejected" ? .red : item.status == "delivered" || item.status == "Delivered" ? .yellow : .primary))
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }

                Spacer()
                
                if items.contains(where: { $0.status == "confirmed" }) {
                    HStack {
                        ActionButton(title: "Order is delivered", backgroundColor: .yellow) {
                            updateItemsStatus(to: "delivered")
                        }
                    }
                    .padding(.horizontal)
                    
                }

                if items.contains(where: { $0.status == "Pending" }) {
                    HStack {
                        ActionButton(title: "Confirm Order", backgroundColor: .green) {
                            updateItemsStatus(to: "confirmed")
                        }
                        ActionButton(title: "Reject Order", backgroundColor: .red) {
                            updateItemsStatus(to: "rejected")
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Order Details")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Order Update"),
                message: Text(alertMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                    onUpdate()
                }
            )
        }
    }

    private func updateItemsStatus(to newStatus: String) {
        guard let url = URL(string: "http://localhost:3000/api/v1/orders/order-items/update-status") else {
            alertMessage = "Invalid API URL"
            showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let updatedItems = items.map { ["order_item_id": $0.order_item_id, "status": newStatus] }
        let payload = ["items": updatedItems]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            alertMessage = "Error encoding JSON: \(error.localizedDescription)"
            showAlert = true
            return
        }

        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    alertMessage = "Network error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    alertMessage = "Failed to update items' status"
                    showAlert = true
                    return
                }

                items.indices.forEach { items[$0].status = newStatus }

                alertMessage = "Item(s) \(newStatus.lowercased()) successfully!"
                showAlert = true
            }
        }.resume()
    }
}






struct DetailFarmRowView: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.bold)
            Spacer()
            Text(value)
        }
        .padding(.vertical, 5)
    }
}

struct OrderFarmItemRowView: View {
    let item: OrderFarmItem

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Product ID: \(item.productid)")
                .font(.headline)
            Text("Quantity: \(item.quantity)")
            Text("Status: \(item.status)")
        }
        .padding(.vertical, 5)
    }
}

struct ActionButton: View {
    let title: String
    let backgroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

