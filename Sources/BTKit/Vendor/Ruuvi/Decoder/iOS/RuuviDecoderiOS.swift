import CoreBluetooth

public struct RuuviDecoderiOS: BTDecoder {

    public init() {
    }

    public func decodeNetwork(uuid: String, rssi: Int, isConnectable: Bool, payload: String) -> BTDevice? {
        guard let data = payload.hex else { return nil }
        guard data.count > 18 else { return nil }

        var offsetAdjustment = 0
        var serviceUUID: String?

        // Check if the service UUID is present
        if data.count > 6, data[3] == 0x03, data[4] == 0x02 {
            // Service UUID is present
            offsetAdjustment = 4 // The service UUID AD structure is 4 bytes long
            // Extract the service UUID (optional)
            serviceUUID = data[5...6].map { String(format: "%02X", $0) }.joined()
        }

        let versionOffset = 7 + offsetAdjustment
        guard data.count > versionOffset else { return nil }
        let version = Int(data[versionOffset])

        let parsableOffset = 5 + offsetAdjustment
        guard data.count > parsableOffset else { return nil }
        let parsable = Data(data[parsableOffset...data.count - 1])

        switch version {
        case 2: // Handle version 2
            guard parsable.count > 5 else { return nil }
            let ruuvi = parsable.ruuvi2()
            let tag = RuuviData2(uuid: uuid, rssi: rssi, isConnectable: isConnectable, version: ruuvi.version, temperature: ruuvi.temperature, humidity: ruuvi.humidity, pressure: ruuvi.pressure)
            return .ruuvi(.tag(.n2(tag)))
        case 3: // Handle version 3
            guard parsable.count > 15 else { return nil }
            let ruuvi = parsable.ruuvi3()
            let tag = RuuviData3(uuid: uuid, rssi: rssi, isConnectable: isConnectable, version: Int(version), humidity: ruuvi.humidity, temperature: ruuvi.temperature, pressure: ruuvi.pressure, accelerationX: ruuvi.accelerationX, accelerationY: ruuvi.accelerationY, accelerationZ: ruuvi.accelerationZ, voltage: ruuvi.voltage)
            return .ruuvi(.tag(.n3(tag)))
        case 4: // Handle version 4
            guard parsable.count > 5 else { return nil }
            let ruuvi = parsable.ruuvi4()
            let tag = RuuviData4(uuid: uuid, rssi: rssi, isConnectable: isConnectable, version: ruuvi.version, temperature: ruuvi.temperature, humidity: ruuvi.humidity, pressure: ruuvi.pressure)
            return .ruuvi(.tag(.n4(tag)))
        case 5: // Handle version 5
            guard parsable.count > 19 else { return nil }
            let ruuvi = parsable.ruuvi5()
            let tag = RuuviData5(uuid: uuid, rssi: rssi, isConnectable: isConnectable, version: Int(version), humidity: ruuvi.humidity, temperature: ruuvi.temperature, pressure: ruuvi.pressure, accelerationX: ruuvi.accelerationX, accelerationY: ruuvi.accelerationY, accelerationZ: ruuvi.accelerationZ, voltage: ruuvi.voltage, movementCounter: ruuvi.movementCounter, measurementSequenceNumber: ruuvi.measurementSequenceNumber, txPower: ruuvi.txPower, mac: ruuvi.mac)
            return .ruuvi(.tag(.n5(tag)))
        case 197: // Handle version C5
            guard parsable.count > 19 else { return nil }
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

            case 197:  // Handle version C5
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
