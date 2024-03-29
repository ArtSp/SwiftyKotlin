import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            
            VStack(spacing: 20) {
                
                if let appVersion = viewModel.appVersion {
                    VStack {
                        Image(systemName: "swift")
                            .foregroundColor(.accentColor)
                        Text(appVersion)
                    }
                }
                
                if let beVersion = viewModel.beVersion {
                    VStack {
                        Image(systemName: "server.rack")
                            .foregroundColor(.accentColor)
                        Text(beVersion)
                    }
                } else {
                    Button("Load BE version") { viewModel.loadBEVersion() }
                }
            }
            .frame(maxHeight: .infinity)
            
            Toggle("Use mock", isOn: $viewModel.useFake)
            
        }
        .alert(
            isPresented: .init(
                get: { viewModel.error != nil },
                set: { _ in viewModel.error = nil }
            )
        ) {
            Alert(
                title: Text(viewModel.error?.title ?? ""),
                message: Text(viewModel.error?.message ?? "")
            )
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
