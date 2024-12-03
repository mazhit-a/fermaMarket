import Foundation

class OfferAPI {
    static let baseURL = "http://localhost:3000/api/v1" // Replace with your backend URL

    static func submitOffer(_ offerData: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/offers") else {
            print("Invalid URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: offerData, options: .prettyPrinted)
        } catch {
            print("Error encoding offer data: \(error)")
            completion(false)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error submitting offer: \(error)")
                completion(false)
                return
            }

            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Offer response:", jsonResponse)
                        completion(true)
                    } else {
                        print("Invalid response")
                        completion(false)
                    }
                } catch {
                    print("Error parsing offer response: \(error)")
                    completion(false)
                }
            }
        }
        task.resume()
    }
}

