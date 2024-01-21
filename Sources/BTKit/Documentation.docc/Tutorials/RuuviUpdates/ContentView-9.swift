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
