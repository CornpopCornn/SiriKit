import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State private var textInput: String = ""
    
    var body: some View {
        VStack(alignment: .trailing) {
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    LazyVStack(alignment: .trailing, spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            Text("\(message.content)")
                                .padding()
                                .background(message.role == "user" ? Color.green : Color.gray)
                                .cornerRadius(10)
                                .id(message.id)
                        }
                    }
                    .onAppear {
                        scrollViewProxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                    .onChange(of: viewModel.messages) { _ in
                        scrollViewProxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            HStack {
                TextField("הקלד הודעה...", text: $textInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    viewModel.sendMessage(textInput)
                    textInput = ""
                }) {
                    Image(systemName: "paperplane.fill")
                }
            }
            .padding()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
