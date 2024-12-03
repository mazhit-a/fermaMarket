import SwiftUI

struct OrdersFarmView: View {
    @AppStorage("farmID") private var farmID: String = ""
    @State private var groupedOrders: [String: [OrderFarmItem]] = [:]
    @State private var errorMessage: String?
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Orders...")
                        .padding()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if groupedOrders.isEmpty {
                    Text("No orders found for your farm.")
                        .padding()
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(groupedOrders.keys.sorted(), id: \.self) { status in
                            NavigationLink(
                                destination: OrderFarmItemsView(
                                    status: status,
                                    items: groupedOrders[status] ?? []
                                )
                            ) {
                                HStack {
                                    Text(status.capitalized)
                                    Spacer()
                                    Text("\(groupedOrders[status]?.count ?? 0)")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Orders")
            .onAppear {
                fetchOrders()
            }
        }
    }

    private func fetchOrders() {
        guard !farmID.isEmpty else {
            errorMessage = "Farm ID is missing. Please log in again."
            return
        }

        guard let url = URL(string: "http://localhost:3000/api/v1/orders/orders-by-farm/\(farmID)") else {
            errorMessage = "Invalid API URL."
            return
        }

        print("Fetching orders from: \(url)")

        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = "Error fetching orders: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    errorMessage = "No data received from server."
                    return
                }

                if let rawJSON = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(rawJSON)")
                }

                do {
                    let decodedResponse = try JSONDecoder().decode([String: [OrderFarmItem]].self, from: data)
                    groupedOrders = decodedResponse
                    errorMessage = nil
                } catch {
                    errorMessage = "No orders found for your farm"
                    print("Decoding Error: \(error.localizedDescription)")
                    print(String(data: data, encoding: .utf8) ?? "Invalid Data")
                }
            }
        }.resume()
    }
}

