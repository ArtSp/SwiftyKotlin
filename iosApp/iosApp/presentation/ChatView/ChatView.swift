import SwiftUI
import Shared

struct ChatView: View {
    
    @StateObject var viewModel: ChatViewModel
    
    var body: some View {
        VStack {
            if let serverDate = viewModel.serverDate {
                VStack {
                    Text("Server time")
                        .font(.title)
                    HStack {
                        Text(serverDate.date.swiftDate.formatted(date: .omitted, time: .complete))
                        if let source = serverDate.source {
                            Text(source)
                                .foregroundStyle(.gray)
                        }
                    }
                    Text("(Updates via network socket every N seconds)")
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                }
            }
            
            chatContentView
        }
        .navigationTitle("Chat")
    }
    
    // TODO: Make content view for chat messages
    var chatContentView: some View {
        Spacer()
    }
}

struct ChatView_Previews: PreviewProvider {
    static let vm = ChatViewModel(chatUseCase: ChatUseCase(client: FakeRemoteClient()))
    
    static var previews: some View {
        ChatView(viewModel: vm)
    }
}
