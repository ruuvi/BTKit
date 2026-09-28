import XCTest
@testable import BTKit

final class BTKitTests: XCTestCase {
    func testGasIndicesOutsideOneToFiveHundredAreUnavailable() {
        assertGasIndices(vocOffset: 13, noxOffset: 14, flagsOffset: 18) {
            let decoded = $0.ruuvi6()
            return (decoded.voc, decoded.nox)
        }
        assertGasIndices(vocOffset: 19, noxOffset: 20, flagsOffset: 30) {
            let decoded = $0.ruuviE1()
            return (decoded.voc, decoded.nox)
        }
        assertGasIndices(vocOffset: 17, noxOffset: 18, flagsOffset: 28) {
            let decoded = $0.ruuviHeartbeatE1()
            return (decoded.voc, decoded.nox)
        }
        assertGasIndices(vocOffset: 21, noxOffset: 22, flagsOffset: 30) {
            let decoded = $0.ruuviLogE1()
            return (decoded?.voc, decoded?.nox)
        }
    }

    private func assertGasIndices(
        vocOffset: Int,
        noxOffset: Int,
        flagsOffset: Int,
        decode: (Data) -> (Double?, Double?)
    ) {
        var bytes = [UInt8](repeating: 0, count: 42)
        let zero = decode(Data(bytes))
        XCTAssertNil(zero.0)
        XCTAssertNil(zero.1)

        bytes[flagsOffset] = 0xC0
        let minimum = decode(Data(bytes))
        XCTAssertEqual(minimum.0, 1)
        XCTAssertEqual(minimum.1, 1)

        bytes[flagsOffset] = 0
        bytes[vocOffset] = 250
        bytes[noxOffset] = 250
        let maximum = decode(Data(bytes))
        XCTAssertEqual(maximum.0, 500)
        XCTAssertEqual(maximum.1, 500)

        bytes[flagsOffset] = 0xC0
        let aboveMaximum = decode(Data(bytes))
        XCTAssertNil(aboveMaximum.0)
        XCTAssertNil(aboveMaximum.1)

        bytes[vocOffset] = 0xFF
        bytes[noxOffset] = 0xFF
        let unavailable = decode(Data(bytes))
        XCTAssertNil(unavailable.0)
        XCTAssertNil(unavailable.1)
    }
}
