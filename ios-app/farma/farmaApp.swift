//
//  farmaApp.swift
//  farma
//
//  Created by MacBook on 20.11.2024.
//

import SwiftUI

@main
struct farmaApp: App {
    @StateObject private var cartManager = CartManager()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(cartManager)
        }
    }
}
