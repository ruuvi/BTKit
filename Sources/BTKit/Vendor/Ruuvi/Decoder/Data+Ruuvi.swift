import Foundation

public extension Ruuvi {
    struct Data2 {
        public var version: Int
        public var humidity: Double
        public var temperature: Double
        public var pressure: Double
    }

    struct Data3 {
        public var humidity: Double
        public var temperature: Double
        public var pressure: Double
        public var accelerationX: Double
        public var accelerationY: Double
        public var accelerationZ: Double
        public var voltage: Double
    }

    struct Data4 {
        public var version: Int
        public var humidity: Double
        public var temperature: Double
        public var pressure: Double
    }

    struct Data5 {
        public var humidity: Double?
        public var temperature: Double?
        public var pressure: Double?
        public var accelerationX: Double?
        public var accelerationY: Double?
        public var accelerationZ: Double?
        public var movementCounter: Int?
        public var measurementSequenceNumber: Int?
        public var voltage: Double?
        public var txPower: Int?
        public var mac: String
    }

    struct DataE1_V6 {
        public var humidity: Double?
        public var temperature: Double?
        public var pressure: Double?
        public var pm1: Double? // N/A in V6
        public var pm25: Double?
        public var pm4: Double? // N/A in V6
        public var pm10: Double? // N/A in V6
        public var co2: Double?
        public var voc: Double?
        public var nox: Double?
        public var luminance: Double?
        public var dbaInstant: Double? // N/A in V6
        public var dbaAvg: Double?
        public var dbaPeak: Double? // N/A in V6
        public var measurementSequenceNumber: Int?
        public var mac: String // 3byte in V6
    }

    struct DataC5 {
        public var humidity: Double?
        public var temperature: Double?
        public var pressure: Double?
        public var movementCounter: Int?
        public var measurementSequenceNumber: Int?
        public var voltage: Double?
        public var txPower: Int?
        public var mac: String
    }

    struct Heartbeat5 {
        public var humidity: Double?
        public var temperature: Double?
        public var pressure: Double?
        public var accelerationX: Double?
        public var accelerationY: Double?
        public var accelerationZ: Double?
        public var movementCounter: Int?
        public var measurementSequenceNumber: Int?
        public var voltage: Double?
        public var txPower: Int?
    }

    struct HeartbeatC5 {
        public var humidity: Double?
        public var temperature: Double?
        public var pressure: Double?
        public var movementCounter: Int?
        public var measurementSequenceNumber: Int?
        public var voltage: Double?
        public var txPower: Int?
    }

    struct HeartbeatE1_V6 {
        public var humidity: Double?
        public var temperature: Double?
        public var pressure: Double?
        public var pm1: Double?
        public var pm25: Double?
        public var pm4: Double?
        public var pm10: Double?
        public var co2: Double?
        public var voc: Double?
        public var nox: Double?
        public var luminance: Double?
        public var dbaInstant: Double?
        public var dbaAvg: Double?
        public var dbaPeak: Double?
        public var measurementSequenceNumber: Int?
    }
}

public extension Data {

    func ruuvi2() -> Ruuvi.Data2 {
        let version = Int(self[0])
        let humidity = ((Double) (self[1] & 0xFF)) / 2.0
        let uTemp = Double((UInt16(self[2] & 127) << 8) | UInt16(self[3]))
        let tempSign = UInt16(self[2] >> 7) & UInt16(1)
        let temperature = tempSign == 0 ? uTemp / 256.0 : -1.00 * uTemp / 256.0
        let pressure = (Double(((UInt16(self[4]) << 8) + UInt16(self[5]))) + 50000) / 100.0
        return Ruuvi.Data2(version: version, humidity: humidity, temperature: temperature, pressure: pressure)
    }

    func ruuvi3() -> Ruuvi.Data3 {
        let humidity = Double(self[3]) * 0.5

        let temperatureSign = (self[4] >> 7) & 1
        let temperatureBase = self[4] & 0x7F
        let temperatureFraction = Double(self[5]) / 100.0
        var temperature = Double(temperatureBase) + temperatureFraction
        if temperatureSign == 1 {
            temperature *= -1
        }

        let pressureHi = self[6] & 0xFF
        let pressureLo = self[7] & 0xFF
        let pressure = (Double(pressureHi) * 256.0 + 50000.0 + Double(pressureLo)) / 100.0

        let accelerationX = Double(self[8...9].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first ?? 0) / 1000.0
        let accelerationY = Double(self[10...11].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first ?? 0) / 1000.0
        let accelerationZ = Double(self[12...13].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first ?? 0) / 1000.0

        let battHi = self[14] & 0xFF
        let battLo = self[15] & 0xFF
        let voltage = (Double(battHi) * 256.0 + Double(battLo)) / 1000.0
        return Ruuvi.Data3(humidity: humidity, temperature: temperature, pressure: pressure, accelerationX: accelerationX, accelerationY: accelerationY, accelerationZ: accelerationZ, voltage: voltage)
    }

    func ruuvi4() -> Ruuvi.Data4 {
        let version = Int(self[0])
        let humidity = ((Double) (self[1] & 0xFF)) / 2.0
        let uTemp = Double((UInt16(self[2] & 127) << 8) | UInt16(self[3]))
        let tempSign = UInt16(self[2] >> 7) & UInt16(1)
        let temperature = tempSign == 0 ? uTemp / 256.0 : -1.00 * uTemp / 256.0
        let pressure = (Double(((UInt16(self[4]) << 8) + UInt16(self[5]))) + 50000) / 100.0
        return Ruuvi.Data4(version: version, humidity: humidity, temperature: temperature, pressure: pressure)
    }

    func ruuvi5() -> Ruuvi.Data5 {

        // temperature
        var temperature: Double?
        if let t = self[3...4].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            if t == Int16.min {
                temperature = nil
            } else {
                temperature = Double(t) / 200.0
            }
        } else {
            temperature = nil
        }

        // humidity
        var humidity: Double?
        if let h = self[5...6].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if h == UInt16.max {
                humidity = nil
            } else {
                humidity = Double(h) / 400.0
            }
        } else {
            humidity = nil
        }

        // pressure
        var pressure: Double?
        if let p = self[7...8].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if p == UInt16.max {
                pressure = nil
            } else {
                pressure = (Double(p) + 50000.0) / 100.0
            }
        } else {
            pressure = nil
        }

        // accelerationX
        var accelerationX: Double?
        if let aX = self[9...10].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            if aX == Int16.min {
                accelerationX = nil
            } else {
                accelerationX = Double(aX) / 1000.0
            }
        } else {
            accelerationX = nil
        }

        // accelerationY
        var accelerationY: Double?
        if let aY = self[11...12].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            if aY == Int16.min {
                accelerationY = nil
            } else {
                accelerationY = Double(aY) / 1000.0
            }
        } else {
            accelerationY = nil
        }

        // accelerationZ
        var accelerationZ: Double?
        if let aZ = self[13...14].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            if aZ == Int16.min {
                accelerationZ = nil
            } else {
                accelerationZ = Double(aZ) / 1000.0
            }
        } else {
            accelerationZ = nil
        }

        // powerInfo
        var voltage: Double?
        var txPower: Int?
        if let powerInfo = self[15...16].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            let v = powerInfo >> 5
            if v == 0b11111111111 {
                voltage = nil
            } else {
                voltage = Double(v) / 1000.0 + 1.6
            }
            let tx = powerInfo & 0b11111
            if tx == 0b11111 {
                txPower = nil
            } else {
                txPower = Int(tx) * 2 - 40
            }
        } else {
            voltage = nil
            txPower = nil
        }

        // movementCounter
        var movementCounter: Int?
        let mc = self[17]
        if mc == UInt8.max {
            movementCounter = nil
        } else {
            movementCounter = Int(mc)
        }

        // measurementSequenceNumber
        var measurementSequenceNumber: Int?
        if let msn = self[18...19].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if msn == UInt16.max {
                measurementSequenceNumber = nil
            } else {
                measurementSequenceNumber = Int(msn)
            }
        } else {
            measurementSequenceNumber = nil
        }

        let asStr = self.hexEncodedString()
        let start = asStr.index(asStr.endIndex, offsetBy: -12)
        let mac = addColons(mac: String(asStr[start...]))
        return Ruuvi.Data5(humidity: humidity, temperature: temperature, pressure: pressure, accelerationX: accelerationX, accelerationY: accelerationY, accelerationZ: accelerationZ, movementCounter: movementCounter, measurementSequenceNumber: measurementSequenceNumber, voltage: voltage, txPower: txPower, mac: mac)
    }

    func ruuviC5() -> Ruuvi.DataC5 {

        // temperature
        var temperature: Double?
        if let t = self[3...4].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            if t == Int16.min {
                temperature = nil
            } else {
                temperature = Double(t) / 200.0
            }
        } else {
            temperature = nil
        }

        // humidity
        var humidity: Double?
        if let h = self[5...6].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if h == UInt16.max {
                humidity = nil
            } else {
                humidity = Double(h) / 400.0
            }
        } else {
            humidity = nil
        }

        // pressure
        var pressure: Double?
        if let p = self[7...8].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if p == UInt16.max {
                pressure = nil
            } else {
                pressure = (Double(p) + 50000.0) / 100.0
            }
        } else {
            pressure = nil
        }

        // powerInfo
        var voltage: Double?
        var txPower: Int?
        if let powerInfo = self[9...10].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            let v = powerInfo >> 5
            if v == 0b11111111111 {
                voltage = nil
            } else {
                voltage = Double(v) / 1000.0 + 1.6
            }
            let tx = powerInfo & 0b11111
            if tx == 0b11111 {
                txPower = nil
            } else {
                txPower = Int(tx) * 2 - 40
            }
        } else {
            voltage = nil
            txPower = nil
        }

        // movementCounter
        var movementCounter: Int?
        let mc = self[11]
        if mc == UInt8.max {
            movementCounter = nil
        } else {
            movementCounter = Int(mc)
        }

        // measurementSequenceNumber
        var measurementSequenceNumber: Int?
        if let msn = self[12...13].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if msn == UInt16.max {
                measurementSequenceNumber = nil
            } else {
                measurementSequenceNumber = Int(msn)
            }
        } else {
            measurementSequenceNumber = nil
        }

        let asStr = self.hexEncodedString()
        let start = asStr.index(asStr.endIndex, offsetBy: -12)
        let mac = addColons(mac: String(asStr[start...]))
        return Ruuvi.DataC5(
            humidity: humidity,
            temperature: temperature,
            pressure: pressure,
            movementCounter: movementCounter,
            measurementSequenceNumber: measurementSequenceNumber,
            voltage: voltage,
            txPower: txPower,
            mac: mac
        )
    }

    func ruuvi6() -> Ruuvi.DataE1_V6 {

        // Extract FLAGS byte (Byte 18)
        let flagsByte = self[18]
        let dbaAvgFlag = isBitSet(byte: flagsByte, bitIndex: 4)  // dBA AVG B9, LSB
        let vocFlag = isBitSet(byte: flagsByte, bitIndex: 6)     // VOC B9, LSB
        let noxFlag = isBitSet(byte: flagsByte, bitIndex: 7)     // NOX B9

        // Temperature (Bytes 3-4)
        var temperature: Double?
        if let t = self[3...4].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            temperature = t == Int16.min ? nil : Double(t) * 0.005
        }

        // Humidity (Bytes 5-6)
        var humidity: Double?
        if let h = self[5...6].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            humidity = h == UInt16.max ? nil : Double(h) * 0.0025
        }

        // Pressure (Bytes 7-8)
        var pressure: Double?
        if let p = self[7...8].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            pressure = p == UInt16.max ? nil : (Double(p) + 50000.0) / 100.0
        }

        // PM2.5 (Bytes 9-10)
        let pm25 = self.toUInt16(from: 9).map { $0 == UInt16.max ? nil : Double($0) * 0.1 } ?? 0

        // CO2 (Bytes 11-12)
        let co2 = self.toUInt16(from: 11).map { $0 == UInt16.max ? nil : Double($0) } ?? 0

        // VOC (UINT9: Byte 13 + FLAGS bit 6)
        var voc: Double?
        let vocBaseByte = self[13]
        if vocBaseByte == UInt8.max {
            voc = nil
        } else {
            let vocValue = (UInt16(vocBaseByte) << 1) | (vocFlag ? 1 : 0)
            voc = vocValue == 511 ? nil : Double(vocValue)
        }

        // NOX (UINT9: Byte 14 + FLAGS bit 7)
        var nox: Double?
        let noxBaseByte = self[14]
        if noxBaseByte == UInt8.max {
            nox = nil
        } else {
            let noxValue = (UInt16(noxBaseByte) << 1) | (noxFlag ? 1 : 0)
            nox = noxValue == 511 ? nil : Double(noxValue)
        }

        // Luminance (Byte 15)
        var luminance: Double?
        let lumiByte = self[15]
        if lumiByte == UInt8.max {
            luminance = nil
        } else {
            luminance = Double(lumiByte)
        }

        // dBA Avg (UINT9: Byte 16 + FLAGS bit 4)
        var dbaAvg: Double?
        let dbaBaseByte = self[16]
        if dbaBaseByte == UInt8.max {
            dbaAvg = nil
        } else {
            let dbaValue = (UInt16(dbaBaseByte) << 1) | (dbaAvgFlag ? 1 : 0)
            dbaAvg = dbaValue == 511 ? nil : (Double(dbaValue) * 0.2 + 18.0)
        }

        // Measurement Sequence Number (Byte 17)
        let measurementSequenceNumber = Int(self[17])

        // MAC Address (Last 3 bytes: Bytes 19-21)
        let macBytes = self[19...21]
        let mac = macBytes.map { String(format: "%02X", $0) }.joined(separator: ":")

        return Ruuvi.DataE1_V6(
            humidity: humidity,
            temperature: temperature,
            pressure: pressure,
            pm25: pm25, // Only PM2.5 available
            co2: co2,
            voc: voc,
            nox: nox,
            luminance: luminance,
            dbaAvg: dbaAvg,
            measurementSequenceNumber: measurementSequenceNumber,
            mac: mac
        )
    }

    func ruuviE1() -> Ruuvi.DataE1_V6 {

        // Extract FLAGS byte (Byte 30) - contains 9th bits for UINT9 values
        let flagsByte = self[30]
        let dbaInstantFlag = isBitSet(byte: flagsByte, bitIndex: 3)
        let dbaAvgFlag = isBitSet(byte: flagsByte, bitIndex: 4)
        let dbaPeakFlag = isBitSet(byte: flagsByte, bitIndex: 5)
        let vocFlag = isBitSet(byte: flagsByte, bitIndex: 6)
        let noxFlag = isBitSet(byte: flagsByte, bitIndex: 7)

        // Temperature (Bytes 3-4)
        var temperature: Double?
        if let t = self[3...4].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            temperature = t == Int16.min ? nil : Double(t) * 0.005
        }

        // Humidity (Bytes 5-6)
        var humidity: Double?
        if let h = self[5...6].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            humidity = h == UInt16.max ? nil : Double(h) * 0.0025
        }

        // Pressure (Bytes 7-8)
        var pressure: Double?
        if let p = self[7...8].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            pressure = p == UInt16.max ? nil : (Double(p) + 50000.0) / 100.0
        }

        // PM1.0 to PM10 (Bytes 9-16)
        let pm1 = self.toUInt16(from: 9).map { $0 == UInt16.max ? nil : Double($0) * 0.1 } ?? 0
        let pm25 = self.toUInt16(from: 11).map { $0 == UInt16.max ? nil : Double($0) * 0.1 } ?? 0
        let pm4 = self.toUInt16(from: 13).map { $0 == UInt16.max ? nil : Double($0) * 0.1 } ?? 0
        let pm10 = self.toUInt16(from: 15).map { $0 == UInt16.max ? nil : Double($0) * 0.1 } ?? 0

        // CO2 (Bytes 17-18)
        let co2 = self.toUInt16(from: 17).map { $0 == UInt16.max ? nil : Double($0) } ?? 0

        // VOC (UINT9: Byte 19 + FLAGS bit 6)
        let vocBaseByte = self[19]
        let vocValue = (UInt16(vocBaseByte) << 1) | (vocFlag ? 1 : 0)
        let voc = vocValue == 511 ? nil : Double(vocValue)

        // NOX (UINT9: Byte 20 + FLAGS bit 7)
        let noxBaseByte = self[20]
        let noxValue = (UInt16(noxBaseByte) << 1) | (noxFlag ? 1 : 0)
        let nox = noxValue == 511 ? nil : Double(noxValue)

        // Luminance (UINT24: Bytes 21-23)
        var luminance: Double?
        let lumiValue = (UInt32(self[21]) << 16) | (UInt32(self[22]) << 8) | UInt32(self[23])
        luminance = lumiValue == 0xFFFFFF ? nil : Double(lumiValue) * 0.01

        // dBA Instant (UINT9: Byte 24 + FLAGS bit 3)
        var dbaInstant: Double?
        let dbaInstantByte = self[24]
        let dbaInstantValue = (UInt16(dbaInstantByte) << 1) | (dbaInstantFlag ? 1 : 0)
        dbaInstant = dbaInstantValue == 511 ? nil : (Double(dbaInstantValue) * 0.2 + 18.0)

        // dBA Avg (UINT9: Byte 25 + FLAGS bit 4)
        var dbaAvg: Double?
        let dbaAvgByte = self[25]
        let dbaAvgValue = (UInt16(dbaAvgByte) << 1) | (dbaAvgFlag ? 1 : 0)
        dbaAvg = dbaAvgValue == 511 ? nil : (Double(dbaAvgValue) * 0.2 + 18.0)

        // dBA Peak (UINT9: Byte 26 + FLAGS bit 5)
        var dbaPeak: Double?
        let dbaPeakByte = self[26]
        let dbaPeakValue = (UInt16(dbaPeakByte) << 1) | (dbaPeakFlag ? 1 : 0)
        dbaPeak = dbaPeakValue == 511 ? nil : (Double(dbaPeakValue) * 0.2 + 18.0)

        // Measurement Sequence Number (UINT24: Bytes 27-29)
        var measurementSequenceNumber: Int
        let seqValue = (UInt32(self[27]) << 16) | (UInt32(self[28]) << 8) | UInt32(self[29])
        measurementSequenceNumber = seqValue == 0xFFFFFF ? 0 : Int(seqValue)

        // MAC Address (Bytes 36-41)
        let macBytes = self[36...41]
        let mac = macBytes.map { String(format: "%02X", $0) }.joined(separator: ":")

        let data = Ruuvi.DataE1_V6(
            humidity: humidity,
            temperature: temperature,
            pressure: pressure,
            pm1: pm1,
            pm25: pm25,
            pm4: pm4,
            pm10: pm10,
            co2: co2,
            voc: voc,
            nox: nox,
            luminance: luminance,
            dbaInstant: dbaInstant,
            dbaAvg: dbaAvg,
            dbaPeak: dbaPeak,
            measurementSequenceNumber: measurementSequenceNumber,
            mac: mac
        )
        return data
    }

    func ruuviHeartbeat5() -> Ruuvi.Heartbeat5 {
        // temperature
        var temperature: Double?
        if let t = self[1...2].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            if t == Int16.min {
                temperature = nil
            } else {
                temperature = Double(t) / 200.0
            }
        } else {
            temperature = nil
        }

        // humidity
        var humidity: Double?
        if let h = self[3...4].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if h == UInt16.max {
                humidity = nil
            } else {
                humidity = Double(h) / 400.0
            }
        } else {
            humidity = nil
        }

        // pressure
        var pressure: Double?
        if let p = self[5...7].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if p == UInt16.max {
                pressure = nil
            } else {
                pressure = (Double(p) + 50000.0) / 100.0
            }
        } else {
            pressure = nil
        }

        // accelerationX
        var accelerationX: Double?
        if let aX = self[7...8].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            if aX == Int16.min {
                accelerationX = nil
            } else {
                accelerationX = Double(aX) / 1000.0
            }
        } else {
            accelerationX = nil
        }

        // accelerationY
        var accelerationY: Double?
        if let aY = self[9...10].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            if aY == Int16.min {
                accelerationY = nil
            } else {
                accelerationY = Double(aY) / 1000.0
            }
        } else {
            accelerationY = nil
        }

        // accelerationZ
        var accelerationZ: Double?
        if let aZ = self[11...12].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            if aZ == Int16.min {
                accelerationZ = nil
            } else {
                accelerationZ = Double(aZ) / 1000.0
            }
        } else {
            accelerationZ = nil
        }

        // powerInfo
        var voltage: Double?
        var txPower: Int?
        if let powerInfo = self[13...14].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            let v = powerInfo >> 5
            if v == 0b11111111111 {
                voltage = nil
            } else {
                voltage = Double(v) / 1000.0 + 1.6
            }
            let tx = powerInfo & 0b11111
            if tx == 0b11111 {
                txPower = nil
            } else {
                txPower = Int(tx) * 2 - 40
            }
        } else {
            voltage = nil
            txPower = nil
        }

        // movementCounter
        var movementCounter: Int?
        let mc = self[15]
        if mc == UInt8.max {
            movementCounter = nil
        } else {
            movementCounter = Int(mc)
        }

        // measurementSequenceNumber
        var measurementSequenceNumber: Int?
        if let msn = self[16...17].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if msn == UInt16.max {
                measurementSequenceNumber = nil
            } else {
                measurementSequenceNumber = Int(msn)
            }
        } else {
            measurementSequenceNumber = nil
        }

        return Ruuvi.Heartbeat5(
            humidity: humidity,
            temperature: temperature,
            pressure: pressure,
            accelerationX: accelerationX,
            accelerationY: accelerationY,
            accelerationZ: accelerationZ,
            movementCounter: movementCounter,
            measurementSequenceNumber: measurementSequenceNumber,
            voltage: voltage,
            txPower: txPower
        )
    }

    func ruuviHeartbeatC5() -> Ruuvi.HeartbeatC5 {
        // temperature
        var temperature: Double?
        if let t = self[1...2].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            if t == Int16.min {
                temperature = nil
            } else {
                temperature = Double(t) / 200.0
            }
        } else {
            temperature = nil
        }

        // humidity
        var humidity: Double?
        if let h = self[3...4].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if h == UInt16.max {
                humidity = nil
            } else {
                humidity = Double(h) / 400.0
            }
        } else {
            humidity = nil
        }

        // pressure
        var pressure: Double?
        if let p = self[5...6].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if p == UInt16.max {
                pressure = nil
            } else {
                pressure = (Double(p) + 50000.0) / 100.0
            }
        } else {
            pressure = nil
        }

        // powerInfo
        var voltage: Double?
        var txPower: Int?
        if let powerInfo = self[7...8].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            let v = powerInfo >> 5
            if v == 0b11111111111 {
                voltage = nil
            } else {
                voltage = Double(v) / 1000.0 + 1.6
            }
            let tx = powerInfo & 0b11111
            if tx == 0b11111 {
                txPower = nil
            } else {
                txPower = Int(tx) * 2 - 40
            }
        } else {
            voltage = nil
            txPower = nil
        }

        // movementCounter
        var movementCounter: Int?
        let mc = self[9]
        if mc == UInt8.max {
            movementCounter = nil
        } else {
            movementCounter = Int(mc)
        }

        // measurementSequenceNumber
        var measurementSequenceNumber: Int?
        if let msn = self[10...11].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if msn == UInt16.max {
                measurementSequenceNumber = nil
            } else {
                measurementSequenceNumber = Int(msn)
            }
        } else {
            measurementSequenceNumber = nil
        }

        return Ruuvi.HeartbeatC5(
            humidity: humidity,
            temperature: temperature,
            pressure: pressure,
            movementCounter: movementCounter,
            measurementSequenceNumber: measurementSequenceNumber,
            voltage: voltage,
            txPower: txPower
        )
    }

    func ruuviHeartbeatE1() -> Ruuvi.HeartbeatE1_V6 {

        // Extract FLAGS byte (Byte 28) - contains 9th bits for UINT9 values
        let flagsByte = self[28]
        let dbaInstantFlag = isBitSet(byte: flagsByte, bitIndex: 3)
        let dbaAvgFlag = isBitSet(byte: flagsByte, bitIndex: 4)
        let dbaPeakFlag = isBitSet(byte: flagsByte, bitIndex: 5)
        let vocFlag = isBitSet(byte: flagsByte, bitIndex: 6)
        let noxFlag = isBitSet(byte: flagsByte, bitIndex: 7)

        // Temperature (Bytes 1-2)
        var temperature: Double?
        if let t = self[1...2].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            temperature = t == Int16.min ? nil : Double(t) * 0.005
        }

        // Humidity (Bytes 3-4)
        var humidity: Double?
        if let h = self[3...4].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            humidity = h == UInt16.max ? nil : Double(h) * 0.0025
        }

        // Pressure (Bytes 5-6)
        var pressure: Double?
        if let p = self[5...6].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            pressure = p == UInt16.max ? nil : (Double(p) + 50000.0) / 100.0
        }

        // PM1.0 to PM10 (Bytes 7-14)
        let pm1 = self.toUInt16(from: 7).map { $0 == UInt16.max ? nil : Double($0) * 0.1 } ?? 0
        let pm25 = self.toUInt16(from: 9).map { $0 == UInt16.max ? nil : Double($0) * 0.1 } ?? 0
        let pm4 = self.toUInt16(from: 11).map { $0 == UInt16.max ? nil : Double($0) * 0.1 } ?? 0
        let pm10 = self.toUInt16(from: 13).map { $0 == UInt16.max ? nil : Double($0) * 0.1 } ?? 0

        // CO2 (Bytes 15-16)
        let co2 = self.toUInt16(from: 15).map { $0 == UInt16.max ? nil : Double($0) } ?? 0

        // VOC (UINT9: Byte 17 + FLAGS bit 6)
        let vocBaseByte = self[17]
        let vocValue = (UInt16(vocBaseByte) << 1) | (vocFlag ? 1 : 0)
        let voc = vocValue == 511 ? nil : Double(vocValue)

        // NOX (UINT9: Byte 18 + FLAGS bit 7)
        let noxBaseByte = self[18]
        let noxValue = (UInt16(noxBaseByte) << 1) | (noxFlag ? 1 : 0)
        let nox = noxValue == 511 ? nil : Double(noxValue)

        // Luminance (UINT24: Bytes 19-21)
        var luminance: Double?
        let lumiValue = (UInt32(self[19]) << 16) | (UInt32(self[20]) << 8) | UInt32(self[21])
        luminance = lumiValue == 0xFFFFFF ? nil : Double(lumiValue) * 0.01

        // dBA Instant (UINT9: Byte 22 + FLAGS bit 3)
        var dbaInstant: Double?
        let dbaInstantByte = self[22]
        let dbaInstantValue = (UInt16(dbaInstantByte) << 1) | (dbaInstantFlag ? 1 : 0)
        dbaInstant = dbaInstantValue == 511 ? nil : (Double(dbaInstantValue) * 0.2 + 18.0)

        // dBA Avg (UINT9: Byte 23 + FLAGS bit 4)
        var dbaAvg: Double?
        let dbaAvgByte = self[23]
        let dbaAvgValue = (UInt16(dbaAvgByte) << 1) | (dbaAvgFlag ? 1 : 0)
        dbaAvg = dbaAvgValue == 511 ? nil : (Double(dbaAvgValue) * 0.2 + 18.0)

        // dBA Peak (UINT9: Byte 24 + FLAGS bit 5)
        var dbaPeak: Double?
        let dbaPeakByte = self[24]
        let dbaPeakValue = (UInt16(dbaPeakByte) << 1) | (dbaPeakFlag ? 1 : 0)
        dbaPeak = dbaPeakValue == 511 ? nil : (Double(dbaPeakValue) * 0.2 + 18.0)

        // Measurement Sequence Number (UINT24: Bytes 25-27)
        var measurementSequenceNumber: Int
        let seqValue = (UInt32(self[25]) << 16) | (UInt32(self[26]) << 8) | UInt32(self[27])
        measurementSequenceNumber = seqValue == 0xFFFFFF ? 0 : Int(seqValue)

        return Ruuvi.HeartbeatE1_V6(
            humidity: humidity,
            temperature: temperature,
            pressure: pressure,
            pm1: pm1,
            pm25: pm25,
            pm4: pm4,
            pm10: pm10,
            co2: co2,
            voc: voc,
            nox: nox,
            luminance: luminance,
            dbaInstant: dbaInstant,
            dbaAvg: dbaAvg,
            dbaPeak: dbaPeak,
            measurementSequenceNumber: measurementSequenceNumber
        )
    }

    func ruuviLogE1() -> RuuviTagEnvLogFull? {
        guard self.count >= 32 else { return nil }

        // Timestamp (Bytes 0-3)
        let timestampRaw = self.subdata(in: 0..<4)
        let timestampBE  = timestampRaw.withUnsafeBytes { $0.load(as: UInt32.self) }
        let timestampLE  = UInt32(bigEndian: timestampBE)
        let date = Date(timeIntervalSince1970: TimeInterval(timestampLE))

        // Extract FLAGS byte (Byte 32) - contains 9th bits for UINT9 values
        let flagsByte = self.count > 32 ? self[32] : 0
        let dbaInstantFlag = isBitSet(byte: flagsByte, bitIndex: 3)
        let dbaAvgFlag = isBitSet(byte: flagsByte, bitIndex: 4)
        let dbaPeakFlag = isBitSet(byte: flagsByte, bitIndex: 5)
        let vocFlag = isBitSet(byte: flagsByte, bitIndex: 6)
        let noxFlag = isBitSet(byte: flagsByte, bitIndex: 7)

        // Temperature (Bytes 5-6)
        var temperature: Double?
        if let t = self[5...6].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            temperature = t == Int16.min ? nil : Double(t) * 0.005
        }

        // Humidity (Bytes 7-8)
        var humidity: Double?
        if let h = self[7...8].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            humidity = h == UInt16.max ? nil : Double(h) * 0.0025
        }

        // Pressure (Bytes 9-10)
        var pressure: Double?
        if let p = self[9...10].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            pressure = p == UInt16.max ? nil : (Double(p) + 50000.0) / 100.0
        }

        // PM1.0 to PM10 (Bytes 11-18)
        let pm1 = self.toUInt16(from: 11).map { $0 == UInt16.max ? nil : Double($0) * 0.1 } ?? nil
        let pm25 = self.toUInt16(from: 13).map { $0 == UInt16.max ? nil : Double($0) * 0.1 } ?? nil
        let pm4 = self.toUInt16(from: 15).map { $0 == UInt16.max ? nil : Double($0) * 0.1 } ?? nil
        let pm10 = self.toUInt16(from: 17).map { $0 == UInt16.max ? nil : Double($0) * 0.1 } ?? nil

        // CO2 (Bytes 19-20)
        let co2 = self.toUInt16(from: 19).map { $0 == UInt16.max ? nil : Double($0) } ?? nil

        // VOC (UINT9: Byte 21 + FLAGS bit 6)
        var voc: Double?
        if self.count > 21 {
            let vocBaseByte = self[21]
            let vocValue = (UInt16(vocBaseByte) << 1) | (vocFlag ? 1 : 0)
            voc = vocValue == 511 ? nil : Double(vocValue)
        } else {
            voc = nil
        }

        // NOX (UINT9: Byte 22 + FLAGS bit 7)
        var nox: Double?
        if self.count > 22 {
            let noxBaseByte = self[22]
            let noxValue = (UInt16(noxBaseByte) << 1) | (noxFlag ? 1 : 0)
            nox = noxValue == 511 ? nil : Double(noxValue)
        } else {
            nox = nil
        }

        // Luminance (UINT24: Bytes 23-25)
        var luminance: Double?
        if self.count > 25 {
            let lumiValue = (UInt32(self[23]) << 16) | (UInt32(self[24]) << 8) | UInt32(self[25])
            luminance = lumiValue == 0xFFFFFF ? nil : Double(lumiValue) * 0.01
        } else {
            luminance = nil
        }

        // dBA Instant (UINT9: Byte 26 + FLAGS bit 3)
        var dbaInstant: Double?
        if self.count > 26 {
            let dbaInstantByte = self[26]
            let dbaInstantValue = (UInt16(dbaInstantByte) << 1) | (dbaInstantFlag ? 1 : 0)
            dbaInstant = dbaInstantValue == 511 ? nil : (Double(dbaInstantValue) * 0.2 + 18.0)
        } else {
            dbaInstant = nil
        }

        // dBA Avg (UINT9: Byte 27 + FLAGS bit 4)
        var dbaAvg: Double?
        if self.count > 27 {
            let dbaAvgByte = self[27]
            let dbaAvgValue = (UInt16(dbaAvgByte) << 1) | (dbaAvgFlag ? 1 : 0)
            dbaAvg = dbaAvgValue == 511 ? nil : (Double(dbaAvgValue) * 0.2 + 18.0)
        } else {
            dbaAvg = nil
        }

        // dBA Peak (UINT9: Byte 28 + FLAGS bit 5)
        var dbaPeak: Double?
        if self.count > 28 {
            let dbaPeakByte = self[28]
            let dbaPeakValue = (UInt16(dbaPeakByte) << 1) | (dbaPeakFlag ? 1 : 0)
            dbaPeak = dbaPeakValue == 511 ? nil : (Double(dbaPeakValue) * 0.2 + 18.0)
        } else {
            dbaPeak = nil
        }

        let record = RuuviTagEnvLogFull(
            date: date,
            temperature: temperature,
            humidity: humidity,
            pressure: pressure,
            pm1: pm1,
            pm25: pm25,
            pm4: pm4,
            pm10: pm10,
            co2: co2,
            voc: voc,
            nox: nox,
            luminosity: luminance,
            soundInstant: dbaInstant,
            soundAvg: dbaAvg,
            soundPeak: dbaPeak,
            batteryVoltage: nil
        )

        return record
    }

    private func addColons(mac: String) -> String {
        let out = NSMutableString(string: mac)
        var i = mac.count - 2
        while i > 0 {
            out.insert(":", at: i)
            i -= 2
        }
        return out.uppercased as String
    }

    func convertLogarithmic(byteValue: UInt8, maxSensorValue: Double) -> Double {
        // Normalize the byte value to a range between 0 and 1
        let normalizedValue = Double(byteValue) / 255.0
        // Apply the logarithmic scaling
        let value = pow(10, normalizedValue * log10(maxSensorValue))
        return value
    }

    // Helper function for bit checking
    private func isBitSet(byte: UInt8, bitIndex: Int) -> Bool {
        guard bitIndex >= 0 && bitIndex <= 7 else { return false }
        return (Int(byte) >> bitIndex) & 1 == 1
    }
}

extension Data {
    // Convert a range of Data to UInt16
    func toUInt16(from index: Int) -> UInt16? {
        guard index + 1 < self.count else {
            return nil
        }
        let highByte = self[index]
        let lowByte = self[index + 1]
        let value = (UInt16(highByte) << 8) | UInt16(lowByte)
        return value
    }
}

extension Double {
    func roundToPlaces(_ places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
