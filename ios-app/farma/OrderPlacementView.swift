import SwiftUI

struct OrderPlacementView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var selectedDeliveryMethod: String = "Pick-up" // Default to "Pick-up"
    @State private var deliveryAddress: String = ""
    @State private var selectedPaymentMethod: String = "Credit Card" // Default payment method
    @State private var deliveryCost: Int = 0 // Cost of the selected delivery method
    @State private var orderID: Int? = nil // To store the order ID after confirmation
    @State private var estimatedDeliveryDate: String = "" // To show after confirmation
    @State private var navigateToConfirmation = false // To trigger navigation
    @AppStorage("userID") private var userID: String = ""
    
    // Function to calculate total price including delivery cost
    var totalPriceWithDelivery: Int {
        return cartManager.totalPrice() + deliveryCost
    }
    
    // Function to handle the order submission
    func placeOrder() {
        // Validate the order inputs
        guard !cartManager.items.isEmpty else {
            print("Cart is empty")
            return
        }
        if selectedDeliveryMethod != "Pick-up" && deliveryAddress.isEmpty {
            print("Delivery address is required")
            return
        }

        // Prepare order data
        let orderData: [String: Any] = [
            "buyerid": userID,
            "total_price": totalPriceWithDelivery,
            "delivery_method": selectedDeliveryMethod,
            "payment_method": selectedPaymentMethod,
            "delivery_address": selectedDeliveryMethod == "Pick-up" ? "" : deliveryAddress
        ]

        // Make API call to place the order
        OrderAPI.placeOrder(orderData) { order in
            let orderIDFromResponse = order["orderid"] as? Int ?? 0
            let deliveryDate = order["estimated_delivery_date"] as? String ?? "N/A"
            
            // Add order items to the backend
            for item in cartManager.items {
                let orderItemData: [String: Any] = [
                    "orderid": orderIDFromResponse,
                    "productid": item.product.productid,
                    "quantity": item.quantity,
                    "price": item.product.price,
                    "total_price": item.product.price * item.quantity
                    
                ]
                OrderAPI.placeOrderItem(orderItemData)
            }

            // Update state for navigation
            orderID = orderIDFromResponse
            estimatedDeliveryDate = deliveryDate
            cartManager.clearCart()
            navigateToConfirmation = true
        }
    }

    var body: some View {
        VStack {
            Text("Order Summary")
                .font(.title)
                .padding()

            // Cart summary
            List {
                ForEach(cartManager.items) { item in
                    HStack {
                        Text(item.product.name)
                        Spacer()
                        Text("Qty: \(item.quantity)")
                        Text("₸\(item.product.price * item.quantity)")
                    }
                }
            }

            HStack {
                Text("Cart Total: ₸\(cartManager.totalPrice())")
                Spacer()
            }
            .padding()

            // Delivery method selection
            Picker("Select Delivery Method", selection: $selectedDeliveryMethod) {
                Text("Pick-up (Free)").tag("Pick-up")
                Text("Home Delivery ($2)").tag("Home Delivery")
                Text("Third-party Delivery ($3)").tag("Third-party delivery")
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedDeliveryMethod) { method in
                switch method {
                case "Home Delivery":
                    deliveryCost = 2
                case "Third-party delivery":
                    deliveryCost = 3
                default:
                    deliveryCost = 0
                }
            }
            .padding()

            // Delivery address input
            if selectedDeliveryMethod != "Pick-up" {
                TextField("Enter Delivery Address", text: $deliveryAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            // Payment method selection
            Picker("Select Payment Method", selection: $selectedPaymentMethod) {
                Text("Credit Card").tag("Credit Card")
                Text("Cash on Delivery").tag("Cash on Delivery")
                Text("Mobile Payment").tag("Mobile Payment")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Total price including delivery
            HStack {
                Text("Total Price: ₸\(totalPriceWithDelivery)")
                    .font(.headline)
                Spacer()
            }
            .padding()

            // Confirm order button
            Button(action: placeOrder) {
                Text("Confirm Order")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            // Navigation to confirmation view
            NavigationLink(
                destination: OrderConfirmationView(orderID: orderID),
                isActive: $navigateToConfirmation
            ) {
                EmptyView()
            }
        }
        .navigationTitle("Order Placement")
    }
}
