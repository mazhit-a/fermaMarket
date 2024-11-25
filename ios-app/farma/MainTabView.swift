import SwiftUI

struct MainTabView: View {
    @State private var products: [Product] = []
    @EnvironmentObject var cartManager: CartManager


    var body: some View {
        TabView {
            HomePageView()
                .tabItem {
                    Label("Home", systemImage: "tray")
                }
            
            ProductSearchView()
                .tabItem {
                    Label("Search", systemImage: "plus.circle")
                }
            
            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart")
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

