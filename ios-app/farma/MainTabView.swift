import SwiftUI

struct MainTabView: View {
    @State private var products: [Product] = []
    @EnvironmentObject var cartManager: CartManager
    @AppStorage("userID") private var userID: String = ""

    var body: some View {
        TabView {
            HomePageView()
                .tabItem {
                    Label("Home", systemImage: "tray")
                }
            
            ProductSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
            
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left")
                }
            
            OrdersView() // New Orders tab
                .tabItem {
                    Label("Orders", systemImage: "list.bullet.rectangle")
                }
        }
        .navigationBarBackButtonHidden(true)
        .accentColor(.green)
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.white
            UITabBar.appearance().unselectedItemTintColor = UIColor.black
        }
    }
}
