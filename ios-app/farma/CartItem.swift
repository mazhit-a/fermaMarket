import SwiftUI
import Combine

struct CartItem: Identifiable {
    let id = UUID()
    let product: Product
    var quantity: Int
}

class CartManager: ObservableObject {
    @Published var items: [CartItem] = []

    func addToCart(product: Product) {
        if let index = items.firstIndex(where: { $0.product.productid == product.productid }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
    }

    func totalItems() -> Int {
        return items.reduce(0) { $0 + $1.quantity }
    }

    func totalPrice() -> Int {
        return items.reduce(0) { $0 + ($1.quantity * $1.product.price) }
    }
    
    func clearCart() {
        items.removeAll()
    }
}
