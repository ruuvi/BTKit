import CoreBluetooth

class RuuviBTBackgroundService: BTService {
    public let uuid = CBUUID(string: "FC98")

    public init() {}
}
