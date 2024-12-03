import SwiftUI

struct OrderFarmRowView: View {
    let orderItem: OrderFarmItem

    var body: some View {
        HStack {
            if let imageUrl = orderItem.image_url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading) {
                Text(orderItem.product_name)
                    .font(.headline)
                Text("Buyer: \(orderItem.buyer_name)")
                    .font(.subheadline)
                Text("Quantity: \(orderItem.quantity)")
                    .font(.subheadline)
                Text("Status: \(orderItem.status)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 8)
        }
        .padding()
    }
}


