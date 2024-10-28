import Foundation

extension String {
    var hex: Data? {
        var value = self
        var data = Data()

        while value.count > 0 {
            let subIndex = value.index(value.startIndex, offsetBy: 2)
            let c = String(value[..<subIndex])
            value = String(value[subIndex...])

            var char: UInt8
            var int: UInt64 = 0
            Scanner(string: c).scanHexInt64(&int)
            char = UInt8(int)
            data.append(&char, count: 1)
        }

        return data
    }
}
