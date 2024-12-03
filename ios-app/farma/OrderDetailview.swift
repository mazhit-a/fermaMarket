import SwiftUI

struct OrderDetailView: View {
    let orderid: Int
    @State private var orderDetail: OrderDetail?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        
        VStack {
            if isLoading {
                ProgressView("Loading Order Details...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if let order = orderDetail {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Order ID: \(order.orderid)")
                        .font(.headline)
                    Text("Delivery method: \(order.delivery_method)")
                        .font(.title3)
                    Text("Delivery address: \(order.delivery_address)")
                        .font(.title3)
                    Text("Payment method: \(order.payment_method)")
                        .font(.title3)
                    Text("Total Price: ₸\(order.total_price)")
                        .font(.title3)
                    
                    Divider()

                    Text("Ordered Items:")
                        .font(.headline)

                    List(order.items, id: \.productid) { item in
                        VStack(alignment: .leading) {
                            AsyncImage(url: URL(string: item.image_url)) { phase in
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
                            
                            Text(item.status)
                                    .italic()
                                    .foregroundColor(getStatusColor(status: item.status))
                                    .fontWeight(item.status == "delivered" ? .bold : .regular)
                            Text(item.product_name)
                                .font(.subheadline)
                            Text("Quantity: \(item.quantity)")
                            Text("Total: ₸\(item.price)")
                                .fontWeight(.bold)
                        }
                        .padding()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Order Details")
        .onAppear(perform: fetchOrderDetail)
    }
    
    func getStatusColor(status: String) -> Color {
        switch status {
        case "pending":
            return .yellow
        case "confirmed":
            return .green
        case "rejected":
            return .red
        case "delivered":
            return .green
        default:
            return .primary // Default color for unknown statuses
        }
    }
    
    private func fetchOrderDetail() {
        guard let url = URL(string: "http://localhost:3000/api/v1/orders/\(orderid)") else {
            errorMessage = "Invalid URL"
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Error fetching order details: \(error.localizedDescription)"
                    isLoading = false
                } else if let data = data {
                    do {
                        orderDetail = try JSONDecoder().decode(OrderDetail.self, from: data)
                        isLoading = false
                    } catch {
                        errorMessage = "Failed to decode response"
                        isLoading = false
                    }
                }
            }
        }.resume()
    }
}
