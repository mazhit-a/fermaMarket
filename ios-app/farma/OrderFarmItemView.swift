import SwiftUI

struct OrderFarmItemsView: View {
    let status: String
    let items: [OrderFarmItem]

    var body: some View {
        List(items) { item in
            NavigationLink(
                destination: OrderFarmDetailView(
                    items: [item],
                    buyerID: item.buyerid,
                    onUpdate: {}
                )
            ) {
                OrderFarmRowView(orderItem: item)
            }
        }
        .navigationTitle("\(status.capitalized) Orders")
    }
}

