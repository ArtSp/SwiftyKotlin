
import MPSwiftUI

extension EnvironmentValues {
    var formFocus: FormFocus? {
        get { self[FormFocusKey.self] }
        set { self[FormFocusKey.self] = newValue }
    }
}

private struct FormFocusKey: EnvironmentKey {
    static let defaultValue: FormFocus? = .firstEmpty
}

extension View {
    func formFocus(
        _ formFocus: FormFocus
    ) -> some View {
        self.environment(\.formFocus, formFocus)
    }
}

// MARK: - FormView

typealias IsFocused = Bool

struct FormView<Key: FormKey, V: View>: View {
    
    @FocusState private var focusedField: Key?
    @Environment(\.formFocus) private var formFocus
    @Binding var form: Form<Key>
    let view: (Key) -> V
    let verifyInput: ((IsFocused, Key) -> Void)?
    
    init(
        form: Binding<Form<Key>>,
        @ViewBuilder view: @escaping (Key) -> V,
        verifyInput: ((IsFocused, Key) -> Void)?
    ) {
        _form = form
        self.view = view
        self.verifyInput = verifyInput
    }
    
    var body: some View {
        VStack(spacing: 24) {
            ForEach(form.layout, id: \.self) { row in
                VStack(alignment: .leading) {
                    if let title = row.title {
                        Text(title)
                            .font(.caption)
                            .foregroundStyle(.gray)
                        
                        HStack {
                            ForEach(row.keys, id: \.self) { key in
                                view(key)
                                    .onChange(of: focusedField) { _, _ in
                                        verifyInput?(focusedField == key, key)
                                    }
                                    .onChange(of: form[key].text) { _, _ in
                                        verifyInput?(focusedField == key, key)
                                    }
                                    .onSubmit {
                                        focusToNextField(after: key)
                                        verifyInput?(focusedField == key, key)
                                    }
                                    .focused($focusedField, equals: key)
                            }
                        }
                        
                        let errors = Array(form.errors(for: row.keys).enumerated())
                        ForEach(errors, id: \.offset) { offset, error in
                            if let error {
                                Text(error.localizedDescription)
                                    .font(.caption)
                                    .foregroundStyle(Color.red)
//                                    .isHidden(focusedField == row.keys[offset])
                            }
                           
                        }
                    }
                    
                }
            }
        }
        .onAppear {
            switch formFocus {
            case .none: break
            case .firstEmpty:
                if let fieldToFocus = form.keys.first(where: { form[$0].text.isEmpty }) {
                    focusedField = fieldToFocus
                }
            }
        }
    }
    
    private func focusToNextField(after key: Key) {
        if let idx = form.keys.firstIndex(of: key) {
            let nextFields = form.keys[idx.advanced(by: 1)...]
            focusedField = nextFields.first(where: { key in
                form[key].text.isEmpty
            })
        }
        
    }
}

// MARK: - FormField

struct FormField: View {
    
    let titleKey: LocalizedStringKey
    @Binding var field: Field
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(titleKey, text: $field.text)
            } else {
                TextField(titleKey, text: $field.text)
            }
        }
            .overlay {
                HStack {
                    Spacer()
                    Button(action: { field.text.removeAll() }) {
                        Image("close")
                    }
                    .buttonStyle(.plain)
                    .isHidden(field.text.isEmpty)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 13)
            .overlay {
                Self.shape
                    .stroke(lineWidth: 1)
                    .foregroundStyle(field.error == nil ? .gray : .red)
            }
    }
    
    fileprivate static var shape: some Shape {
        RoundedRectangle(cornerRadius: 4)
    }
}

// MARK: - Preview

struct Form_Previews: PreviewProvider {
    
    enum Key: String, FormKey {
        case title
        case subtitle
        case text
    }
    
    struct PreviewBody: View {
        @State private var form = Form<Key>(
            [
                FormRow(title: "Row 1", keys: [.title, .subtitle]),
                FormRow(title: "Row 2", key: .text)
            ]
        )
        
        var body: some View {
            VStack {
                FormView(form: $form) { key in
                    switch key {
                    default:
                        FormField(
                            titleKey: key.rawValue.localizedStringKey,
                            field: $form[key]
                        )
                    }
                } verifyInput: { isFocused, key in
                    let text = form[key].text
                    
                    if !text.isEmpty {
                        form[key].error = nil
                    } else if !isFocused {
                        form[key].error = nil
                    }
                    
                }
                .padding()
                
                Spacer()
                
                Button("Next") { }
                .buttonStyle(.simpleButton(theme: .primary, fillWidth: true))
                .padding()
                .disabled(!form.isReadyToSubmit)
            }
            
        }
    }
    
    static var previews: some View {
        PreviewBody()
    }
}
