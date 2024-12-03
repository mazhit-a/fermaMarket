import SwiftUI

struct Offer: Identifiable, Codable {
    let offer_id: Int
    let productid: Int
    let buyerid: Int
    let offered_price: Int
    let status: String
    let created_at: String
    let farmid: Int

    var id: Int { offer_id }
}

struct OfferManagementView: View {
    @State private var offers: [Offer] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    @AppStorage("farmID") private var farmID: String = ""

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading offers...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if offers.isEmpty {
                    Text("No offers found for your products.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(offers) { offer in
                        VStack(alignment: .leading) {
                            Text("Offer ID: \(offer.offer_id)")
                                .font(.headline)
                            Text("Product ID: \(offer.productid)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Buyer ID: \(offer.buyerid)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Offered Price: $\(offer.offered_price)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Text("Status: \(offer.status)")
                                .font(.subheadline)
                                .foregroundColor(statusColor(for: offer.status))
                            Text("Date: \(offer.created_at)")
                                .font(.caption)
                                .foregroundColor(.gray)

                            // Action Buttons
                            HStack {
                                Button("Accept") {
                                    handleAccept(offer: offer)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)

                                Button("Reject") {
                                    handleReject(offer: offer)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)

                                Button("Counter") {
                                    handleCounter(offer: offer)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.blue)
                            }
                            .padding(.top, 5)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Offers")
            .onAppear(perform: fetchOffers)
        }
    }

    // Fetch offers from the backend
    private func fetchOffers() {
        guard let url = URL(string: "http://localhost:3000/api/v1/offers/farm/\(farmID)") else {
            errorMessage = "Invalid API URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Failed to load offers: \(error.localizedDescription)"
                } else if let data = data {
                    do {
                        let decodedOffers = try JSONDecoder().decode([Offer].self, from: data)
                        self.offers = decodedOffers
                    } catch {
                        errorMessage = "Failed to decode response: \(error.localizedDescription)"
                    }
                } else {
                    errorMessage = "Unknown error occurred"
                }
                isLoading = false
            }
        }.resume()
    }

    // Handle Accept
    private func handleAccept(offer: Offer) {
        updateOfferStatus(offer: offer, status: "approved")
        
    }

    // Handle Reject
    private func handleReject(offer: Offer) {
        updateOfferStatus(offer: offer, status: "rejected")
    }

    // Handle Counter
    private func handleCounter(offer: Offer) {
        // Implement counter logic, e.g., present a dialog to input a new price
        print("Counter Price for Offer ID: \(offer.offer_id)")
    }

    // Update offer status in the backend
    private func updateOfferStatus(offer: Offer, status: String) {
        guard let url = URL(string: "http://localhost:3000/api/v1/offers/offers/\(offer.offer_id)/\(status)") else {
            errorMessage = "Invalid API URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["status": status]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Failed to update status: \(error.localizedDescription)"
                } else {
                    fetchOffers() // Refresh offers
                }
            }
        }.resume()
    }

    // Helper to color status text
    private func statusColor(for status: String) -> Color {
        switch status {
        case "pending": return .yellow
        case "approved": return .green
        case "rejected": return .red
        default: return .gray
        }
    }
}
