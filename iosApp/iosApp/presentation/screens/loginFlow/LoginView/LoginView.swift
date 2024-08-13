
import MPSwiftUI

struct LoginView: LocalizedView {
    
    @StateObject var viewModel: LoginViewModel = .init()
    @Environment(\.navigationRouter) private var router
    @State private var form = Form<Key>(
        [
            FormRow(title: localizedKey("loginRow"), key: .user),
            FormRow(title: localizedKey("passwordRow"), key: .password)
        ]
    )
    
    var body: some View {
        VStack {
            FormView(form: $form) { key in
                FormField(
                    titleKey: localizedKey(key.rawValue),
                    field: $form[key],
                    isSecure: key == .password
                )
            } verifyInput: { isFocused, key in
                Validator(form: $form).validate(key: key, isFocused: isFocused)
            }
            .padding()
            
            Button(localizedKey("login")) {
                viewModel.login(
                    username: form[.user].text,
                    password: form[.user].text
                )
            }
            .disabled(!form.isReadyToSubmit || viewModel.isLoading.contains(.login))
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("civita_logo_white")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 25)
                    .colorInvert()
            }
        }
        .buttonStyle(.simpleButton)
        .padding()
        .handleAlert(item: $viewModel.alert)
        .onReceive(viewModel.navigation) { router?.path.append($0) }
    }
    
}

extension LoginView {
    
    enum Key: String, FormKey {
        case user
        case password
    }
    
    struct Validator: FormValidator {
        @Binding var form: Form<Key>
        @Environment(\.locale) var locale
        
        func validate(key: Key, isFocused: Bool) {
            let text = form[key].text
            
            if !text.isEmpty {
                switch key {
                case .user:
                    if text.count > 5 {
                        form[key].error = nil
                    } else {
                        form[key].error = LoginView.localized("error_min5", locale: locale)
                    }
                case .password:
                    if text.count > 5 {
                        if text.containsDigit && text.containsSymbol {
                            form[key].error = nil
                        } else {
                            form[key].error = LoginView.localized("error_symbolsAndDigits", locale: locale)
                        }
                    } else {
                        form[key].error = LoginView.localized("error_min5", locale: locale)
                    }
                }
                
            }
            
        }
    }
}

#Preview {
    LoginNavigation {
        LoginView()
    }
}
