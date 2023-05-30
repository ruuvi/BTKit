import Foundation
import CoreBluetooth

public class DeviceInformationService: BTService {
    public let uuid = CBUUID(string: "180a")
    public let serialRevision = CBUUID(string: "2a25")
    public let firmwareRevision = CBUUID(string: "2a26")

    public init() {
    }
}
