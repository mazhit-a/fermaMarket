import Foundation

class OrderAPI {
    
    // API URL for the backend
    static let baseURL = "http://localhost:3000/api/v1" // Change this to your actual backend URL

    // Function to place an order
    static func placeOrder(_ orderData: [String: Any], completion: @escaping ([String: Any]) -> Void) {
        guard let url = URL(string: "\(baseURL)/orders") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Convert the order data into JSON
            request.httpBody = try JSONSerialization.data(withJSONObject: orderData, options: .prettyPrinted)
        } catch {
            print("Error encoding order data: \(error)")
            return
        }
        
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error placing order: \(error)")
                return
            }
            
            if let data = data {
                do {
                    // Parse the response data
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        completion(jsonResponse) // Return the order data
                    } else {
                        print("Invalid response")
                    }
                } catch {
                    print("Error parsing order response: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    // Function to add order items to the order
    static func placeOrderItem(_ orderItemData: [String: Any]) {
        guard let url = URL(string: "\(baseURL)/orders/order-items") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Convert the order item data into JSON
            request.httpBody = try JSONSerialization.data(withJSONObject: orderItemData, options: .prettyPrinted)
        } catch {
            print("Error encoding order item data: \(error)")
            return
        }
        
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error adding order item: \(error)")
                return
            }
            
            if let data = data {
                do {
                    // Optionally, you can handle the response if needed
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Order item added successfully: \(jsonResponse)")
                    }
                } catch {
                    print("Error parsing order item response: \(error)")
                }
            }
        }
        
        task.resume()
    }
}
