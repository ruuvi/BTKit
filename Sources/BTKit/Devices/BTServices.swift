import Foundation
import CoreBluetooth

public enum BTServiceProgress {
    case connecting
    case serving
    case reading(Int)
    case disconnecting
    case success
    case failure(BTError)
}

public enum Progressable {
    case points(Int)
    case logs([RuuviTagEnvLogFull])
}

public enum BTServiceType {
    case ruuvi(BTRuuviServiceType)
    case gatt(BTGATTServiceType)

    var uuid: CBUUID {
        switch self {
        case .ruuvi(let type):
            switch type {
            case .nus(let service):
                return service.uuid
            }
        case .gatt(let type):
            switch type {
            case .deviceInformation(let service):
                return service.uuid
            }
        }
    }
}

public enum BTGATTDeviceInformationService {
    case firmwareRevision(BTGATTDeviceInformationFirmwareRevisionService)
    case serialRevision(BTGATTDeviceInformationSerialRevisionService)

    var uuid: CBUUID {
        switch self {
        case .firmwareRevision(let value):
            return value.uuid
        case .serialRevision(let value):
            return value.uuid
        }
    }

    var characteristic: CBUUID {
        switch self {
        case .firmwareRevision(let value):
            return value.characteristic
        case .serialRevision(let value):
            return value.characteristic
        }
    }
}

public enum BTGATTDeviceInformationFirmwareRevisionService {
    case standard

    var uuid: CBUUID {
        switch self {
        case .standard:
            return CBUUID(string: "180a")
        }
    }

    var characteristic: CBUUID {
        switch self {
        case .standard:
            return CBUUID(string: "2a26")
        }
    }
}

public enum BTGATTDeviceInformationSerialRevisionService {
    case standard

    var uuid: CBUUID {
        switch self {
        case .standard:
            return CBUUID(string: "180a")
        }
    }

    var characteristic: CBUUID {
        switch self {
        case .standard:
            return CBUUID(string: "2a25")
        }
    }
}

public enum BTRuuviNUSService {
    case temperature // in °C
    case humidity // relative in %
    case pressure // in hPa
    case e1
    case all

    var uuid: CBUUID {
        return CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    }

    var flag: UInt8 {
        switch self {
        case .temperature:
            return 0x30
        case .humidity:
            return 0x31
        case .pressure:
            return 0x32
        case .e1:
            return 0x3B
        case .all:
            return 0x3A
        }
    }

    var multiplier: Double {
        switch self {
        case .temperature:
            return 0.01
        case .humidity:
            return 0.01
        case .pressure:
            return 0.01
        case .e1:
            return 0.01
        case .all:
            return 0.01
        }
    }

    func request(from date: Date) -> Data {
        // big-endian times
        let nowSeconds = UInt32(Date().timeIntervalSince1970).bigEndian
        let fromSeconds = UInt32(max(0, date.timeIntervalSince1970)).bigEndian
        let nowData = withUnsafeBytes(of: nowSeconds) { Data($0) }
        let fromData = withUnsafeBytes(of: fromSeconds) { Data($0) }

        var data = Data()
        data.append(flag)

        switch self {
        case .e1:
            data.append(0x00)
            data.append(0x21)
        default:
            data.append(0x30)
            data.append(0x11)
        }

        data.append(nowData)
        data.append(fromData)
        return data
    }

    func responseRow(from data: Data) -> (Date, BTRuuviNUSService, Double)? {
        guard data.count == 11 else { return nil }
        var service: BTRuuviNUSService
        switch data[1] {
        case BTRuuviNUSService.temperature.flag:
            service = .temperature
        case BTRuuviNUSService.humidity.flag:
            service = .humidity
        case BTRuuviNUSService.pressure.flag:
            service = .pressure
        default:
            return nil
        }
        guard let value = response(from: data, for: service) else { return nil }
        return (value.0, service, value.1)
    }

    func response(from data: Data) -> (Date, Double)? {
        return response(from: data, for: self)
    }

    func response(from data: Data, for service: BTRuuviNUSService) -> (Date, Double)? {
        guard data.count == 11 else { return nil }
        guard data[1] == service.flag else { return nil }
        let timestampData = data[3...6]
        var timestamp: UInt32 = 0
        let timestampBytesCopied = withUnsafeMutableBytes(of: &timestamp, { timestampData.copyBytes(to: $0)})
        timestamp = UInt32(bigEndian: timestamp)
        assert(timestampBytesCopied == MemoryLayout.size(ofValue: timestamp))

        let valueData = data[7...10]
        var value: Int32 = 0
        let valueBytesCopied = withUnsafeMutableBytes(of: &value, { valueData.copyBytes(to: $0) })
        assert(valueBytesCopied == MemoryLayout.size(ofValue: value))

        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        value = Int32(bigEndian: value)
        return (date, Double(value) * service.multiplier)
    }

    func isEndOfTransmissionFlag(data: Data) -> Bool {
        guard data.count == 11 else { return false }
        let payload = data[3...10]
        var value: UInt64 = 0
        let bytesCopied = withUnsafeMutableBytes(of: &value, { payload.copyBytes(to: $0)})
        assert(bytesCopied == MemoryLayout.size(ofValue: value))
        return value == UInt64.max
    }

    func responseE1(_ data: Data) -> ([RuuviTagEnvLogFull], Bool)? {
        guard data.count >= 5 else { return nil }
        // Byte1 = src (0x3B), Byte2 = op (0x20), Byte3 = numRecords, Byte4 = recordLen
        let src   = data[1]
        let op    = data[2]
        let count = data[3]       // numRecords
        let len   = data[4]       // recordLen
        if src != 0x3B || (op != 0x20 && op != 0x10) {
            return nil
        }
        if count == 0 {
            // Means no more records => end
            return ([], true)
        }
        // Each record is len bytes
        let neededSize = 5 + Int(count) * Int(len)
        guard data.count >= neededSize else { return nil }

        var records = [RuuviTagEnvLogFull]()
        var offset = 5
        for _ in 0..<count {
            let chunk = data.subdata(in: offset..<(offset + Int(len)))
            offset += Int(len)
            if let rec = chunk.ruuviLogE1() {
                records.append(rec)
            }
        }
        return (records, false)
    }
}

public enum BTRuuviServiceType {
    case nus(BTRuuviNUSService)
}

public enum BTGATTServiceType {
    case deviceInformation(BTGATTDeviceInformationService)

    var uuid: CBUUID {
        switch self {
        case .deviceInformation(let value):
            return value.uuid
        }
    }

    var characteristic: CBUUID {
        switch self {
        case .deviceInformation(let value):
            return value.characteristic
        }
    }
}

public protocol BTService: AnyObject {
    var uuid: CBUUID { get }
}

public protocol BTUARTService: BTService {
    var txUUID: CBUUID { get }
    var rxUUID: CBUUID { get }
}

public struct BTServices {
    public let ruuvi = BTRuuviServices()
    public let gatt = BTGATTService()
}

public struct BTRuuviServices {
    public let nus = BTKitRuuviNUSService()
}

public struct BTGATTService {
    public func serialRevision<T: AnyObject>(
        for observer: T,
        uuid: String,
        options: BTScannerOptionsInfo? = nil,
        progress: ((BTServiceProgress) -> Void)? = nil,
        result: @escaping (T, Result<String, BTError>) -> Void
    ) {
        serveRevision(
            for: observer,
            uuid: uuid,
            type: .deviceInformation(.serialRevision(.standard)),
            options: options,
            progress: progress,
            result: result
        )
    }

    public func firmwareRevision<T: AnyObject>(
        for observer: T,
        uuid: String,
        options: BTScannerOptionsInfo? = nil,
        progress: ((BTServiceProgress) -> Void)? = nil,
        result: @escaping (T, Result<String, BTError>) -> Void
    ) {
        serveRevision(
            for: observer,
            uuid: uuid,
            type: .deviceInformation(.firmwareRevision(.standard)),
            options: options,
            progress: progress,
            result: result
        )
    }

    private func serveRevision<T: AnyObject>(
        for observer: T,
        uuid: String,
        type: BTGATTServiceType,
        options: BTScannerOptionsInfo?,
        progress: ((BTServiceProgress) -> Void)? = nil,
        result: @escaping (T, Result<String, BTError>) -> Void
    ) {
        var connectToken: ObservationToken?
        progress?(.connecting)
        connectToken = BTKit.background.connect(for: observer, uuid: uuid, options: options, connected: { (observer, connectResult) in
            connectToken?.invalidate()
            switch connectResult {
            case .already, .just:
                var serveToken: ObservationToken?
                progress?(.serving)
                serveToken = self.serve(observer, uuid, type, options) { observer, serveResult in
                    serveToken?.invalidate()
                    var disconnectToken: ObservationToken?
                    progress?(.disconnecting)
                    disconnectToken = BTKit.background.disconnect(for: observer, uuid: uuid, options: options) { (observer, disconnectResult) in
                        disconnectToken?.invalidate()
                        switch disconnectResult {
                        case .already, .just, .stillConnected, .bluetoothWasPoweredOff:
                            progress?(.success)
                            result(observer, serveResult)
                        case .failure(let error):
                            progress?(.failure(error))
                            result(observer, .failure(error))
                        }
                    }
                }
            case .failure(let error):
                progress?(.failure(error))
                result(observer, .failure(error))
            case .disconnected:
                break // do nothing, it will reconnect
            }
        })
    }

    private func serve<T: AnyObject>(
        _ observer: T,
        _ uuid: String,
        _ type: BTGATTServiceType,
        _ options: BTScannerOptionsInfo?,
        _ result: @escaping (T, Result<String, BTError>) -> Void
    ) -> ObservationToken? {
        let info = BTKitParsedOptionsInfo(options)
        let serveToken = BTKit.background.scanner.serveGATT(
            observer,
            for: uuid,
            type,
            options: options,
            request: { (observer, peripheral, characteristic) in
            if let characteristic = characteristic {
                peripheral?.readValue(for: characteristic)
            } else {
                info.callbackQueue.execute {
                    result(observer, .failure(.unexpected(.characteristicIsNil)))
                }
            }
        }, response: { (observer, data, _) in
            if let data = data {
                if let firmwareRevisionString = String(data: data, encoding: .utf8) {
                    result(observer, .success(firmwareRevisionString))
                } else {
                    result(observer, .failure(.unexpected(.dataIsNil)))
                }
            } else {
                info.callbackQueue.execute {
                    result(observer, .failure(.unexpected(.dataIsNil)))
                }
            }
        }) { (observer, error) in
            info.callbackQueue.execute {
                result(observer, .failure(error))
            }
        }
        return serveToken
    }
}

public struct BTKitRuuviNUSService {

    public func celisus<T: AnyObject>(for observer: T, uuid: String, from date: Date, options: BTScannerOptionsInfo? = nil, progress: ((BTServiceProgress) -> Void)? = nil, result: @escaping (T, Result<[RuuviTagEnvLog], BTError>) -> Void) {
        serve(.temperature, for: observer, uuid: uuid, from: date, options: options, result: result)
    }

    public func humidity<T: AnyObject>(for observer: T, uuid: String, from date: Date, options: BTScannerOptionsInfo? = nil, progress: ((BTServiceProgress) -> Void)? = nil, result: @escaping (T, Result<[RuuviTagEnvLog], BTError>) -> Void) {
        serve(.humidity, for: observer, uuid: uuid, from: date, options: options, result: result)
    }

    public func pressure<T: AnyObject>(for observer: T, uuid: String, from date: Date, options: BTScannerOptionsInfo? = nil, progress: ((BTServiceProgress) -> Void)? = nil, result: @escaping (T, Result<[RuuviTagEnvLog], BTError>) -> Void) {
        serve(.pressure, for: observer, uuid: uuid, from: date, options: options, result: result)
    }

    public func log<T: AnyObject>(
        for observer: T,
        uuid: String,
        from date: Date,
        service: BTRuuviNUSService,
        options: BTScannerOptionsInfo? = nil,
        progress: ((BTServiceProgress) -> Void)? = nil,
        result: @escaping (T, Result<Progressable, BTError>
        ) -> Void) {
        var connectToken: ObservationToken?
        progress?(.connecting)
        connectToken = BTKit.background.connect(for: observer, uuid: uuid, options: options, connected: { (observer, connectResult) in
            connectToken?.invalidate()
            switch connectResult {
            case .already:
                var serveToken: ObservationToken?
                progress?(.serving)
                serveToken = self.serveLogs(
                    observer, uuid, service, options, date
                ) { observer, serveResult in
                    var disconnectToken: ObservationToken?
                    switch serveResult {
                    case .success(.points(let points)):
                        progress?(.reading(points))
                    case .success(.logs):
                        serveToken?.invalidate()
                        progress?(.disconnecting)
                        disconnectToken = BTKit.background.disconnect(for: observer, uuid: uuid, options: options) { (observer, disconnectResult) in
                            disconnectToken?.invalidate()
                            switch disconnectResult {
                            case .already:
                                progress?(.success)
                                result(observer, serveResult)
                            case .just:
                                progress?(.success)
                                result(observer, serveResult)
                            case .stillConnected:
                                result(observer, serveResult)
                                progress?(.success)
                            case .bluetoothWasPoweredOff:
                                progress?(.success)
                                result(observer, serveResult)
                            case .failure(let error):
                                progress?(.failure(error))
                                result(observer, .failure(error))
                            }
                        }
                    case let .failure(error):
                        progress?(.failure(error))
                        result(observer, .failure(error))
                    }

                }
            case .just:
                var serveToken: ObservationToken?
                progress?(.serving)
                serveToken = self.serveLogs(
                    observer, uuid, service, options, date
                ) { observer, serveResult in
                    switch serveResult {
                    case .success(.points(let points)):
                        progress?(.reading(points))
                    case .success(.logs):
                        serveToken?.invalidate()
                        var disconnectToken: ObservationToken?
                        progress?(.disconnecting)
                        disconnectToken = BTKit.background.disconnect(for: observer, uuid: uuid, options: options) { (observer, disconnectResult) in
                            disconnectToken?.invalidate()
                            switch disconnectResult {
                            case .already:
                                progress?(.success)
                                result(observer, serveResult)
                            case .just:
                                progress?(.success)
                                result(observer, serveResult)
                            case .stillConnected:
                                progress?(.success)
                                result(observer, serveResult)
                            case .bluetoothWasPoweredOff:
                                progress?(.success)
                                result(observer, serveResult)
                            case .failure(let error):
                                progress?(.failure(error))
                                result(observer, .failure(error))
                            }
                        }
                    case .failure(let error):
                        progress?(.failure(error))
                        result(observer, .failure(error))
                    }
                }
            case .failure(let error):
                progress?(.failure(error))
                result(observer, .failure(error))
            case .disconnected:
                break // do nothing, it will reconnect
            }
        })
    }

    private func serveLogs<T: AnyObject>(
        _ observer: T,
        _ uuid: String,
        _ service: BTRuuviNUSService,
        _ options: BTScannerOptionsInfo?,
        _ date: Date,
        _ result: @escaping (T, Result<Progressable, BTError>) -> Void
    ) -> ObservationToken? {
        let info = BTKitParsedOptionsInfo(options)
        var values = [RuuviTagEnvLogFull]()
        var lastValue = RuuviTagEnvLogFullClass()
        let serveToken = BTKit.background.scanner.serveUART(
            observer,
            for: uuid, .ruuvi(.nus(service)),
            options: options,
            request: { (observer, peripheral, rx, _) in
            if let rx = rx {
                peripheral?.writeValue(service.request(from: date), for: rx, type: .withResponse)
            } else {
                info.callbackQueue.execute {
                    result(observer, .failure(.unexpected(.characteristicIsNil)))
                }
            }
        }, response: { (observer, data, finished) in
            if let data = data {
                switch service {
                case .e1:
                    if let (records, done) = service.responseE1(data) {
                        values.append(contentsOf: records)
                        if !records.isEmpty {
                            result(observer, .success(.points(values.count)))
                        }
                        if done {
                            finished?(true)
                            info.callbackQueue.execute {
                                result(observer, .success(.logs(values)))
                            }
                        }
                    } else {
                        info.callbackQueue.execute {
                            result(observer, .failure(.unexpected(.dataIsNil)))
                        }
                    }
                default:
                    if service.isEndOfTransmissionFlag(data: data) {
                        finished?(true)
                        info.callbackQueue.execute {
                            result(observer, .success(.logs(values)))
                        }
                    } else if let row = service.responseRow(from: data) {
                        switch row.1 {
                        case .temperature:
                            lastValue.temperature = row.2
                        case .humidity:
                            lastValue.humidity = row.2
                        case .pressure:
                            lastValue.pressure = row.2
                        case .all, .e1:
                            break
                        }
                        if let t = lastValue.temperature,
                            let h = lastValue.humidity,
                            let p = lastValue.pressure {
                            let log = RuuviTagEnvLogFull(date: row.0, temperature: t, humidity: h, pressure: p)
                            values.append(log)
                            lastValue = RuuviTagEnvLogFullClass()
                            result(observer, .success(.points(values.count)))
                        }
                    }
                }

            } else {
                info.callbackQueue.execute {
                    result(observer, .failure(.unexpected(.dataIsNil)))
                }
            }
        }) { (observer, error) in
            info.callbackQueue.execute {
                result(observer, .failure(error))
            }
        }
        return serveToken
    }

    fileprivate func serveEnv<T: AnyObject>(_ observer: T, _ uuid: String, _ service: BTRuuviNUSService, _ options: BTScannerOptionsInfo?, _ date: Date, _ result: @escaping (T, Result<[RuuviTagEnvLog], BTError>) -> Void) -> ObservationToken? {
        let info = BTKitParsedOptionsInfo(options)
        var values = [RuuviTagEnvLog]()
        let serveToken = BTKit.background.scanner.serveUART(observer, for: uuid, .ruuvi(.nus(service)), options: options, request: { (observer, peripheral, rx, _) in
            if let rx = rx {
                peripheral?.writeValue(service.request(from: date), for: rx, type: .withResponse)
            } else {
                info.callbackQueue.execute {
                    result(observer, .failure(.unexpected(.characteristicIsNil)))
                }
            }
        }, response: { (observer, data, finished) in
            if let data = data {
                if service.isEndOfTransmissionFlag(data: data) {
                    finished?(true)
                    info.callbackQueue.execute {
                        result(observer, .success(values))
                    }
                } else if let row = service.response(from: data) {
                    values.append(RuuviTagEnvLog(type: service, date: row.0, value: row.1))
                }
            } else {
                info.callbackQueue.execute {
                    result(observer, .failure(.unexpected(.dataIsNil)))
                }
            }
        }) { (observer, error) in
            info.callbackQueue.execute {
                result(observer, .failure(error))
            }
        }
        return serveToken
    }

    private func serve<T: AnyObject>(_ service: BTRuuviNUSService, for observer: T, uuid: String, from date: Date, options: BTScannerOptionsInfo?, progress: ((BTServiceProgress) -> Void)? = nil, result: @escaping (T, Result<[RuuviTagEnvLog], BTError>) -> Void) {

        var connectToken: ObservationToken?
        progress?(.connecting)
        connectToken = BTKit.background.connect(for: observer, uuid: uuid, options: options, connected: { (observer, connectResult) in
            connectToken?.invalidate()
            switch connectResult {
            case .already:
                var serveToken: ObservationToken?
                progress?(.serving)
                serveToken = self.serveEnv(observer, uuid, service, options, date) { observer, serveResult in
                    serveToken?.invalidate()
                    var disconnectToken: ObservationToken?
                    progress?(.disconnecting)
                    disconnectToken = BTKit.background.disconnect(for: observer, uuid: uuid, options: options) { (observer, disconnectResult) in
                        disconnectToken?.invalidate()
                        switch disconnectResult {
                        case .already:
                            progress?(.success)
                            result(observer, serveResult)
                        case .just:
                            progress?(.success)
                            result(observer, serveResult)
                        case .stillConnected:
                            progress?(.success)
                            result(observer, serveResult)
                        case .bluetoothWasPoweredOff:
                            progress?(.success)
                            result(observer, serveResult)
                        case .failure(let error):
                            progress?(.failure(error))
                            result(observer, .failure(error))
                        }
                    }
                }
            case .just:
                var serveToken: ObservationToken?
                progress?(.serving)
                serveToken = self.serveEnv(observer, uuid, service, options, date) { observer, serveResult in
                    serveToken?.invalidate()
                    var disconnectToken: ObservationToken?
                    progress?(.disconnecting)
                    disconnectToken = BTKit.background.disconnect(for: observer, uuid: uuid, options: options) { (observer, disconnectResult) in
                        disconnectToken?.invalidate()
                        switch disconnectResult {
                        case .already:
                            progress?(.success)
                            result(observer, serveResult)
                        case .just:
                            progress?(.success)
                            result(observer, serveResult)
                        case .stillConnected:
                            progress?(.success)
                            result(observer, serveResult)
                        case .bluetoothWasPoweredOff:
                            progress?(.success)
                            result(observer, serveResult)
                        case .failure(let error):
                            progress?(.failure(error))
                            result(observer, .failure(error))
                        }
                    }
                }
            case .failure(let error):
                progress?(.failure(error))
                result(observer, .failure(error))
            case .disconnected:
                break // do nothing, it will reconnect
            }
        })
    }

    public func disconnect<T: AnyObject>(
        for observer: T,
        uuid: String,
        options: BTScannerOptionsInfo?,
        result: @escaping (T, Result<BTDisconnectResult, BTError>) -> Void
    ) {
        var disconnectToken: ObservationToken?
        disconnectToken = BTKit.background.disconnect(
            for: observer, uuid: uuid, options: options
        ) { (observer, disconnectResult) in
            disconnectToken?.invalidate()
            switch disconnectResult {
            case .already, .just, .stillConnected, .bluetoothWasPoweredOff:
                result(observer, .success(disconnectResult))
            case .failure(let error):
                result(observer, .failure(error))
            }
        }
    }
}

public struct RuuviTagEnvLog {
    public var type: BTRuuviNUSService
    public var date: Date
    public var value: Double
}

public struct RuuviTagEnvLogFull {
    public var date: Date
    public var temperature: Double? // in °C
    public var humidity: Double? // relative in %
    public var pressure: Double? // in hPa

    // E1-specific fields
    public var pm1: Double?
    public var pm25: Double?
    public var pm4: Double?
    public var pm10: Double?
    public var co2: Double?
    public var voc: Double?
    public var nox: Double?
    public var luminosity: Double?
    public var soundInstant: Double?
    public var soundAvg: Double?
    public var soundPeak: Double?
    public var batteryVoltage: Double?
    public var measurementSequenceNumber: Int?
}

class RuuviTagEnvLogFullClass {
    var date: Date?
    var temperature: Double? // in °C
    var humidity: Double? // relative in %
    var pressure: Double? // in hPa

    // E1-specific fields
    var pm1: Double?
    var pm25: Double?
    var pm4: Double?
    var pm10: Double?
    var co2: Double?
    var voc: Double?
    var nox: Double?
    var luminosity: Double?
    var soundInstant: Double?
    var soundAvg: Double?
    var soundPeak: Double?
    var batteryVoltage: Double?
    var measurementSequenceNumber: Int?
}
