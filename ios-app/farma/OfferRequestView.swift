import SwiftUI

struct OfferRequestView: View {
    let product: Product
    @State private var offerPrice: String = ""
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("userID") private var userID: String = ""

    func submitOffer() {
        guard let offerPriceValue = Int(offerPrice), offerPriceValue > 0 else {
            print("Invalid offer price")
            return
        }

        // Example API call to submit the offer
        let offerData: [String: Any] = [
            "productid": product.productid,
            "farmid": product.farmid,
            "buyerid": userID,
            "offered_price": offerPriceValue
        ]
        
        OfferAPI.submitOffer(offerData) { success in
            if success {
                print("Offer submitted successfully")
            } else {
                print("Failed to submit offer")
            }
            presentationMode.wrappedValue.dismiss() // Close the sheet
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Request an Offer")
                    .font(.title)
                    .padding()

                Text("Propose your price for \(product.name):")
                    .font(.headline)

                TextField("Enter your offer price", text: $offerPrice)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: submitOffer) {
                    Text("Submit Offer")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                Spacer()
            }
            .padding()
            .navigationTitle("Request Offer")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

