import Foundation
import LaunchAtLogin
import KeyboardShortcuts
import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var preferences: Preferences

    private enum Tabs: Hashable {
        case general
    }

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
        }.padding(20)
    }
}

struct GeneralSettingsView: View {
    @EnvironmentObject var preferences: Preferences
    @ObservedObject private var launchAtLogin = LaunchAtLogin.observable

    let width: CGFloat = 90
    var body: some View {
        Form {
            ToggleView(label: "Startup", secondLabel: "Start at Login",
                       state: $launchAtLogin.isEnabled,
                       width: width)
            ToggleView(label: "Menu Bar", secondLabel: "Show Icon",
                       state: $preferences.showMenuBarIcon,
                       width: width)
            if preferences.showMenuBarIcon {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(NSColor.controlBackgroundColor))
                    HStack {
                        ForEach(Preferences.MenuBarIcon.allCases, id: \.self) { item in
                            MenuBarIconView(item: item, selected: $preferences.menuBarIcon).onTapGesture {
                                preferences.menuBarIcon = item
                            }
                        }
                    }
                }.frame(height: 70)
                    .padding([.leading, .trailing], 10)
            }
            HStack {
                Text("  ")
                Text("Turn On\\Off:")
                Spacer()
                KeyboardShortcuts.Recorder(for: .toggle)
            }.frame(width:250)
        }
        .padding(20)
        .frame(width: 410, height: preferences.showMenuBarIcon ? 140 : 80)
    }
}

struct MenuBarIconView: View {
    let item: Preferences.MenuBarIcon
    @Binding var selected: Preferences.MenuBarIcon
    var isSelected: Bool {
        selected == item
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
            VStack(spacing: 2) {
                HStack {
                    item.image().on
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30, alignment: .center)
                    item.image().off
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30, alignment: .center)
                }
                .padding(3)
                .accentColor(isSelected ? .blue : .white)
                .border(isSelected ? Color.blue : Color.clear, width: 2)
                Circle()
                    .fill(isSelected ? Color.blue : Color.gray)
                    .frame(width: 8, height: 8)
                    .padding([.top], 5)
            }
        }
    }
}

struct ToggleView: View {
    let label: String
    let secondLabel: String
    @Binding var state: Bool
    let width: CGFloat

    var mainLabel: String {
        guard !label.isEmpty else { return "" }
        return "\(label):"
    }

    var body: some View {
        HStack {
            HStack {
                Spacer()
                Text(mainLabel)
            }.frame(width: width)
            Toggle("", isOn: $state)
            Text(secondLabel)
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView().environmentObject(Preferences.shared)
    }
}
