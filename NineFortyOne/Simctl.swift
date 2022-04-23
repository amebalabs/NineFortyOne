import Foundation
import ShellOut
import Combine

class Simctl {
    public static let shared = Simctl()
    var isOn: Bool = true
    var timer: Timer?
    var cancellable: AnyCancellable?
    let preferences = Preferences.shared
    
    init() {
        cancellable = preferences.$overrideInterval.sink { [weak self] interval in
            self?.continiousOverride(interval: interval)
        }
    }
    
    func toggle() {
        isOn.toggle()
        isOn ? continiousOverride(interval: preferences.overrideInterval):reset()
    }

    func override() {
        Task {
            listSimulators().filter{$0.isAvailable}.forEach{overrideStatusBar(id: $0.udid)}
        }
    }
    
    func continiousOverride(interval: TimeInterval) {
        override()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 45.0, repeats: true) { timer in
            self.override()
        }
    }
    
    func reset() {
        timer?.invalidate()
        Task {
            listSimulators().filter{$0.isAvailable}.forEach{clearSimulatorStatusBar(id: $0.udid)}
        }
    }
    
    private func overrideStatusBar(id: UUID) {
        _ = try? shellOut(to: "xcrun simctl status_bar \(id.uuidString) override --time 9:41 --dataNetwork wifi --wifiMode active --wifiBars 3 --cellularBars 4 --operatorName '' --batteryState charged")
    }
    
    private func clearSimulatorStatusBar(id: UUID) {
        _ = try? shellOut(to: "xcrun simctl status_bar \(id.uuidString) clear")
    }
    
    private func listSimulators() -> [Simulator] {
        do {
            let devicesJSONString = try shellOut(to: "xcrun simctl list -j -v devices")
            guard let devicesData: Data = devicesJSONString.data(using: .utf8) else {
                throw Errors.listSimulatorsError
            }
            let decoder = JSONDecoder()
            let listing = try decoder.decode(SimulatorList.self, from: devicesData)
            return listing.devices
        } catch {
            return []
        }
    }
}

public enum Errors: Swift.Error {
    case listSimulatorsError
}

public struct Simulator: Decodable {
    public let udid: UUID
    public let name: String
    public let isAvailable: Bool
    public let deviceTypeIdentifier: String
    public let state: State
    public let logPath: URL
    public let dataPath: URL
    
    public enum State: String, Decodable {
        case shutdown = "Shutdown"
        case booted = "Booted"
    }
}
extension Simulator {
    public var deviceId: String {
        udid.uuidString
    }
}


public struct SimulatorList: Decodable {
    public enum Keys: String, CodingKey {
        case devices
    }
    
    public let devices: [Simulator]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let dict = try container.decode([String: [Simulator]].self, forKey: .devices)
        self.devices = dict.values.flatMap { $0 }
    }
}
