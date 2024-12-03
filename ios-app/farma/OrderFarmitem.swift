import SwiftUI


struct OrderFarmItem: Identifiable, Codable {
    var id: Int { order_item_id }
    let order_item_id: Int
    let productid: Int
    let quantity: Int
    var status: String
    let buyerid: Int
    let buyer_name: String
    let product_name: String
    let image_url: String?
}


