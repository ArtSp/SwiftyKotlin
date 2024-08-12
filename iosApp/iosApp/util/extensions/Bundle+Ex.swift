
import UIKit

private var bundleKey: UInt8 = 0

final class BundleExtension: Bundle {
    
    override func localizedString(
        forKey key: String,
        value: String?,
        table tableName: String?
    ) -> String {
        guard let string = (objc_getAssociatedObject(self, &bundleKey) as? Bundle)?.localizedString(forKey: key, value: value, table: tableName) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return string
    }
}

extension Bundle {
    
    static let once: Void = { object_setClass(Bundle.main, type(of: BundleExtension())) }()
    
    static var language: Language? {
        guard let languages = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String] else { return nil }
        let lang = languages.compactMap { lang in Language.companion.instance(name: lang) }.first
        return lang
    }
    
    static func setLanguage(_ language: Language) {
        Bundle.once
        
        UIView.appearance().semanticContentAttribute = language.isRTL ? .forceRightToLeft : .forceLeftToRight
        
        UserDefaults.standard.set(language.isRTL, forKey: "AppleTextDirection")
        UserDefaults.standard.set(language.isRTL, forKey: "NSForceRightToLeftWritingDirection")
        UserDefaults.standard.set([language.code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        guard let path = Bundle.main.path(forResource: language.code, ofType: "lproj") else {
            print("Failed to get a bundle path.")
            return
        }
        
        objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle(path: path), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
