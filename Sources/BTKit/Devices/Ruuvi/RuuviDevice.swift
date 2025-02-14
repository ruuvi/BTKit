import Foundation

public enum RuuviDevice {
    case tag(RuuviTag)
}

public extension RuuviDevice {
    var tag: RuuviTag? {
        if case let .tag(tag) = self {
            return tag
        } else {
            return nil
        }
    }
}

public enum RuuviTag {
    case v2(RuuviData2)
    case v3(RuuviData3)
    case v4(RuuviData4)
    case v5(RuuviData5)
    case vE0_F0(RuuviDataE0_F0)
    case vC5(RuuviDataC5)

    case h5(RuuviHeartbeat5)
    case hE0_F0(RuuviHeartbeatE0_F0)
    case hC5(RuuviHeartbeatC5)

    case n2(RuuviData2)
    case n3(RuuviData3)
    case n4(RuuviData4)
    case n5(RuuviData5)
    case nE0_F0(RuuviDataE0_F0)
    case nC5(RuuviDataC5)
}

public extension RuuviTag {

    var v2: RuuviData2? {
        if case let .v2(data) = self {
            return data
        } else {
            return nil
        }
    }

    var v3: RuuviData3? {
        if case let .v3(data) = self {
            return data
        } else {
            return nil
        }
    }

    var v4: RuuviData4? {
        if case let .v4(data) = self {
            return data
        } else {
            return nil
        }
    }

    var v5: RuuviData5? {
        if case let .v5(data) = self {
            return data
        } else {
            return nil
        }
    }

    var vE0_F0: RuuviDataE0_F0? {
        if case let .vE0_F0(data) = self {
            return data
        } else {
            return nil
        }
    }

    var vC5: RuuviDataC5? {
        if case let .vC5(data) = self {
            return data
        } else {
            return nil
        }
    }

    var volts: Double? {
        switch self {
        case .v2:
            return nil
        case .v3(let data):
            return data.voltage
        case .v4:
            return nil
        case .v5(let data):
            return data.voltage
        case .vE0_F0(let data):
            return data.voltage
        case .vC5(let data):
            return data.voltage
        case .h5(let heartbeat):
            return heartbeat.voltage
        case .hE0_F0(let heartbeat):
            return heartbeat.voltage
        case .hC5(let heartbeat):
            return heartbeat.voltage
        case .n2:
            return nil
        case .n3(let data):
            return data.voltage
        case .n4:
            return nil
        case .n5(let data):
            return data.voltage
        case .nE0_F0(let data):
            return data.voltage
        case .nC5(let data):
            return data.voltage
        }
    }

    var accelerationX: Double? {
        switch self {
        case .v2:
            return nil
        case .v3(let data):
            return data.accelerationX
        case .v4:
            return nil
        case .v5(let data):
            return data.accelerationX
        case .vE0_F0:
            return nil
        case .vC5:
            return nil
        case .h5(let heartbeat):
            return heartbeat.accelerationX
        case .hE0_F0:
            return nil
        case .hC5:
            return nil
        case .n2:
            return nil
        case .n3(let data):
            return data.accelerationX
        case .n4:
            return nil
        case .n5(let data):
            return data.accelerationX
        case .nE0_F0:
            return nil
        case .nC5:
            return nil
        }
    }

    var accelerationY: Double? {
        switch self {
        case .v2:
            return nil
        case .v3(let data):
            return data.accelerationY
        case .v4:
            return nil
        case .v5(let data):
            return data.accelerationY
        case .vE0_F0:
            return nil
        case .vC5:
            return nil
        case .h5(let heartbeat):
            return heartbeat.accelerationY
        case .hE0_F0:
            return nil
        case .hC5:
            return nil
        case .n2:
            return nil
        case .n3(let data):
            return data.accelerationY
        case .n4:
            return nil
        case .n5(let data):
            return data.accelerationY
        case .nE0_F0:
            return nil
        case .nC5:
            return nil
        }
    }

    var accelerationZ: Double? {
        switch self {
        case .v2:
            return nil
        case .v3(let data):
            return data.accelerationZ
        case .v4:
            return nil
        case .v5(let data):
            return data.accelerationZ
        case .vE0_F0:
            return nil
        case .vC5:
            return nil
        case .h5(let heartbeat):
            return heartbeat.accelerationZ
        case .hE0_F0:
            return nil
        case .hC5:
            return nil
        case .n2:
            return nil
        case .n3(let data):
            return data.accelerationZ
        case .n4:
            return nil
        case .n5(let data):
            return data.accelerationZ
        case .nE0_F0:
            return nil
        case .nC5:
            return nil
        }
    }

    var movementCounter: Int? {
        switch self {
        case .v2:
            return nil
        case .v3:
            return nil
        case .v4:
            return nil
        case .v5(let data):
            return data.movementCounter
        case .vE0_F0:
            return nil
        case .vC5(let data):
            return data.movementCounter
        case .h5(let heartbeat):
            return heartbeat.movementCounter
        case .hE0_F0:
            return nil
        case .hC5(let heartbeat):
            return heartbeat.movementCounter
        case .n2:
            return nil
        case .n3:
            return nil
        case .n4:
            return nil
        case .n5(let data):
            return data.movementCounter
        case .nE0_F0:
            return nil
        case .nC5(let data):
            return data.movementCounter
        }
    }

    var measurementSequenceNumber: Int? {
        switch self {
        case .v2:
            return nil
        case .v3:
            return nil
        case .v4:
            return nil
        case .v5(let data):
            return data.measurementSequenceNumber
        case .vE0_F0(let data):
            return data.measurementSequenceNumber
        case .vC5(let data):
            return data.measurementSequenceNumber
        case .h5(let heartbeat):
            return heartbeat.measurementSequenceNumber
        case .hE0_F0(let heartbeat):
            return heartbeat.measurementSequenceNumber
        case .hC5(let heartbeat):
            return heartbeat.measurementSequenceNumber
        case .n2:
            return nil
        case .n3:
            return nil
        case .n4:
            return nil
        case .n5(let data):
            return data.measurementSequenceNumber
        case .nE0_F0(let data):
            return data.measurementSequenceNumber
        case .nC5(let data):
            return data.measurementSequenceNumber
        }
    }

    var txPower: Int? {
        switch self {
        case .v2:
            return nil
        case .v3:
            return nil
        case .v4:
            return nil
        case .v5(let data):
            return data.txPower
        case .vE0_F0:
            return nil
        case .vC5(let data):
            return data.txPower
        case .h5(let heartbeat):
            return heartbeat.txPower
        case .hE0_F0:
            return nil
        case .hC5(let heartbeat):
            return heartbeat.txPower
        case .n2:
            return nil
        case .n3:
            return nil
        case .n4:
            return nil
        case .n5(let data):
            return data.txPower
        case .nE0_F0:
            return nil
        case .nC5(let data):
            return data.txPower
        }
    }

    var uuid: String {
        switch self {
        case .v2(let data):
            return data.uuid
        case .v3(let data):
            return data.uuid
        case .v4(let data):
            return data.uuid
        case .v5(let data):
            return data.uuid
        case .vE0_F0(let data):
            return data.uuid
        case .vC5(let data):
            return data.uuid
        case .h5(let heartbeat):
            return heartbeat.uuid
        case .hE0_F0(let heartbeat):
            return heartbeat.uuid
        case .hC5(let heartbeat):
            return heartbeat.uuid
        case .n2(let data):
            return data.uuid
        case .n3(let data):
            return data.uuid
        case .n4(let data):
            return data.uuid
        case .n5(let data):
            return data.uuid
        case .nE0_F0(let data):
            return data.uuid
        case .nC5(let data):
            return data.uuid
        }
    }

    var rssi: Int? {
        switch self {
        case .v2(let data):
            return data.rssi
        case .v3(let data):
            return data.rssi
        case .v4(let data):
            return data.rssi
        case .v5(let data):
            return data.rssi
        case .vE0_F0(let data):
            return data.rssi
        case .vC5(let data):
            return data.rssi
        case .h5, .hE0_F0, .hC5:
            return nil
        case .n2(let data):
            return data.rssi
        case .n3(let data):
            return data.rssi
        case .n4(let data):
            return data.rssi
        case .n5(let data):
            return data.rssi
        case .nE0_F0(let data):
            return data.rssi
        case .nC5(let data):
            return data.rssi
        }
    }

    var isConnectable: Bool {
        switch self {
        case .v2(let data):
            return data.isConnectable
        case .v3(let data):
            return data.isConnectable
        case .v4(let data):
            return data.isConnectable
        case .v5(let data):
            return data.isConnectable
        case .vE0_F0(let data):
            return data.isConnectable
        case .vC5(let data):
            return data.isConnectable
        case .h5(let heartbeat):
            return heartbeat.isConnectable
        case .hE0_F0(let heartbeat):
            return heartbeat.isConnectable
        case .hC5(let heartbeat):
            return heartbeat.isConnectable
        case .n2(let data):
            return data.isConnectable
        case .n3(let data):
            return data.isConnectable
        case .n4(let data):
            return data.isConnectable
        case .n5(let data):
            return data.isConnectable
        case .nE0_F0(let data):
            return data.isConnectable
        case .nC5(let data):
            return data.isConnectable
        }
    }

    var version: Int {
        switch self {
        case .v2(let data):
            return data.version
        case .v3(let data):
            return data.version
        case .v4(let data):
            return data.version
        case .v5(let data):
            return data.version
        case .vE0_F0(let data):
            return data.version
        case .vC5(let data):
            return data.version
        case .h5(let heartbeat):
            return heartbeat.version
        case .hE0_F0(let heartbeat):
            return heartbeat.version
        case .hC5(let heartbeat):
            return heartbeat.version
        case .n2(let data):
            return data.version
        case .n3(let data):
            return data.version
        case .n4(let data):
            return data.version
        case .n5(let data):
            return data.version
        case .nE0_F0(let data):
            return data.version
        case .nC5(let data):
            return data.version
        }
    }

    var relativeHumidity: Double? {
        switch self {
        case .v2(let data):
            return data.humidity
        case .v3(let data):
            return data.humidity
        case .v4(let data):
            return data.humidity
        case .v5(let data):
            return data.humidity
        case .vE0_F0(let data):
            return data.humidity
        case .vC5(let data):
            return data.humidity
        case .h5(let heartbeat):
            return heartbeat.humidity
        case .hE0_F0(let heartbeat):
            return heartbeat.humidity
        case .hC5(let heartbeat):
            return heartbeat.humidity
        case .n2(let data):
            return data.humidity
        case .n3(let data):
            return data.humidity
        case .n4(let data):
            return data.humidity
        case .n5(let data):
            return data.humidity
        case .nE0_F0(let data):
            return data.humidity
        case .nC5(let data):
            return data.humidity
        }
    }

    var hectopascals: Double? {
        switch self {
        case .v2(let data):
            return data.pressure
        case .v3(let data):
            return data.pressure
        case .v4(let data):
            return data.pressure
        case .v5(let data):
            return data.pressure
        case .vE0_F0(let data):
            return data.pressure
        case .vC5(let data):
            return data.pressure
        case .h5(let heartbeat):
            return heartbeat.pressure
        case .hE0_F0(let heartbeat):
            return heartbeat.pressure
        case .hC5(let heartbeat):
            return heartbeat.pressure
        case .n2(let data):
            return data.pressure
        case .n3(let data):
            return data.pressure
        case .n4(let data):
            return data.pressure
        case .n5(let data):
            return data.pressure
        case .nE0_F0(let data):
            return data.pressure
        case .nC5(let data):
            return data.pressure
        }
    }

    var inHg: Double? {
        if let pressure = hectopascals {
            return pressure / 33.86389
        } else {
            return nil
        }
    }

    var mmHg: Double? {
        if let pressure = hectopascals {
            return pressure / 1.333223684
        } else {
            return nil
        }
    }

    var celsius: Double? {
        switch self {
        case .v2(let data):
            return data.temperature
        case .v3(let data):
            return data.temperature
        case .v4(let data):
            return data.temperature
        case .v5(let data):
            return data.temperature
        case .vE0_F0(let data):
            return data.temperature
        case .vC5(let data):
            return data.temperature
        case .h5(let heartbeat):
            return heartbeat.temperature
        case .hE0_F0(let heartbeat):
            return heartbeat.temperature
        case .hC5(let heartbeat):
            return heartbeat.temperature
        case .n2(let data):
            return data.temperature
        case .n3(let data):
            return data.temperature
        case .n4(let data):
            return data.temperature
        case .n5(let data):
            return data.temperature
        case .nE0_F0(let data):
            return data.temperature
        case .nC5(let data):
            return data.temperature
        }
    }

    var mac: String? {
        switch self {
        case .v5(let data):
            return data.mac
        case .vE0_F0(let data):
            return data.mac
        case .vC5(let data):
            return data.mac
        case .n5(let data):
            return data.mac
        case .nE0_F0(let data):
            return data.mac
        case .nC5(let data):
            return data.mac
        default:
            return nil
        }
    }

    var fahrenheit: Double? {
        if let celsius = celsius {
            return (celsius * 9.0 / 5.0) + 32.0
        } else {
            return nil
        }
    }

    var kelvin: Double? {
        if let celsius = celsius {
            return celsius + 273.15
        } else {
            return nil
        }
    }

    var serviceUUID: String? {
        switch self {
        case .vE0_F0:
            return vE0_F0?.serviceUUID
        case .vC5:
            return vC5?.serviceUUID
        default:
            return nil
        }
    }

    var pMatter1_0: Double? {
        switch self {
        case .vE0_F0(let data):
            return data.pm1
        case .hE0_F0(let heartbeat):
            return heartbeat.pm1
        case .nE0_F0(let data):
            return data.pm1
        default:
            return nil
        }
    }

    var pMatter2_5: Double? {
        switch self {
        case .vE0_F0(let data):
            return data.pm2_5
        case .hE0_F0(let heartbeat):
            return heartbeat.pm2_5
        case .nE0_F0(let data):
            return data.pm2_5
        default:
            return nil
        }
    }

    var pMatter4: Double? {
        switch self {
        case .vE0_F0(let data):
            return data.pm4
        case .hE0_F0(let heartbeat):
            return heartbeat.pm4
        case .nE0_F0(let data):
            return data.pm4
        default:
            return nil
        }
    }

    var pMatter10: Double? {
        switch self {
        case .vE0_F0(let data):
            return data.pm10
        case .hE0_F0(let heartbeat):
            return heartbeat.pm10
        case .nE0_F0(let data):
            return data.pm10
        default:
            return nil
        }
    }

    var carbonDioxide: Double? {
        switch self {
        case .vE0_F0(let data):
            return data.co2
        case .hE0_F0(let heartbeat):
            return heartbeat.co2
        case .nE0_F0(let data):
            return data.co2
        default:
            return nil
        }
    }

    var volatileOrganicCompound: Double? {
        switch self {
        case .vE0_F0(let data):
            return data.voc
        case .hE0_F0(let heartbeat):
            return heartbeat.voc
        case .nE0_F0(let data):
            return data.voc
        default:
            return nil
        }
    }

    var nitrogenOxide: Double? {
        switch self {
        case .vE0_F0(let data):
            return data.nox
        case .hE0_F0(let heartbeat):
            return heartbeat.nox
        case .nE0_F0(let data):
            return data.nox
        default:
            return nil
        }
    }

    var luminanceValue: Double? {
        switch self {
        case .vE0_F0(let data):
            return data.luminance
        case .hE0_F0(let heartbeat):
            return heartbeat.luminance
        case .nE0_F0(let data):
            return data.luminance
        default:
            return nil
        }
    }

    var decibelAverage: Double? {
        switch self {
        case .vE0_F0(let data):
            return data.dbaAvg
        case .hE0_F0(let heartbeat):
            return heartbeat.dbaAvg
        case .nE0_F0(let data):
            return data.dbaAvg
        default:
            return nil
        }
    }

    var decibelPeak: Double? {
        switch self {
        case .vE0_F0(let data):
            return data.dbaPeak
        case .hE0_F0(let heartbeat):
            return heartbeat.dbaPeak
        case .nE0_F0(let data):
            return data.dbaPeak
        default:
            return nil
        }
    }
}

extension RuuviTag: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .v2(let data):
            hasher.combine(data.uuid)
            hasher.combine("v2")
        case .v3(let data):
            hasher.combine(data.uuid)
            hasher.combine("v3")
        case .v4(let data):
            hasher.combine(data.uuid)
            hasher.combine("v4")
        case .v5(let data):
            hasher.combine(data.uuid)
            hasher.combine("v5")
        case .vE0_F0(let data):
            hasher.combine(data.uuid)
            hasher.combine("v6")
        case .vC5(let data):
            hasher.combine(data.uuid)
            hasher.combine("vC5")
        case .h5(let heartbeat):
            hasher.combine(heartbeat.uuid)
            hasher.combine("h5")
        case .hE0_F0(let heartbeat):
            hasher.combine(heartbeat.uuid)
            hasher.combine("h6")
        case .hC5(let heartbeat):
            hasher.combine(heartbeat.uuid)
            hasher.combine("hC5")
        case .n2(let data):
            hasher.combine(data.uuid)
            hasher.combine("n2")
        case .n3(let data):
            hasher.combine(data.uuid)
            hasher.combine("n3")
        case .n4(let data):
            hasher.combine(data.uuid)
            hasher.combine("n4")
        case .n5(let data):
            hasher.combine(data.uuid)
            hasher.combine("n5")
        case .nE0_F0(let data):
            hasher.combine(data.uuid)
            hasher.combine("n6")
        case .nC5(let data):
            hasher.combine(data.uuid)
            hasher.combine("nC5")
        }
    }
}

extension RuuviTag: Equatable {
    public static func ==(lhs: RuuviTag, rhs: RuuviTag) -> Bool {
        switch (lhs, rhs) {
        case let (.v2(l), .v2(r)): return l.uuid == r.uuid
        case let (.v3(l), .v3(r)): return l.uuid == r.uuid
        case let (.v4(l), .v4(r)): return l.uuid == r.uuid
        case let (.v5(l), .v5(r)): return l.uuid == r.uuid
        case let (.vE0_F0(l), .vE0_F0(r)): return l.uuid == r.uuid
        case let (.vC5(l), .vC5(r)): return l.uuid == r.uuid
        default: return false
        }
    }
}

public extension RuuviTag {
    var isConnected: Bool {
        return BTKit.background.scanner.isConnected(uuid: uuid)
    }

    @discardableResult
    func connect<T: AnyObject>(for observer: T, connected: @escaping (T, BTConnectResult) -> Void, heartbeat: @escaping (T, BTDevice) -> Void, disconnected: @escaping (T, BTDisconnectResult) -> Void) -> ObservationToken? {
        return connect(for: observer, options: nil, connected: connected, heartbeat: heartbeat, disconnected: disconnected)
    }

    @discardableResult
    func connect<T: AnyObject>(for observer: T, options: BTScannerOptionsInfo?, connected: @escaping (T, BTConnectResult) -> Void, heartbeat: @escaping (T, BTDevice) -> Void, disconnected: @escaping (T, BTDisconnectResult) -> Void) -> ObservationToken? {
        if !isConnectable {
            let info = BTKitParsedOptionsInfo(options)
            info.callbackQueue.execute {
                connected(observer, .failure(.logic(.notConnectable)))
            }
            return nil
        } else {
            return BTKit.background.connect(for: observer, uuid: uuid, options: options, connected: connected, heartbeat: heartbeat, disconnected: disconnected)
        }
    }

    @discardableResult
    func disconnect<T: AnyObject>(for observer: T, result: @escaping (T, BTDisconnectResult) -> Void) -> ObservationToken? {
        return disconnect(for: observer, options: nil, result: result)
    }

    @discardableResult
    func disconnect<T: AnyObject>(for observer: T, options: BTScannerOptionsInfo?, result: @escaping (T, BTDisconnectResult) -> Void) -> ObservationToken? {
        if !isConnectable {
            let info = BTKitParsedOptionsInfo(options)
            info.callbackQueue.execute {
                result(observer, .failure(.logic(.notConnectable)))
            }
            return nil
        } else {
            return BTKit.background.disconnect(for: observer, uuid: uuid, options: options, result: result)
        }
    }

    func celisus<T: AnyObject>(for observer: T, from date: Date, result: @escaping (T, Result<[RuuviTagEnvLog], BTError>) -> Void) {
        celisus(for: observer, from: date, options: nil, result: result)
    }

    func celisus<T: AnyObject>(for observer: T, from date: Date, options: BTScannerOptionsInfo?, result: @escaping (T, Result<[RuuviTagEnvLog], BTError>) -> Void) {
        if !isConnectable {
            let info = BTKitParsedOptionsInfo(options)
            info.callbackQueue.execute {
                result(observer, .failure(.logic(.notConnectable)))
            }
        } else {
            BTKit.background.services.ruuvi.nus.celisus(for: observer, uuid: uuid, from: date, result: result)
        }
    }

    func humidity<T: AnyObject>(for observer: T, from date: Date, result: @escaping (T, Result<[RuuviTagEnvLog], BTError>) -> Void) {
        humidity(for: observer, from: date, options: nil, result: result)
    }

    func humidity<T: AnyObject>(for observer: T, from date: Date, options: BTScannerOptionsInfo?, result: @escaping (T, Result<[RuuviTagEnvLog], BTError>) -> Void) {
        if !isConnectable {
            let info = BTKitParsedOptionsInfo(options)
            info.callbackQueue.execute {
                result(observer, .failure(.logic(.notConnectable)))
            }
        } else {
            BTKit.background.services.ruuvi.nus.humidity(for: observer, uuid: uuid, from: date, options: options, result: result)
        }
    }

    func pressure<T: AnyObject>(for observer: T, from date: Date, result: @escaping (T, Result<[RuuviTagEnvLog], BTError>) -> Void) {
        pressure(for: observer, from: date, options: nil, result: result)
    }

    func pressure<T: AnyObject>(for observer: T, from date: Date, options: BTScannerOptionsInfo?, result: @escaping (T, Result<[RuuviTagEnvLog], BTError>) -> Void) {
        if !isConnectable {
            let info = BTKitParsedOptionsInfo(options)
            info.callbackQueue.execute {
                result(observer, .failure(.logic(.notConnectable)))
            }
        } else {
            BTKit.background.services.ruuvi.nus.pressure(for: observer, uuid: uuid, from: date, options: options, result: result)
        }
    }

    func log<T: AnyObject>(
        for observer: T,
        from date: Date,
        service: BTRuuviNUSService,
        result: @escaping (T, Result<Progressable, BTError>) -> Void
    ) {
        log(
            for: observer,
            from: date,
            service: service,
            options: nil,
            result: result
        )
    }

    func log<T: AnyObject>(
        for observer: T,
        from date: Date,
        service: BTRuuviNUSService,
        options: BTScannerOptionsInfo?,
        result: @escaping (T, Result<Progressable, BTError>) -> Void
    ) {
        if !isConnectable {
            let info = BTKitParsedOptionsInfo(options)
            info.callbackQueue.execute {
                result(observer, .failure(.logic(.notConnectable)))
            }
        } else {
            BTKit.background.services.ruuvi.nus.log(
                for: observer,
                uuid: uuid,
                from: date,
                service: service,
                options: options, result: result
            )
        }
    }
}
