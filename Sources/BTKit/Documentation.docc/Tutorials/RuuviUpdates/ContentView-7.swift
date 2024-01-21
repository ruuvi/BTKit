import BTKit
import SwiftUI

struct ContentView: View {
    @State var content: Set<RuuviTag> = []

    var body: some View {
        VStack {
            List(content.sorted(by: >)) { ruuviTag in
                Text(ruuviTag.mac ?? ruuviTag.uuid)
                    .font(.title2)
                    .bold()

                if let temperature = ruuviTag.celsius {
                    HStack {
                        Image(systemName: "thermometer")
                        Text("\(temperature, specifier: "%.1f")°C")
                    }
                }
                if let humidity = ruuviTag.relativeHumidity {
                    HStack {
                        Image(systemName: "humidity")
                        Text("\(humidity, specifier: "%.1f")%")
                    }
                }
                if let pressure = ruuviTag.hectopascals {
                    HStack {
                        Image(systemName: "barometer")
                        Text("\(pressure, specifier: "%.1f") hPa")
                    }
                }
            }
        }
        .onReceive(BTForeground.publisher.ruuviTag) {
            content.update(with: $0)
        }
    }
}

extension RuuviTag: Identifiable {
    public var id: String { uuid }
}

extension RuuviTag: Comparable {
    public static func < (lhs: RuuviTag, rhs: RuuviTag) -> Bool {
        lhs.rssi ?? 0 < rhs.rssi ?? 0
    }
}

@Observable class ViewModel: Identifiable {
    var id: String
    var mac: String?
    var celsius: Double?
    var hectopascals: Double?
    var relativeHumidity: Double?
    var dateTime: Date

    init(ruuviTag: RuuviTag) {
        self.id = ruuviTag.id
        self.mac = ruuviTag.mac
        self.celsius = ruuviTag.celsius
        self.hectopascals = ruuviTag.hectopascals
        self.relativeHumidity = ruuviTag.relativeHumidity
        self.dateTime = Date()
    }
}
