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

    struct DataE0_F0 {
        public var humidity: Double?
        public var temperature: Double?
        public var pressure: Double?
        public var pm1: Double?
        public var pm2_5: Double?
        public var pm4: Double?
        public var pm10: Double?
        public var co2: Double?
        public var voc: Double?
        public var nox: Double?
        public var luminance: Double?
        public var dbaAvg: Double?
        public var dbaPeak: Double?
        public var measurementSequenceNumber: Int?
        public var voltage: Double?
        public var mac: String
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

    struct HeartbeatE0_F0 {
        public var humidity: Double?
        public var temperature: Double?
        public var pressure: Double?
        public var pm1: Double?
        public var pm2_5: Double?
        public var pm4: Double?
        public var pm10: Double?
        public var co2: Double?
        public var voc: Double?
        public var nox: Double?
        public var luminance: Double?
        public var dbaAvg: Double?
        public var dbaPeak: Double?
        public var measurementSequenceNumber: Int?
        public var voltage: Double?
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

    func ruuviF0() -> Ruuvi.DataE0_F0 {
        // Temperature (Byte 3)
        var temperature: Double?
        let temperatureByte = Int8(bitPattern: self[3])
        if temperatureByte == Int8.min {
            temperature = nil
        } else {
            temperature = Double(temperatureByte) * 1.0 // Resolution 1
        }

        // Humidity (Byte 4)
        var humidity: Double?
        let humidityByte = self[4]
        if humidityByte == UInt8.max {
            humidity = nil
        } else {
            humidity = Double(humidityByte) * 0.5 // Resolution 0.5
        }

        // Pressure (Byte 5)
        var pressure: Double?
        let pressureByte = self[5]
        if pressureByte == UInt8.max {
            pressure = nil
        } else {
            pressure = Double(pressureByte) * 1.0 + 900.0 // Resolution 1 hPa, offset 900 hPa
        }

        // Logarithmic conversion function with specific scale factors
        func convertLogarithmic(byteValue: UInt8, scale: Double) -> Double {
            if byteValue == 0 {
                return 0.0
            } else {
                let value = exp(Double(byteValue) / scale) - 1.0
                return value
            }
        }

        // Precompute scales
        let scalePM = 254.0 / log(1000.0 + 1.0) // Max 1000
        let scaleCO2 = 254.0 / log(40000.0 + 1.0) // Max 40000
        let scaleVOCNOx = 254.0 / log(500.0 + 1.0) // Max 500
        let scaleLumi = 254.0 / log(40000.0 + 1.0) // Max 40000

        // PM1.0 to PM10 (Bytes 6-9)
        let pm1 = self[6] == UInt8.min ? nil : convertLogarithmic(byteValue: self[6], scale: scalePM)
        let pm2_5 = self[7] == UInt8.min ? nil : convertLogarithmic(byteValue: self[7], scale: scalePM)
        let pm4 = self[8] == UInt8.min ? nil : convertLogarithmic(byteValue: self[8], scale: scalePM)
        let pm10  = self[9] == UInt8.min ? nil : convertLogarithmic(byteValue: self[9], scale: scalePM)

        // CO2 (Byte 10)
        let co2 = self[10] == UInt8.min ? nil : convertLogarithmic(byteValue: self[10], scale: scaleCO2)

        // VOC (Byte 11)
        var voc: Double?
        let vocByte = self[11]
        if vocByte == UInt8.min {
            voc = nil
        } else {
            voc = convertLogarithmic(byteValue: vocByte, scale: scaleVOCNOx)
        }

        // NOx (Byte 12)
        var nox: Double?
        let noxByte = self[12]
        if noxByte == UInt8.min {
            nox = nil
        } else {
            nox = convertLogarithmic(byteValue: noxByte, scale: scaleVOCNOx)
        }

        // Luminance (Byte 13)
        var luminance: Double?
        let lumiByte = self[13]
        if lumiByte == UInt8.min {
            luminance = nil
        } else {
            luminance = convertLogarithmic(byteValue: lumiByte, scale: scaleLumi)
        }

        // dBA Avg (Byte 14)
        var dbaAvg: Double?
        let dbaByte = self[14]
        if dbaByte == UInt8.min {
            dbaAvg = nil
        } else {
            dbaAvg = Double(dbaByte) * 0.5 // Resolution 0.5 dB
        }

        // MAC Address (Bytes 25-30)
        let asStr = self.hexEncodedString()
        let start = asStr.index(asStr.endIndex, offsetBy: -12)
        let mac = addColons(mac: String(asStr[start...]))

        return Ruuvi.DataE0_F0(
            humidity: humidity,
            temperature: temperature,
            pressure: pressure,
            pm1: pm1,
            pm2_5: pm2_5,
            pm4: pm4,
            pm10: pm10,
            co2: co2,
            voc: voc,
            nox: nox,
            luminance: luminance,
            dbaAvg: dbaAvg,
            mac: mac
        )
    }

    func ruuviE0() -> Ruuvi.DataE0_F0 {

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
        let pm1 = self.toUInt16(from: 9).map { $0 == UInt16.min ? nil : Double($0) * 0.1 } ?? 0
        let pm2_5 = self.toUInt16(from: 11).map { $0 == UInt16.min ? nil : Double($0) * 0.1 } ?? 0
        let pm4 = self.toUInt16(from: 13).map { $0 == UInt16.min ? nil : Double($0) * 0.1 } ?? 0
        let pm10 = self.toUInt16(from: 15).map { $0 == UInt16.min ? nil : Double($0) * 0.1 } ?? 0

        // CO2 (Bytes 17-18)
        let co2 = self.toUInt16(from: 17).map { $0 == UInt16.min ? nil : Double($0) } ?? 0

        // VOC (Bytes 19-20)
        let voc = self.toUInt16(from: 19).map { $0 == UInt16.min ? nil : Double($0) } ?? 0

        // NOX (Bytes 21-22)
        let nox = self.toUInt16(from: 21).map { $0 == UInt16.min ? nil : Double($0) } ?? 0

        // Luminance (Bytes 23-24)
        let luminance = self.toUInt16(from: 23).map { $0 == UInt16.min ? nil : Double($0) } ?? 0

        // dBA Avg (Byte 25)
        var dbaAvg: Double?
        let dbaAvgByte = self[25]
        dbaAvg = dbaAvgByte == UInt8.min ? nil : Double(dbaAvgByte) * 0.5

        // dBA Peak (Byte 26)
        var dbaPeak: Double?
        let dbaPeakByte = self[26]
        dbaPeak = dbaPeakByte == UInt8.min ? nil : Double(dbaPeakByte) * 0.5

        // measurementSequenceNumber (Bytes 27-28)
        let measurementSequenceNumber = self.toUInt16(from: 27).map { $0 == UInt16.max ? nil : Int($0) } ?? 0

        // Voltage (Byte 29)
        var voltage: Double?
        let voltageByte = self[29]
        voltage = voltageByte == UInt8.min ? nil : Double(voltageByte) * 0.03

        // MAC Address (Bytes 36-41)
        let macBytes = self[36...41]
        let mac = macBytes.map { String(format: "%02X", $0) }.joined(separator: ":")

        return Ruuvi.DataE0_F0(
            humidity: humidity,
            temperature: temperature,
            pressure: pressure,
            pm1: pm1,
            pm2_5: pm2_5,
            pm4: pm4,
            pm10: pm10,
            co2: co2,
            voc: voc,
            nox: nox,
            luminance: luminance,
            dbaAvg: dbaAvg,
            dbaPeak: dbaPeak,
            measurementSequenceNumber: measurementSequenceNumber,
            voltage: voltage,
            mac: mac
        )
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
