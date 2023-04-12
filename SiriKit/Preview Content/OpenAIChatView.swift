import SwiftUI
import XCTest

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
                .autocapitalization(TextAutocapitalization.none)
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
