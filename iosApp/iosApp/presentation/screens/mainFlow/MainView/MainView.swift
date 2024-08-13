import MPSwiftUI

struct MainView: LocalizedView {
    
    @StateObject var viewModel: MainViewModel = .init()
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 20, pinnedViews: .sectionHeaders) {
                        
                        Section(header: SectionHeaderView("Remote Chat", module: "Shared")) {
                            chatSectionContent
                        }
                        
                        Section(header: SectionHeaderView("Remote version", module: "Shared")) {
                            remoteVersionSectionContent
                        }
                        
                        Divider()
                        
                        Section(header: SectionHeaderView("Local version", module: "Shared")) {
                            localVersionSectionContent
                        }
                        
                        Section(header: SectionHeaderView("Local timer", module: "Shared")) {
                            clockSectionContent(timerIsRunning: viewModel.clockIsRunning)
                        }
                        
                        Section(header: SectionHeaderView("Currency converter", module: "Shared")) {
                            currecnyConverterContent
                        }
                        
                        Section(header: SectionHeaderView("Local VM specific", module: "Platform")) {
                            iosSpecificSectionContent
                        }
                    }.padding()
                }
                .frame(maxHeight: .infinity)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("civita_logo_white")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 20)
                        .colorInvert()
                }
            }
            .handleAlert(item: $viewModel.alert)
        }
    }
    
    var iosSpecificSectionContent: some View {
        Stepper("Count: \(viewModel.counter)", value: $viewModel.counter)
    }
    
    var localVersionSectionContent: some View {
        HStack {
            Image(systemName: "swift")
                .foregroundColor(.accentColor)
            Text(viewModel.appVersion ?? "UNKNOWN")
        }
    }
    
    @ViewBuilder
    var remoteVersionSectionContent: some View {
        VStack {
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
        }
        
    }
    
    var chatSectionContent: some View {
        HStack {
            Text("Name:")
            TextField("Username", text: $viewModel.userName)
            NavigationLink("Open", value: Destination.chat(userName: viewModel.userName))
        }
        .textFieldStyle(.roundedBorder)
    }
    
    var currecnyConverterContent: some View {
        VStack {
            HStack {
                Text("Local: ")
                TextField("value", text: $viewModel.localCurrencyVal)
                Button("Convert") {
                    convertCurrency()
                }
            }
            HStack {
                Text("Converted value: \(viewModel.convertedCurrencyVal)")
                Spacer()
            }
        }
        .textFieldStyle(.roundedBorder)
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

    func toggleTimer() {
        viewModel.toggleTimer()
    }
    
    func convertCurrency() {
        viewModel.convertCurrency()
    }
}

extension MainView {
    
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

#Preview {
//    MainNavigation {
        MainView()
//    }
}
