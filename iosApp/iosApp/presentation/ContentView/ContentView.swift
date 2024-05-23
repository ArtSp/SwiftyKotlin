import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    
    func toggleTimer() {
        viewModel.toggleTimer()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 20, pinnedViews: .sectionHeaders) {
                        
                        Section(header: SectionHeaderView("Platform specific", module: "Platform")) {
                            iosSpecificSectionContent
                        }
                        
                        Section(header: SectionHeaderView("Timer", module: "Shared")) {
                            clockSectionContent(timerIsRunning: viewModel.clockIsRunning)
                        }
                        
                        Section(header: SectionHeaderView("AppVersion", module: "Shared")) {
                            localVersionSectionContent
                        }
                        
                        Section(header: SectionHeaderView("Backend", module: "Shared")) {
                            remoteVersionSectionContent
                        }
                    }.padding()
                }
                .frame(maxHeight: .infinity)
                
                Toggle("Use mock", isOn: $viewModel.useFake)
                    .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("civita_logo_white")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                        .colorInvert()
                }
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
        }
    }
    
    var iosSpecificSectionContent: some View {
        Stepper("Count: \(viewModel.counter)", value: $viewModel.counter)
    }
    
    var localVersionSectionContent: some View {
        VStack {
            Image(systemName: "swift")
                .foregroundColor(.accentColor)
            Text(viewModel.appVersion ?? "UNKNOWN")
        }
    }
    
    @ViewBuilder
    var remoteVersionSectionContent: some View {
        VStack(alignment: .leading) {
            if let serverDate = viewModel.serverDate {
                HStack {
                    Text("Server time: ")
                    Text(serverDate.date.swiftDate.formatted(date: .omitted, time: .complete))
                    if let source = serverDate.source {
                        Text(source)
                            .foregroundStyle(.gray)
                    }
                }
            }
            
            if let beVersion = viewModel.beVersion {
                HStack {
                    Text("Server version: ")
                    Text(beVersion)
                }
            } else {
                if viewModel.isLoadingRemoteVersion {
                    ProgressView()
                } else {
                    Button("Load BE version") { viewModel.loadRemoteVersion() }
                }
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    func clockSectionContent(timerIsRunning: Bool) -> some View {
        VStack {
            Text(viewModel.clock ?? "Timer stopped")
                .foregroundStyle(viewModel.clockIsRunning ? Color.black : .red)
            
            Button(viewModel.clockIsRunning ? "Stop" : "Start") {
                toggleTimer()
            }
        }
        .frame(minWidth: 120)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8.0)
    }
}

extension ContentView {
    
    struct SectionHeaderView: View {
        let title: LocalizedStringKey
        let module: LocalizedStringKey
        
        init(_ title: LocalizedStringKey, module: LocalizedStringKey) {
            self.title = title
            self.module = module
        }
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(module)
                    .font(.subheadline)
            }
            .background(Color.primary
                            .colorInvert()
                            .opacity(0.95))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
