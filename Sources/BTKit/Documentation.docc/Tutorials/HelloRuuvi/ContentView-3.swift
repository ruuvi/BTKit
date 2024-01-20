import BTKit
import SwiftUI

struct ContentView: View {
    @State var content: Set<RuuviTag> = []

    var body: some View {
        VStack {
        }
        .onReceive(BTForeground.publisher.ruuviTag) {
            content.update(with: $0)
        }
    }
}
