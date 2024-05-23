import SwiftUI

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
            
            Spacer()
        }
        .navigationTitle("Chat")
    }
}
