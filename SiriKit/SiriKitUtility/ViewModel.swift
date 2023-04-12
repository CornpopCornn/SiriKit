import Foundation
import Combine

class ViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var inputText: String = ""
    @Published var messages: [Message] = []
    
    struct Message: Identifiable {
        let id = UUID()
        let content: String
        let role: String
    }
    
    func sendMessage() {
        let userMessage = Message(content: inputText, role: "User")
        messages.append(userMessage)
        fetchOpenAIResponse(text: inputText)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching response: \(error.localizedDescription)")
                }
            }, receiveValue: { responseText in
                let cleanedResponse = responseText.replacingOccurrences(of: "Eve: ", with: "")
                if !cleanedResponse.isEmpty {
                    self.messages.append(Message(content: cleanedResponse, role: "AI"))
                }
                self.inputText = ""
            })
            .store(in: &cancellables)
    }
    private func fetchOpenAIResponse(text: String) -> AnyPublisher<String, Error> {
        return Future { promise in
            SiriBotUtility.shared.handleSiriBotRequest(text: text) { responseText in
                promise(.success(responseText))
            }
        }
        .eraseToAnyPublisher()
    }
}
               
