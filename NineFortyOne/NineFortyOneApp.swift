import SwiftUI

@main
struct NineFortyOneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            PreferencesView().environmentObject(Preferences.shared)
        }
    }
}
