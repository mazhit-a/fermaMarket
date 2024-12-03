import SwiftUI

struct Order: Identifiable, Decodable {
    let orderid: Int
    let buyerid: Int
    let order_date: String
    let total_price: String
    let payment_method: String
    let delivery_method: String
    let delivery_address: String
    
    var formattedDate: String {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = isoFormatter.date(from: order_date) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM yyyy"
                dateFormatter.locale = Locale(identifier: "en_US")
                return dateFormatter.string(from: date)
            } else {
                return "Invalid Date"
            }
        }
    
    var id: Int { orderid }
}

struct OrderDetail: Decodable {
    let orderid: Int
    let buyerid: Int
    let total_price: String
    let payment_method: String
    let delivery_method: String
    let delivery_address: String
    let items: [OrderItem] // Include items in the order

    struct OrderItem: Decodable {
        let productid: Int
        let product_name: String
        let quantity: Int
        let price: Int
        let image_url: String
        let status: String
    }
}


struct OrdersView: View {
    @State private var orders: [Order] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @AppStorage("userID") private var userID: String = ""

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Orders...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if orders.isEmpty {
                    Text("No orders found.")
                        .font(.headline)
                        .padding()
                } else {
                    List(orders) { order in
                        NavigationLink(destination: OrderDetailView(orderid: order.orderid)) {
                            VStack(alignment: .leading) {
                                Text("Order ID: \(order.orderid)")
                                    .font(.headline)
                                Text("Date: \(order.formattedDate)")
                                    .font(.subheadline)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Your Orders")
            .onAppear(perform: fetchOrders)
        }
    }
    

    private func fetchOrders() {
        guard let url = URL(string: "http://localhost:3000/api/v1/orders/buyer/\(userID)") else {
            errorMessage = "Invalid URL"
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Error fetching orders: \(error.localizedDescription)"
                    isLoading = false
                } else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        orders = try decoder.decode([Order].self, from: data)
                        isLoading = false
                    } catch {
                        errorMessage = "Failed to decode response: \(error.localizedDescription)"
                        print("Decoding error: \(error)") // Debug error
                        isLoading = false
                    }
                }
            }
        }.resume()
    }

}

