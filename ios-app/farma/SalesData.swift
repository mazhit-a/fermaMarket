import Foundation


// Define SalesData struct to represent each sales entry
struct SalesData: Identifiable, Decodable {  // Conform to Decodable
    let id = UUID() // Automatically generate a unique ID for each entry
    let date: Date
    let total_price: String // Use total_price for revenue as it's more appropriate
    
    // Implement coding keys if the property names don't match the JSON keys
    enum CodingKeys: String, CodingKey {
        case date
        case total_price
    }
}

