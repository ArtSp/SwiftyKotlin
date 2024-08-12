
import MPSwiftUI

struct UpdateView: LocalizedView {
    
    @StateObject var viewModel: UpdateViewModel = .init()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text(localizedKey("Update required"))
            
            Spacer()
            
            Button(localizedKey("update")) {
                viewModel.update()
            }
        }
        .padding()
    }
}

#Preview {
    CommonNavigation {
        UpdateView()
    }
    
}

