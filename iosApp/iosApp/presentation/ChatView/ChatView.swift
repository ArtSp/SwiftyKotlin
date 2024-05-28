import SwiftUI
import Shared

struct ChatView: View {
    
    @StateObject var viewModel: ChatViewModel
    
    var body: some View {
        VStack {
            if let serverDate = viewModel.serverDate {
                HStack {
                    let source = serverDate.source ?? "NA"
                    Text("Server time (\(source))")
                    Text(serverDate.date.swiftDate.formatted(date: .omitted, time: .complete))
                        .foregroundStyle(Color.black)
                }
                .font(.footnote)
                .foregroundStyle(.gray)
            }
            
            chatContentView
        }
        .navigationTitle("Chat")
        .overlay {
            VStack {
                Spacer()
                HStack {
                    TextField("Message", text: $viewModel.message)
                    
                    Button(action: {
                        viewModel.sendMessage()
                    }, label: {
                        Image(systemName: "paperplane.circle.fill")
                            .font(.largeTitle)
                    })
                    .disabled(viewModel.sendDisabled)
                }
                .padding()
            }
        }
    }
    
    var chatContentView: some View {
        ScrollView(.vertical) {
            VStack {
                VStack {
                    Text("Messages: \(viewModel.messages.count)")
                    ForEach(viewModel.messages, id: \.self) { message in
                        
                        Text(message.text)
                            .foregroundStyle(Color.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(message.bgColor)
                            )
                            .frame(maxWidth: .infinity, alignment: message.isLocal ? .trailing : .leading)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private extension ChatMessage {
    var bgColor: Color {
        switch theme {
        case .green: return .green
        default: return .blue
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static let vm = ChatViewModel(chatUseCase: ChatUseCase(client: FakeRemoteClient()))
    
    static var previews: some View {
        ChatView(viewModel: vm)
    }
}
