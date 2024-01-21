import SwiftUI

struct RuuviTagView: View {
    @Bindable var ruuviTag: ViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(ruuviTag.mac ?? ruuviTag.id)
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
}
