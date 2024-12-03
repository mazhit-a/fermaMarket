import SwiftUI

struct MainFarmerTabView: View {
    @State private var products: [FarmProduct] = []
    @AppStorage("farmID") private var farmID: String = ""
    
    var body: some View {
        TabView {
            InventoryView()
                .tabItem {
                    Label("Inventory", systemImage: "tray")
                }
            
            AddProductView(products: $products)
                .tabItem {
                    Label("Add Product", systemImage: "plus.circle")
                }
            
            OrdersFarmView()
                .tabItem {
                    Label("Orders", systemImage: "shippingbox")
                }
            
            ProfileManagementView()
                .tabItem {
                    Label("Account", systemImage: "person")
                }
            
            OfferManagementView()
                .tabItem {
                    Label("Offers", systemImage: "checkmark.message.fill")
                }
            
            
        }
        .accentColor(.green)
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.white
            UITabBar.appearance().unselectedItemTintColor = UIColor.black
        }
    }
}

struct FarmProduct: Codable {
    let farmid: Int
    let name: String
    let quantity: Int
    let description: String
    let category: String
    let organic_certification: String
    let price: Int
    let productid: Int
    let image_url: String?
}
