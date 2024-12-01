import CoreBluetooth

public struct RuuviDecoderiOS: BTDecoder {

    public init() {
    }

    public func decodeNetwork(
        uuid: String,
        rssi: Int,
        isConnectable: Bool,
        payload: String
    ) -> BTDevice? {
        guard let data = payload.hex else { return nil }
        guard data.count > 18 else { return nil }

        let (serviceUUID, parsable, version) = extractAdvertisementData(from: data)
        guard let parsable = parsable,
              let version = version else {
            return nil
        }

        switch version {
        case 2: // Handle version 2
            guard parsable.count > 5 else { return nil }
            let ruuvi = parsable.ruuvi2()
            let tag = RuuviData2(
                uuid: uuid,
                rssi: rssi,
                isConnectable: isConnectable,
                version: ruuvi.version,
                temperature: ruuvi.temperature,
                humidity: ruuvi.humidity,
                pressure: ruuvi.pressure
            )
            return .ruuvi(.tag(.n2(tag)))
        case 3: // Handle version 3
            guard parsable.count > 15 else { return nil }
            let ruuvi = parsable.ruuvi3()
            let tag = RuuviData3(
                uuid: uuid,
                rssi: rssi,
                isConnectable: isConnectable,
                version: Int(
                    version
                ),
                humidity: ruuvi.humidity,
                temperature: ruuvi.temperature,
                pressure: ruuvi.pressure,
                accelerationX: ruuvi.accelerationX,
                accelerationY: ruuvi.accelerationY,
                accelerationZ: ruuvi.accelerationZ,
                voltage: ruuvi.voltage
            )
            return .ruuvi(.tag(.n3(tag)))
        case 4: // Handle version 4
            guard parsable.count > 5 else { return nil }
            let ruuvi = parsable.ruuvi4()
            let tag = RuuviData4(
                uuid: uuid,
                rssi: rssi,
                isConnectable: isConnectable,
                version: ruuvi.version,
                temperature: ruuvi.temperature,
                humidity: ruuvi.humidity,
                pressure: ruuvi.pressure
            )
            return .ruuvi(.tag(.n4(tag)))
        case 5: // Handle version 5
            guard parsable.count > 19 else { return nil }
            let ruuvi = parsable.ruuvi5()
            let tag = RuuviData5(
                uuid: uuid,
                rssi: rssi,
                isConnectable: isConnectable,
                version: Int(
                    version
                ),
                humidity: ruuvi.humidity,
                temperature: ruuvi.temperature,
                pressure: ruuvi.pressure,
                accelerationX: ruuvi.accelerationX,
                accelerationY: ruuvi.accelerationY,
                accelerationZ: ruuvi.accelerationZ,
                voltage: ruuvi.voltage,
                movementCounter: ruuvi.movementCounter,
                measurementSequenceNumber: ruuvi.measurementSequenceNumber,
                txPower: ruuvi.txPower,
                mac: ruuvi.mac
            )
            return .ruuvi(.tag(.n5(tag)))
        case 0xE0: // Handle Version 6 Extended Advertising Extension
            if parsable.count > 31 {
                let ruuvi = parsable.ruuviE0()
                let tag = RuuviDataE0_F0(
                    uuid: uuid,
                    serviceUUID: serviceUUID.first,
                    rssi: rssi,
                    isConnectable: isConnectable,
                    version: Int(version),
                    humidity: ruuvi.humidity,
                    temperature: ruuvi.temperature,
                    pressure: ruuvi.pressure,
                    pm1: ruuvi.pm1,
                    pm2_5: ruuvi.pm2_5,
                    pm4: ruuvi.pm4,
                    pm10: ruuvi.pm10,
                    co2: ruuvi.co2,
                    voc: ruuvi.voc,
                    nox: ruuvi.nox,
                    luminance: ruuvi.luminance,
                    dbaAvg: ruuvi.dbaAvg,
                    dbaPeak: ruuvi.dbaPeak,
                    sequence: ruuvi.measurementSequenceNumber,
                    voltage: ruuvi.voltage,
                    mac: ruuvi.mac
                )
                return .ruuvi(.tag(.nE0_F0(tag)))
            }
            return nil
        case 0xC5: // Handle version C5
            guard parsable.count > 19 else { return nil }
            let ruuvi = parsable.ruuviC5()
            let tag = RuuviDataC5(
                uuid: uuid,
                serviceUUID: serviceUUID.first,
                rssi: rssi,
                isConnectable: isConnectable,
                version: Int(
                    version
                ),
                humidity: ruuvi.humidity,
                temperature: ruuvi.temperature, 
                pressure: ruuvi.pressure,
                voltage: ruuvi.voltage,
                movementCounter: ruuvi.movementCounter,
                measurementSequenceNumber: ruuvi.measurementSequenceNumber,
                txPower: ruuvi.txPower,
                mac: ruuvi.mac
            )
            return .ruuvi(.tag(.nC5(tag)))
        default:
            return nil
        }
    }

    public func decodeHeartbeat(uuid: String, data: Data?) -> BTDevice? {
        guard let data = data else { return nil }
        guard data.count > 16 else { return nil }
        let isConnectable = true
        let version = Int(data[0])
        switch version {
        case 5: // Handle version 5
            let ruuvi = data.ruuviHeartbeat5()
            let tag = RuuviHeartbeat5(
                uuid: uuid,
                isConnectable: isConnectable,
                version: Int(
                    version
                ),
                humidity: ruuvi.humidity,
                temperature: ruuvi.temperature,
                pressure: ruuvi.pressure,
                accelerationX: ruuvi.accelerationX,
                accelerationY: ruuvi.accelerationY,
                accelerationZ: ruuvi.accelerationZ,
                voltage: ruuvi.voltage,
                movementCounter: ruuvi.movementCounter,
                measurementSequenceNumber: ruuvi.measurementSequenceNumber,
                txPower: ruuvi.txPower
            )
            return .ruuvi(.tag(.h5(tag)))
        case 0xC5:  // Handle version C5
            let ruuvi = data.ruuviHeartbeatC5()
            let tag = RuuviHeartbeatC5(
                uuid: uuid,
                isConnectable: isConnectable,
                version: Int(version),
                humidity: ruuvi.humidity,
                temperature: ruuvi.temperature,
                pressure: ruuvi.pressure,
                voltage: ruuvi.voltage,
                movementCounter: ruuvi.movementCounter,
                measurementSequenceNumber: ruuvi.measurementSequenceNumber,
                txPower: ruuvi.txPower
            )
            return .ruuvi(.tag(.hC5(tag)))

        default:
            return nil
        }
    }

    public func decodeAdvertisement(
        uuid: String,
        rssi: NSNumber,
        advertisementData: [String: Any],
        supportsExtendedAdv: Bool
    ) -> BTDevice? {
        if let manufacturerDictionary = advertisementData[CBAdvertisementDataServiceDataKey] as? [NSObject: AnyObject],
            let manufacturerData = manufacturerDictionary.first?.value as? Data {
            guard manufacturerData.count > 18 else { return nil }
            guard let url = String(data: manufacturerData[3 ... manufacturerData.count - 1], encoding: .utf8) else { return nil}
            guard url.starts(with: Ruuvi.eddystone) else { return nil }
            var urlData = url.replacingOccurrences(of: Ruuvi.eddystone, with: "")
            urlData = urlData.padding(toLength: ((urlData.count+3)/4)*4,
                                      withPad: "AAA",
                                      startingAt: 0)
            guard let data = Data(base64Encoded: urlData) else { return nil }
            let version = Int(data[0])
            let isConnectable = (advertisementData[CBAdvertisementDataIsConnectable] as? NSNumber)?.boolValue ?? false
            switch version {
            case 2:
                let ruuvi = data.ruuvi2()
                let tag = RuuviData2(uuid: uuid, rssi: rssi.intValue, isConnectable: isConnectable, version: ruuvi.version, temperature: ruuvi.temperature, humidity: ruuvi.humidity, pressure: ruuvi.pressure)
                return .ruuvi(.tag(.v2(tag)))
            case 4:
                let ruuvi = data.ruuvi4()
                let tag = RuuviData4(uuid: uuid, rssi: rssi.intValue, isConnectable: isConnectable, version: ruuvi.version, temperature: ruuvi.temperature, humidity: ruuvi.humidity, pressure: ruuvi.pressure)
                return .ruuvi(.tag(.v4(tag)))
            default:
                return nil
            }
        } else if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            guard manufacturerData.count > 2 else { return nil }
            let manufactureId = UInt16(manufacturerData[0]) + UInt16(manufacturerData[1]) << 8
            guard manufactureId == Ruuvi.vendorId else { return nil }
            let version = manufacturerData[2]
            let isConnectable = (advertisementData[CBAdvertisementDataIsConnectable] as? NSNumber)?.boolValue ?? false
            let serviceUUID = extract16ByteServiceUUID(from: advertisementData)

            switch version {
            case 3:  // Handle version 3
                guard manufacturerData.count > 14 else { return nil }
                let ruuvi = manufacturerData.ruuvi3()
                let tag = RuuviData3(
                    uuid: uuid,
                    rssi: rssi.intValue,
                    isConnectable: isConnectable,
                    version: Int(
                        version
                    ),
                    humidity: ruuvi.humidity,
                    temperature: ruuvi.temperature,
                    pressure: ruuvi.pressure,
                    accelerationX: ruuvi.accelerationX,
                    accelerationY: ruuvi.accelerationY,
                    accelerationZ: ruuvi.accelerationZ,
                    voltage: ruuvi.voltage
                )
                return .ruuvi(.tag(.v3(tag)))

            case 5:  // Handle version 5
                guard manufacturerData.count > 25 else { return nil }
                let ruuvi = manufacturerData.ruuvi5()
                let tag = RuuviData5(
                    uuid: uuid,
                    rssi: rssi.intValue,
                    isConnectable: isConnectable,
                    version: Int(
                        version
                    ),
                    humidity: ruuvi.humidity,
                    temperature: ruuvi.temperature,
                    pressure: ruuvi.pressure,
                    accelerationX: ruuvi.accelerationX,
                    accelerationY: ruuvi.accelerationY,
                    accelerationZ: ruuvi.accelerationZ,
                    voltage: ruuvi.voltage,
                    movementCounter: ruuvi.movementCounter,
                    measurementSequenceNumber: ruuvi.measurementSequenceNumber,
                    txPower: ruuvi.txPower,
                    mac: ruuvi.mac
                )
                return .ruuvi(.tag(.v5(tag)))

            case 0xE0: // // Handle E0(Advertising Extension)

                if supportsExtendedAdv && manufacturerData.count > 31 {
                    let ruuvi = manufacturerData.ruuviE0()
                    let tag = RuuviDataE0_F0(
                        uuid: uuid,
                        serviceUUID: serviceUUID,
                        rssi: rssi.intValue,
                        isConnectable: isConnectable,
                        version: Int(version),
                        humidity: ruuvi.humidity,
                        temperature: ruuvi.temperature,
                        pressure: ruuvi.pressure,
                        pm1: ruuvi.pm1,
                        pm2_5: ruuvi.pm2_5,
                        pm4: ruuvi.pm4,
                        pm10: ruuvi.pm10,
                        co2: ruuvi.co2,
                        voc: ruuvi.voc,
                        nox: ruuvi.nox,
                        luminance: ruuvi.luminance,
                        dbaAvg: ruuvi.dbaAvg,
                        dbaPeak: ruuvi.dbaPeak,
                        sequence: ruuvi.measurementSequenceNumber,
                        voltage: ruuvi.voltage,
                        mac: ruuvi.mac
                    )
                    return .ruuvi(.tag(.vE0_F0(tag)))
                }

                return nil

            case 0xF0: // Handle F0(Legacy Advertisement)
                if supportsExtendedAdv {
                    return nil
                }
                if manufacturerData.count > 19 {
                    let ruuvi = manufacturerData.ruuviF0()
                    let tag = RuuviDataE0_F0(
                        uuid: uuid,
                        serviceUUID: serviceUUID,
                        rssi: rssi.intValue,
                        isConnectable: isConnectable,
                        version: Int(version),
                        humidity: ruuvi.humidity,
                        temperature: ruuvi.temperature,
                        pressure: ruuvi.pressure,
                        pm1: ruuvi.pm1,
                        pm2_5: ruuvi.pm2_5,
                        pm4: ruuvi.pm4,
                        pm10: ruuvi.pm10,
                        co2: ruuvi.co2,
                        voc: ruuvi.voc,
                        nox: ruuvi.nox,
                        luminance: ruuvi.luminance,
                        dbaAvg: ruuvi.dbaAvg,
                        mac: ruuvi.mac
                    )
                    return .ruuvi(.tag(.vE0_F0(tag)))
                }
                return nil

            case 0xC5:  // Handle version C5
                guard manufacturerData.count > 19 else { return nil }
                let ruuvi = manufacturerData.ruuviC5()
                let tag = RuuviDataC5(
                    uuid: uuid,
                    serviceUUID: serviceUUID,
                    rssi: rssi.intValue,
                    isConnectable: isConnectable,
                    version: Int(version),
                    humidity: ruuvi.humidity,
                    temperature: ruuvi.temperature,
                    pressure: ruuvi.pressure,
                    voltage: ruuvi.voltage,
                    movementCounter: ruuvi.movementCounter,
                    measurementSequenceNumber: ruuvi.measurementSequenceNumber,
                    txPower: ruuvi.txPower,
                    mac: ruuvi.mac
                )
                return .ruuvi(.tag(.vC5(tag)))

            default:
                return nil
            }
        } else {
            return nil
        }
    }
}

// MARK: Private helpers
extension RuuviDecoderiOS {
    private func extract16ByteServiceUUID(from advertisementData: [String: Any]) -> String? {
        // Retrieve the service UUIDs from the advertisement data
        if let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            for uuid in serviceUUIDs {
                // Return the one with 2 byte
                if uuid.data.count == 2 {
                    return uuid.uuidString
                }
            }
        }
        // Return nil if no 2-byte UUID is found
        return nil
    }

    func extractAdvertisementData(
        from data: Data
    ) -> (
        serviceUUIDs: [String],
        manufacturerData: Data?,
        version: UInt8?
    ) {
        var index = 0
        var serviceUUIDs: [String] = []
        var manufacturerData: Data?
        var version: UInt8?

        while index < data.count {
            // Ensure there's at least one byte left for the length
            let remainingBytes = data.count - index
            guard remainingBytes >= 1 else {
                break
            }

            // Get the length of the AD structure
            let length = Int(data[index])
            index += 1

            // Length must be at least 1 (for the AD type)
            if length == 0 {
                continue
            }

            // Ensure there are enough bytes left for type and data
            guard index + length - 1 <= data.count else {
                break
            }

            // Get the AD type
            let adType = data[index]
            index += 1

            // Extract the AD data
            let adDataLength = length - 1
            let adDataRange = index..<(index + adDataLength)
            let adData = data.subdata(in: adDataRange)

            // Process the AD structure based on its type
            switch adType {
            case 0x02, 0x03: // 16-bit Service UUIDs
                var uuidIndex = 0
                while uuidIndex + 1 < adData.count {
                    // UUIDs are in little-endian format
                    let uuidBytes = adData.subdata(in: uuidIndex..<(uuidIndex + 2))
                    let uuid = String(format: "%02X%02X", uuidBytes[1], uuidBytes[0])
                    serviceUUIDs.append(uuid)
                    uuidIndex += 2
                }
            case 0x06, 0x07: // 128-bit Service UUIDs
                var uuidIndex = 0
                while uuidIndex + 15 < adData.count {
                    // UUIDs are in little-endian format
                    let uuidBytes = adData.subdata(in: uuidIndex..<(uuidIndex + 16))
                    let uuid = uuidBytes.reversed().map { String(format: "%02X", $0) }.joined()
                    serviceUUIDs.append(uuid)
                    uuidIndex += 16
                }
            case 0xFF: // Manufacturer Specific Data
                manufacturerData = adData
                // Extract the version number (data format)
                if adData.count >= 3 {
                    version = adData[2]
                }
            default:
                break
            }

            // Move to the next AD structure
            index += adDataLength
        }

        return (serviceUUIDs, manufacturerData, version)
    }
}

extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var index = hexString.startIndex

        for _ in 0..<len {
            let nextIndex = hexString.index(index, offsetBy: 2)
            guard nextIndex <= hexString.endIndex else { return nil }
            let bytes = hexString[index..<nextIndex]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            index = nextIndex
        }
        self = data
    }
}
