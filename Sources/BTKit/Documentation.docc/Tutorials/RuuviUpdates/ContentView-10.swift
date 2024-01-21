import BTKit
import SwiftUI

struct ContentView: View {
    @State var content = Storage()

    var body: some View {
        VStack {
            List(content.ruuviTags) { ruuviTag in
                RuuviTagView(ruuviTag: ruuviTag)
            }
        }
        .onReceive(BTForeground.publisher.ruuviTag) {
            content.update(with: $0)
        }
    }
}
