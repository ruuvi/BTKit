import CoreBluetooth

public class RuuviDecoderiOS: BTDecoder {

    private let deviceRegistry = RuuviDeviceRegistry()

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
        case 0xE0: // Handle E0
            let ruuvi = data.ruuviHeartbeatE0()
            let tag = RuuviHeartbeatE0_F0(
                uuid: uuid,
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
                measurementSequenceNumber: ruuvi.measurementSequenceNumber,
                voltage: ruuvi.voltage
            )
            return .ruuvi(.tag(.hE0_F0(tag)))
        default:
            return nil
        }
    }

    public func decodeAdvertisement(
        uuid: String,
        rssi: NSNumber,
        advertisementData: [String: Any],
        isConnected: Bool,
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

            case 0xE0: // Handle E0(Advertising Extension)
                if supportsExtendedAdv && manufacturerData.count > 31 {
                    let ruuvi = manufacturerData.ruuviE0()

                    // Check if we have a legacy UUID for this MAC
                    if let deviceUUID = deviceRegistry.getLegacyUUID(for: ruuvi.mac) {
                        let tag = RuuviDataE0_F0(
                            uuid: deviceUUID,
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
                }
                return nil
            case 0xF0: // Handle F0(Legacy Advertisement)

                if manufacturerData.count > 19 && manufacturerData.count < 31 {
                    let ruuvi = manufacturerData.ruuviF0()
                    deviceRegistry.registerLegacyUUID(mac: ruuvi.mac, uuid: uuid)
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
                        mac: ruuvi.mac
                    )

                    return !supportsExtendedAdv ? .ruuvi(.tag(.vE0_F0(tag))) : nil

                } else if manufacturerData.count > 31 {
                    // Merged Legacy + Extended advertisement:
                    // The same manufacturerData block contains F0 portion + E0 portion.
                    // Therefore we will split the data into two parts and return them based on device
                    // extended adv scan capabilities.

                    // First 22 bytes => F0 data
                    let f0Length = 22
                    let f0Data = manufacturerData.prefix(f0Length)
                    let ruuviF0 = f0Data.ruuviF0()

                    let tagF0 = RuuviDataE0_F0(
                        uuid: uuid,
                        serviceUUID: serviceUUID,
                        rssi: rssi.intValue,
                        isConnectable: isConnectable && !isConnected,
                        version: Int(version),
                        humidity: ruuviF0.humidity,
                        temperature: ruuviF0.temperature,
                        pressure: ruuviF0.pressure,
                        pm1: ruuviF0.pm1,
                        pm2_5: ruuviF0.pm2_5,
                        pm4: ruuviF0.pm4,
                        pm10: ruuviF0.pm10,
                        co2: ruuviF0.co2,
                        voc: ruuviF0.voc,
                        nox: ruuviF0.nox,
                        luminance: ruuviF0.luminance,
                        dbaAvg: ruuviF0.dbaAvg,
                        dbaPeak: ruuviF0.dbaPeak,
                        sequence: ruuviF0.measurementSequenceNumber,
                        mac: ruuviF0.mac
                    )
                    deviceRegistry.registerLegacyUUID(mac: tagF0.mac, uuid: uuid)

                    // Remaining data => E0 portion
                    let e0Data = manufacturerData.subdata(in: f0Length..<manufacturerData.count)

                    // If E0 portion is invalid, fallback to returning F0
                    if e0Data.count <= 31 && !supportsExtendedAdv {
                        return .ruuvi(.tag(.vE0_F0(tagF0)))
                    }

                    // Build "completeE0Data" by reusing the 2-byte (0x99, 0x04) header
                    var completeE0Data = Data()
                    // Add the 2-byte header from the original manufacturerData
                    // We need this to build the complete E0 data that will be used to
                    // pass to the ruuviE0() method which requires the header.
                    completeE0Data.append(manufacturerData.prefix(2))
                    // Then append the leftover E0 bytes
                    completeE0Data.append(e0Data)

                    let ruuviE0 = completeE0Data.ruuviE0()
                    let tagE0 = RuuviDataE0_F0(
                        uuid: uuid,
                        serviceUUID: serviceUUID,
                        rssi: rssi.intValue,
                        isConnectable: isConnectable && !isConnected,
                        version: Int(e0Data[0]), // read from E0 portion
                        humidity: ruuviE0.humidity,
                        temperature: ruuviE0.temperature,
                        pressure: ruuviE0.pressure,
                        pm1: ruuviE0.pm1,
                        pm2_5: ruuviE0.pm2_5,
                        pm4: ruuviE0.pm4,
                        pm10: ruuviE0.pm10,
                        co2: ruuviE0.co2,
                        voc: ruuviE0.voc,
                        nox: ruuviE0.nox,
                        luminance: ruuviE0.luminance,
                        dbaAvg: ruuviE0.dbaAvg,
                        dbaPeak: ruuviE0.dbaPeak,
                        sequence: ruuviE0.measurementSequenceNumber,
                        voltage: ruuviE0.voltage,
                        mac: ruuviE0.mac
                    )

                    if supportsExtendedAdv && !isConnected {
                        return .ruuvi(.tag(.vE0_F0(tagE0)))
                    } else {
                        return .ruuvi(.tag(.vE0_F0(tagF0)))
                    }
                }

                // Otherwise, no recognized data
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

class RuuviDeviceRegistry {
    // Map from MAC address to the UUID from legacy (F0) advertisements
    private var macToLegacyUUID: [String: String] = [:]

    // Store the F0 UUID for a given MAC address
    func registerLegacyUUID(mac: String, uuid: String) {
        macToLegacyUUID[mac] = uuid
    }

    // Get the F0 UUID for a given MAC address
    func getLegacyUUID(for mac: String) -> String? {
        return macToLegacyUUID[mac]
    }

    // Check if we have a registered F0 UUID for this MAC
    func hasLegacyUUID(for mac: String) -> Bool {
        return macToLegacyUUID[mac] != nil
    }
}
