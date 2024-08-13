
import MPSwiftUI

struct Field {
    var text: String = ""
    var error: Error?
}

enum FormFocus {
    case firstEmpty
}

struct Form<Key: FormKey> {
    var fields: [Key: Field]!
    let layout: [FormRow<Key>]
    var keys: [Key] { layout.flatMap { $0.keys } }
    
    init(_ layout: [FormRow<Key>]) {
        self.layout = layout
        fields = Dictionary(uniqueKeysWithValues: keys.map { ($0, Field()) })
    }
    
    subscript(key: Key) -> Field {
        get { fields[key]! }
        set(newValue) { fields[key] = newValue }
    }
    
    var isReadyToSubmit: Bool {
        errors(for: keys).allSatisfy { $0.isNil }
        &&
        fields.keys
            .filter { $0.isRequired }
            .allSatisfy { !self[$0].text.isEmpty }
    }
    
    func errors(for keys: [Key]) -> [Error?] {
        keys.map { self[$0].error }
    }
}

struct FormRow<Key: FormKey>: Hashable {
    let title: LocalizedStringKey?
    let keys: [Key]
    
    init(title: LocalizedStringKey?, keys: [Key]) {
        self.title = title
        self.keys = keys
    }
    
    init(title: LocalizedStringKey?, key: Key) {
        self.title = title
        self.keys = [key]
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(keys.hashValue)
    }
}

protocol FormKey: RawRepresentable, Hashable {
    var isRequired: Bool { get }
}

extension FormKey {
    var isRequired: Bool { true }
}

protocol FormValidator {
    associatedtype Key: FormKey
    var form: Form<Key> { get set }
    func validate(key: Key, isFocused: Bool)
}
