import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
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
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
