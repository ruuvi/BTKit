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

    struct Data6 {
        public var humidity: Double?
        public var temperature: Double?
        public var pressure: Double?
        public var pm1_0: Double?
        public var pm2_5: Double?
        public var pm4_0: Double?
        public var pm10: Double?
        public var co2: Double?
        public var voc: Double?
        public var nox: Double?
        public var lumi: Double?
        public var dbaAvg: Double?
        public var dbaPeak: Double?
        public var sequence: Double?
        public var voltage: Double?
        public var mac: String
    }

    struct Heartbeat1 {
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

    func ruuvi6Legacy() -> Ruuvi.Data6 {

        // temperature
        var temperature: Double?
        let temperatureByte = self[3]
        if temperatureByte == Int16.min {
            temperature = nil
        } else {
            temperature = Double(temperatureByte) / 200.0
        }

        // humidity
        var humidity: Double?
        let humidityByte = self[4]
        if humidityByte == UInt16.max {
            humidity = nil
        } else {
            humidity = Double(humidityByte) / 400.0
        }

        // pressure
        var pressure: Double?
        let pressureByte = self[5]
        if pressureByte == UInt16.max {
            pressure = nil
        } else {
            pressure = (Double(pressureByte) + 50000.0) / 100.0
        }

        // PM1.0
        var pm1_0: Double?
        let pm1Byte = self[15]
        if pm1Byte == UInt8.max {
            pm1_0 = nil
        } else {
            pm1_0 = convertLogarithmic(byteValue: pm1Byte, maxSensorValue: 10000.0)
        }

        // PM2.5
        var pm2_5: Double?
        let pm2_5Byte = self[16]
        if pm2_5Byte == UInt8.max {
            pm2_5 = nil
        } else {
            pm2_5 = convertLogarithmic(byteValue: pm2_5Byte, maxSensorValue: 10000.0)
        }

        // PM4.0
        var pm4_0: Double?
        let pm4Byte = self[17]
        if pm4Byte == UInt8.max {
            pm4_0 = nil
        } else {
            pm4_0 = convertLogarithmic(byteValue: pm4Byte, maxSensorValue: 10000.0)
        }

        // PM10
        var pm10: Double?
        let pm10Byte = self[18]
        if pm10Byte == UInt8.max {
            pm10 = nil
        } else {
            pm10 = convertLogarithmic(byteValue: pm10Byte, maxSensorValue: 10000.0)
        }

        // CO2
        var co2: Double?
        let co2Byte = self[18]
        if co2Byte == UInt8.max {
            co2 = nil
        } else {
            co2 = convertLogarithmic(byteValue: co2Byte, maxSensorValue: 10000.0)
        }

        // VOC
        var voc: Double?
        let vocByte = self[20]
        if vocByte == UInt8.max {
            voc = nil
        } else {
            voc = Double(vocByte) * 2.0
        }

        // NOX
        var nox: Double?
        let noxByte = self[21]
        if noxByte == UInt8.max {
            nox = nil
        } else {
            nox = Double(noxByte) * 2.0
        }

        // dBa Avg
        var dbaAvg: Double?
        let dbaByte = self[23]
        if dbaByte == UInt8.max {
            dbaAvg = nil
        } else {
            dbaAvg = Double(dbaByte) * 0.5
        }

        let asStr = self.hexEncodedString()
        let start = asStr.index(asStr.endIndex, offsetBy: -12)
        let mac = addColons(mac: String(asStr[start...]))
        return Ruuvi.Data6(
            humidity: humidity,
            temperature: temperature,
            pressure: pressure,
            pm1_0: pm1_0,
            pm2_5: pm2_5,
            pm4_0: pm4_0,
            pm10: pm10,
            co2: co2,
            voc: voc,
            nox: nox,
            dbaAvg: dbaAvg,
            mac: mac
        )
    }

//    func ruuvi6AdvertisingExtension() -> Ruuvi.Data6 {
//
//        // temperature
//        var temperature: Double?
//        if let t = self[3...4].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
//            if t == Int16.min {
//                temperature = nil
//            } else {
//                temperature = Double(t) / 200.0
//            }
//        } else {
//            temperature = nil
//        }
//
//        // humidity
//        var humidity: Double?
//        if let h = self[5...6].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
//            if h == UInt16.max {
//                humidity = nil
//            } else {
//                humidity = Double(h) / 400.0
//            }
//        } else {
//            humidity = nil
//        }
//
//        // pressure
//        var pressure: Double?
//        if let p = self[7...8].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
//            if p == UInt16.max {
//                pressure = nil
//            } else {
//                pressure = (Double(p) + 50000.0) / 100.0
//            }
//        } else {
//            pressure = nil
//        }
//
//        // powerInfo
//        var voltage: Double?
//        var txPower: Int?
//        if let powerInfo = self[9...10].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
//            let v = powerInfo >> 5
//            if v == 0b11111111111 {
//                voltage = nil
//            } else {
//                voltage = Double(v) / 1000.0 + 1.6
//            }
//            let tx = powerInfo & 0b11111
//            if tx == 0b11111 {
//                txPower = nil
//            } else {
//                txPower = Int(tx) * 2 - 40
//            }
//        } else {
//            voltage = nil
//            txPower = nil
//        }
//
//        // movementCounter
//        var movementCounter: Int?
//        let mc = self[11]
//        if mc == UInt8.max {
//            movementCounter = nil
//        } else {
//            movementCounter = Int(mc)
//        }
//
//        // measurementSequenceNumber
//        var measurementSequenceNumber: Int?
//        if let msn = self[12...13].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
//            if msn == UInt16.max {
//                measurementSequenceNumber = nil
//            } else {
//                measurementSequenceNumber = Int(msn)
//            }
//        } else {
//            measurementSequenceNumber = nil
//        }
//
//        let asStr = self.hexEncodedString()
//        let start = asStr.index(asStr.endIndex, offsetBy: -12)
//        let mac = addColons(mac: String(asStr[start...]))
//        return Ruuvi.Data6(
//            humidity: humidity,
//            temperature: temperature,
//            pressure: pressure,
//            movementCounter: movementCounter,
//            measurementSequenceNumber: measurementSequenceNumber,
//            voltage: voltage,
//            txPower: txPower,
//            mac: mac
//        )
//    }

    func ruuviHeartbeat1() -> Ruuvi.Heartbeat1 {
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

        return Ruuvi.Heartbeat1(humidity: humidity, temperature: temperature, pressure: pressure, accelerationX: accelerationX, accelerationY: accelerationY, accelerationZ: accelerationZ, movementCounter: movementCounter, measurementSequenceNumber: measurementSequenceNumber, voltage: voltage, txPower: txPower)
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
