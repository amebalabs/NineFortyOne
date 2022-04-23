import Cocoa
import Combine

class MenubarItem: NSObject {
    let simctl: Simctl
    let preferences = Preferences.shared
    var statusBarItem: NSStatusItem = {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.sendAction(on: [.leftMouseDown, .rightMouseDown])
        return item
    }()

    let statusBarMenu = NSMenu()
    let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
    let aboutItem = NSMenuItem(title: "About 9:41...", action: #selector(showAbout), keyEquivalent: "")
    var cancellable: AnyCancellable?

    init(_ simctl: Simctl) {
        self.simctl = simctl
        super.init()
        statusBarItem.button?.action = #selector(barItemClicked)
        statusBarItem.button?.target = self
        statusBarItem.button?.imagePosition = .imageLeft
        buildMenu()

        statusBarItem.button?.window?.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
        statusBarItem.button?.window?.registerForDraggedTypes(NSFilePromiseReceiver.readableDraggedTypes.map { NSPasteboard.PasteboardType($0) })

        cancellable = preferences.$menuBarIcon.sink { [weak self] item in
            let iconPair = item.nsImage()
            self?.setMenuBarImage(iconPair: iconPair)
        }
    }

    func setMenuBarImage(iconPair: Preferences.IconPairNSImage? = nil) {
        let iconPair = iconPair ?? preferences.menuBarIcon.nsImage()
        let size: CGFloat = 18
        let nsImage = simctl.isOn ? iconPair.on:iconPair.off
        let image = nsImage.resizedCopy(w: size, h: size)
        image.isTemplate = true
        statusBarItem.button?.image = image
    }
    
    private func buildMenu() {
        [aboutItem, quitItem].forEach { $0.target = self }
        statusBarMenu.addItem(aboutItem)
        if let menu = NSApp.mainMenu?.items.first, let item = menu.submenu?.items.first {
            menu.submenu?.removeItem(item)
            statusBarMenu.addItem(item)
        }
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(quitItem)

        statusBarMenu.delegate = self
    }

    func showMenu() {
        statusBarItem.menu = statusBarMenu
        statusBarItem.button?.performClick(nil)
    }

    @objc func barItemClicked() {
        guard let currentEvent = NSApp.currentEvent else { return }

        if currentEvent.type == .rightMouseDown || currentEvent.modifierFlags.contains(.option) {
            showMenu()
            return
        }
        simctl.toggle()
        setMenuBarImage()
    }

    @objc func showAbout() {
        NSApp.orderFrontStandardAboutPanel()
    }

    @objc func quit() {
        NSApp.terminate(self)
    }

    @objc func showPreferences() {
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: self, from: self)
    }
}

extension MenubarItem: NSMenuDelegate {
    func menuWillOpen(_: NSMenu) {}

    func menuDidClose(_: NSMenu) {
        statusBarItem.menu = nil
    }
}
