import AppKit
import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggle = Self("toggleShortcut")
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarItem: MenubarItem?
    var simctl = Simctl.shared
    var preferences = Preferences.shared

    func applicationDidFinishLaunching(_: Notification) {
        menuBarItem = MenubarItem(simctl)
        simctl.continiousOverride(interval: preferences.overrideInterval)

        KeyboardShortcuts.onKeyUp(for: .toggle) { [self] in
            simctl.toggle()
            menuBarItem?.setMenuBarImage()
        }
    }
}
