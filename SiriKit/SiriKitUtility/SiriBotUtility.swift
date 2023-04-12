import Foundation

class SiriBotUtility {
    static let shared = SiriBotUtility()
    
    private init() {}
    
    func handleSiriBotRequest(text: String, completion: @escaping (String) -> Void) {
        let apiKey = "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"
        let url = URL(string: "https://api.openai.com/v1/engines/gpt-3.5-turbo/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "messages": [["content": text]],
            "temperature": 0.7
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error during API call: \(error.localizedDescription)")
                return
            }
            if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let choices = jsonResponse["choices"] as? [[String: Any]],
                           let firstChoice = choices.first,
                           let message = firstChoice["message"] as? [String: Any],
                           let content = message["content"] as? String {
                            DispatchQueue.main.async {
                                completion(content)
                            }
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
        }.resume()
    }
}

