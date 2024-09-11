import CoreBluetooth

class RuuviBTService: BTService {
    var uuid: CBUUID

    init(uuid: CBUUID) {
        self.uuid = uuid
    }
}
