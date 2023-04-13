import Foundation

class SiriBotUtility {
    static let shared = SiriBotUtility()
    
    private init() {}
    
    func handleSiriBotRequest(messages: [[String: String]], completion: @escaping (String) -> Void) {
        // צריך להחליף את YOUR_API_KEY עם המפתח האמיתי שלך מ-OpenAI
        let apiKey = "OPENAI_API_KEY"
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo", // שם המודל
            "messages": messages, // שליחת ההיסטוריה המלאה של השיחה
            "temperature": 0.7,
            "max_tokens": 750
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error during API call: \(error.localizedDescription)")
                completion("שגיאה בחיבור לשרת")
                return
            }
            if let data = data {
                // הוספת הדפסה של התגובה המלאה מהשרת
                let responseString = String(data: data, encoding: .utf8)
                print("Response from server: \(responseString ?? "")")
                
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                } else {
                    completion("שגיאה בקבלת תשובה")
                }
            } else {
                completion("שגיאה בקבלת תשובה")
            }
        }.resume()
    }
}

