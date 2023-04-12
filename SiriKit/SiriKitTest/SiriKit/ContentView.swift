import SwiftUI
import Combine
import UIKit

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
    }
}

struct OpenAIChatView: View {
    @ObservedObject var viewModel = ViewModel()
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.messages) { message in
                        Text("\(message.role): \(message.content)")
                    }
                }
                .padding()
            }
            
            TextField("Enter your text", text: $viewModel.inputText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .frame(height: 40) // Adjust height as needed
            
            Button(action: {
                self.viewModel.sendMessage()
            }) {
                Text("Send")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.bottom)
        }
        .padding()
    }
}
    
    private func processText() {
        let userMessage: [String: String] = ["role": "user", "content": inputText]
        let systemMessage: [String: String] = ["role": "system", "content": "You are talking to an AI language model."]
        let conversation = [systemMessage, userMessage] // Define the conversation messages
        fetchOpenAIResponse(messages: conversation) { responseText in
            let cleanedResponse = responseText.replacingOccurrences(of: "Eve: ", with: "")
            if !cleanedResponse.isEmpty {
                let systemMessage = Message(content: cleanedResponse, role: "Eve")
                self.messages.append(systemMessage)
            }
        }
    }
    
    private func fetchOpenAIResponse(messages: [[String: String]], completion: @escaping (String) -> Void) {
        print("Making API call with messages: (messages)")
        let apiKey = "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"
        let url = URL(string: "https://api.openai.com/v1/engines/gpt-3.5-turbo/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer (apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody: [String: Any] = [
            "messages": messages,
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
                        print("Raw JSON response: \(jsonResponse)") // Output raw JSON response
                        if let choices = jsonResponse["choices"] as? [[String: Any]],
                           let firstChoice = choices.first,
                           let message = firstChoice["message"] as? [String: Any],
                           let content = message["content"] as? String {
                            DispatchQueue.main.async {
                                print("Received response from API: \(content)")
                                completion(content)
                            }
                        } else {
                            print("Failed to parse response JSON")
                        }
                    } else {
                        print("Failed to parse response JSON")
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            } else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }

