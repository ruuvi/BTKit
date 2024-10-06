import CoreBluetooth

public struct RuuviDecoderiOS: BTDecoder {

    public init() {
    }

    public func decodeNetwork(uuid: String, rssi: Int, isConnectable: Bool, payload: String) -> BTDevice? {
        guard let data = payload.hex else { return nil }
        var offset = 0
        var version: UInt8?
        var parsable: Data?
        var serviceUUID: String?

        // Parse the advertising data into AD structures
        while offset < data.count {
            // Each AD structure starts with a length byte
            let length = Int(data[offset])
            offset += 1

            // Check if length is valid
            guard length > 0, offset + length - 1 < data.count else {
                break
            }

            // Type byte
            let type = data[offset]
            offset += 1

            // Value bytes
            let valueLength = length - 1
            let valueStart = offset
            let valueEnd = offset + valueLength
            let valueData = data[valueStart..<valueEnd]
            offset += valueLength

            switch type {
            case 0xFF:
                // Manufacturer Specific Data
                // Company Identifier (2 bytes), then data
                // At least 3 bytes: 2 bytes company ID + 1 byte data format
                guard valueLength >= 3 else { continue }
                let companyID = (UInt16(valueData[valueData.startIndex + 1]) << 8) | UInt16(valueData[valueData.startIndex])
                // Check if companyID matches Ruuvi (0x0499)
                if companyID == 0x0499 {
                    // Data format version is the next byte
                    version = valueData[valueData.startIndex + 2]
                    // Skip company ID (2 bytes) and version (1 byte)
                    parsable = valueData.dropFirst(3)
                }
            case 0x16: 
                // Service Data - 16-bit UUID
                // Service UUID (2 bytes), then data
                guard valueLength >= 3 else { continue }
                let uuidBytes = valueData[valueData.startIndex..<valueData.startIndex+2]
                serviceUUID = uuidBytes.map { String(format: "%02X", $0) }.joined()
                // Data format version is the next byte
                version = valueData[valueData.startIndex + 2]
                // Skip service UUID (2 bytes) and version (1 byte)
                parsable = valueData.dropFirst(3)
            default:
                continue
            }

            // If we've found the version and parsable data, no need to continue parsing
            if version != nil && parsable != nil {
                break
            }
        }

        // Ensure we have the necessary data to proceed
        guard let version = version, let parsable = parsable else {
            return nil
        }

        print("OMA: ", version)

        switch version {
        case 2:
            guard parsable.count > 5 else { return nil }
            let ruuvi = parsable.ruuvi2()
            let tag = RuuviData2(uuid: uuid, rssi: rssi, isConnectable: isConnectable, version: ruuvi.version, temperature: ruuvi.temperature, humidity: ruuvi.humidity, pressure: ruuvi.pressure)
            return .ruuvi(.tag(.n2(tag)))
        case 3:
            guard parsable.count > 15 else { return nil }
            let ruuvi = parsable.ruuvi3()
            let tag = RuuviData3(uuid: uuid, rssi: rssi, isConnectable: isConnectable, version: Int(version), humidity: ruuvi.humidity, temperature: ruuvi.temperature, pressure: ruuvi.pressure, accelerationX: ruuvi.accelerationX, accelerationY: ruuvi.accelerationY, accelerationZ: ruuvi.accelerationZ, voltage: ruuvi.voltage)
            return .ruuvi(.tag(.n3(tag)))
        case 4:
            guard parsable.count > 5 else { return nil }
            let ruuvi = parsable.ruuvi4()
            let tag = RuuviData4(uuid: uuid, rssi: rssi, isConnectable: isConnectable, version: ruuvi.version, temperature: ruuvi.temperature, humidity: ruuvi.humidity, pressure: ruuvi.pressure)
            return .ruuvi(.tag(.n4(tag)))
        case 5:
            guard parsable.count > 19 else { return nil }
            let ruuvi = parsable.ruuvi5()
            let tag = RuuviData5(uuid: uuid, rssi: rssi, isConnectable: isConnectable, version: Int(version), humidity: ruuvi.humidity, temperature: ruuvi.temperature, pressure: ruuvi.pressure, accelerationX: ruuvi.accelerationX, accelerationY: ruuvi.accelerationY, accelerationZ: ruuvi.accelerationZ, voltage: ruuvi.voltage, movementCounter: ruuvi.movementCounter, measurementSequenceNumber: ruuvi.measurementSequenceNumber, txPower: ruuvi.txPower, mac: ruuvi.mac)
            return .ruuvi(.tag(.n5(tag)))
        case 197:
            print("DEKHI: ")
            dump(data)
            guard parsable.count > 19 else { return nil }
//            let serviceUUID = extract16ByteServiceUUID(from: parsable)
            let ruuvi = parsable.ruuviC5()
            let tag = RuuviDataC5(
                uuid: uuid,
                serviceUUID: serviceUUID,
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
            print("BALDA: ", tag)
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
        case 5: // Handle version C5
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
        case 197:  // Handle version C5
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

    public func decodeAdvertisement(uuid: String, rssi: NSNumber, advertisementData: [String: Any]) -> BTDevice? {
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
                let tag = RuuviData3(uuid: uuid, rssi: rssi.intValue, isConnectable: isConnectable, version: Int(version), humidity: ruuvi.humidity, temperature: ruuvi.temperature, pressure: ruuvi.pressure, accelerationX: ruuvi.accelerationX, accelerationY: ruuvi.accelerationY, accelerationZ: ruuvi.accelerationZ, voltage: ruuvi.voltage)
                return .ruuvi(.tag(.v3(tag)))

            case 5:  // Handle version 5
                print("BALCHAL AGAIN: ")
                dump(advertisementData)
                guard manufacturerData.count > 25 else { return nil }
                let ruuvi = manufacturerData.ruuvi5()
                let tag = RuuviData5(uuid: uuid, rssi: rssi.intValue, isConnectable: isConnectable, version: Int(version), humidity: ruuvi.humidity, temperature: ruuvi.temperature, pressure: ruuvi.pressure, accelerationX: ruuvi.accelerationX, accelerationY: ruuvi.accelerationY, accelerationZ: ruuvi.accelerationZ, voltage: ruuvi.voltage, movementCounter: ruuvi.movementCounter, measurementSequenceNumber: ruuvi.measurementSequenceNumber, txPower: ruuvi.txPower, mac: ruuvi.mac)
                return .ruuvi(.tag(.v5(tag)))
            case 254:
                // Legacy
                if manufacturerData.count > 19 && manufacturerData.count <= 31 {
                    let ruuvi = manufacturerData.ruuvi6Legacy()
                    let tag = RuuviData6(
                        uuid: uuid,
                        serviceUUID: serviceUUID,
                        rssi: rssi.intValue,
                        isConnectable: isConnectable,
                        version: Int(version),
                        humidity: ruuvi.humidity,
                        temperature: ruuvi.temperature,
                        pressure: ruuvi.pressure,
                        pm1_0: ruuvi.pm1_0,
                        pm2_5: ruuvi.pm2_5,
                        pm4_0: ruuvi.pm4_0,
                        pm10: ruuvi.pm10,
                        co2: ruuvi.co2,
                        nox: ruuvi.nox,
                        dbaAvg: ruuvi.dbaAvg,
                        mac: ruuvi.mac
                    )
                    return .ruuvi(.tag(.v6(tag)))
                } else if manufacturerData.count > 31 { // Advertising extension
                    let ruuvi = manufacturerData.ruuvi6AdvertisingExtension()
                    let tag = RuuviData6(
                        uuid: uuid,
                        serviceUUID: serviceUUID,
                        rssi: rssi.intValue,
                        isConnectable: isConnectable,
                        version: Int(version),
                        humidity: ruuvi.humidity,
                        temperature: ruuvi.temperature,
                        pressure: ruuvi.pressure,
                        pm1_0: ruuvi.pm1_0,
                        pm2_5: ruuvi.pm2_5,
                        pm4_0: ruuvi.pm4_0,
                        pm10: ruuvi.pm10,
                        co2: ruuvi.co2,
                        nox: ruuvi.nox,
                        dbaAvg: ruuvi.dbaAvg,
                        dbaPeak: ruuvi.dbaPeak,
                        voltage: ruuvi.voltage,
                        mac: ruuvi.mac
                    )
                    return .ruuvi(.tag(.v6(tag)))
                }

                return nil

            case 197:  // Handle version C5
                guard manufacturerData.count > 19 else { return nil }
                print("BALCHAL: ")
                dump(advertisementData)
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

// MARK: Privaye
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
}
