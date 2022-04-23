import Cocoa
import Combine
import SwiftUI

public class Preferences: ObservableObject {
    public static let shared = Preferences()
    static let userDefaults = UserDefaults.standard

    enum PreferencesKeys: String {
        case ShowMenuBarIcon
        case NeedsOnboarding
        case MenuBarIcon
        case OverrideInterval
    }

    public typealias IconPairImage = (on: Image, off: Image)
    public typealias IconPairNSImage = (on: NSImage, off: NSImage)

    public enum MenuBarIcon: String, CaseIterable {
        case Option1
        case Option2
        case Option3
        case Option4

        public func image() -> IconPairImage {
            let iconPair = nsImage()
            return (on: Image(nsImage: iconPair.on), off: Image(nsImage: iconPair.off))
        }

        public func nsImage() -> IconPairNSImage {
            var onImage: NSImage
            var offImage: NSImage
            let imageConfig = NSImage.SymbolConfiguration(pointSize: 50, weight: .heavy, scale: .large)
            switch self {
            case .Option1:
                onImage = NSImage(systemSymbolName: "iphone", accessibilityDescription: nil)!.withSymbolConfiguration(imageConfig)!
                offImage = NSImage(systemSymbolName: "iphone.slash", accessibilityDescription: nil)!.withSymbolConfiguration(imageConfig)!
            case .Option2:
                onImage = NSImage(systemSymbolName: "lock", accessibilityDescription: nil)!.withSymbolConfiguration(imageConfig)!
                offImage = NSImage(systemSymbolName: "lock.slash", accessibilityDescription: nil)!.withSymbolConfiguration(imageConfig)!
            case .Option3:
                onImage = NSImage(systemSymbolName: "plus.circle", accessibilityDescription: nil)!.withSymbolConfiguration(imageConfig)!
                offImage = NSImage(systemSymbolName: "multiply.circle", accessibilityDescription: nil)!.withSymbolConfiguration(imageConfig)!
            case .Option4:
                onImage = NSImage(systemSymbolName: "bolt", accessibilityDescription: nil)!.withSymbolConfiguration(imageConfig)!
                offImage = NSImage(systemSymbolName: "bolt.slash", accessibilityDescription: nil)!.withSymbolConfiguration(imageConfig)!
            }
            onImage.isTemplate = true
            offImage.isTemplate = true
            return (on: onImage, off: offImage)
        }
    }

    @Published public var needsOnboarding: Bool {
        didSet {
            Preferences.setValue(value: needsOnboarding, key: .NeedsOnboarding)
        }
    }

    @Published public var showMenuBarIcon: Bool {
        didSet {
            Preferences.setValue(value: showMenuBarIcon, key: .ShowMenuBarIcon)
        }
    }

    @Published public var menuBarIcon: MenuBarIcon {
        didSet {
            Preferences.setValue(value: menuBarIcon.rawValue, key: .MenuBarIcon)
        }
    }

    @Published public var overrideInterval: TimeInterval {
        didSet {
            Preferences.setValue(value: overrideInterval, key: .OverrideInterval)
        }
    }

    init() {
        needsOnboarding = Preferences.getValue(key: .NeedsOnboarding) as? Bool ?? true
        showMenuBarIcon = Preferences.getValue(key: .ShowMenuBarIcon) as? Bool ?? true
        menuBarIcon = .Option1
        if let mbitem = Preferences.getValue(key: .MenuBarIcon) as? String {
            menuBarIcon = MenuBarIcon(rawValue: mbitem) ?? .Option1
        }
        overrideInterval = 5.0
        if let interval = Preferences.getValue(key: .OverrideInterval) as? TimeInterval {
            overrideInterval = interval
        }
    }

    static func removeAll() {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
        userDefaults.synchronize()
    }

    private static func setValue(value: Any?, key: PreferencesKeys) {
        userDefaults.setValue(value, forKey: key.rawValue)
        userDefaults.synchronize()
    }

    private static func getValue(key: PreferencesKeys) -> Any? {
        userDefaults.value(forKey: key.rawValue)
    }
}
