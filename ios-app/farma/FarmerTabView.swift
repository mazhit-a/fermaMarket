import SwiftUI

struct MainFarmerTabView: View {
    @State private var products: [FarmProduct] = []

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
            
            ProfileManagementView()
                .tabItem {
                    Label("Account", systemImage: "person")
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
