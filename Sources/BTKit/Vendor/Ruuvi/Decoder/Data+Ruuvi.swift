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
        public var measurementSequenceNumber: Int?
        public var voltage: Double?
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
        let pm1Byte = self[6]
        if pm1Byte == UInt8.max {
            pm1_0 = nil
        } else {
            pm1_0 = convertLogarithmic(byteValue: pm1Byte, maxSensorValue: 10000.0)
        }

        // PM2.5
        var pm2_5: Double?
        let pm2_5Byte = self[7]
        if pm2_5Byte == UInt8.max {
            pm2_5 = nil
        } else {
            pm2_5 = convertLogarithmic(byteValue: pm2_5Byte, maxSensorValue: 10000.0)
        }

        // PM4.0
        var pm4_0: Double?
        let pm4Byte = self[8]
        if pm4Byte == UInt8.max {
            pm4_0 = nil
        } else {
            pm4_0 = convertLogarithmic(byteValue: pm4Byte, maxSensorValue: 10000.0)
        }

        // PM10
        var pm10: Double?
        let pm10Byte = self[9]
        if pm10Byte == UInt8.max {
            pm10 = nil
        } else {
            pm10 = convertLogarithmic(byteValue: pm10Byte, maxSensorValue: 10000.0)
        }

        // CO2
        var co2: Double?
        let co2Byte = self[10]
        if co2Byte == UInt8.max {
            co2 = nil
        } else {
            co2 = convertLogarithmic(byteValue: co2Byte, maxSensorValue: 10000.0)
        }

        // VOC
        var voc: Double?
        let vocByte = self[11]
        if vocByte == UInt8.max {
            voc = nil
        } else {
            voc = Double(vocByte) * 2.0
        }

        // NOX
        var nox: Double?
        let noxByte = self[12]
        if noxByte == UInt8.max {
            nox = nil
        } else {
            nox = Double(noxByte) * 2.0
        }

        // **Luminance (Bytes 25-26)**
        var luminane: Double?
        let lumi = self[13]
        if lumi == UInt16.max {
            luminane = nil
        } else {
            luminane = Double(lumi)
        }

        // dBa Avg
        var dbaAvg: Double?
        let dbaByte = self[14]
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
            lumi: luminane,
            dbaAvg: dbaAvg,
            mac: mac
        )
    }

    func ruuvi6AdvertisingExtension() -> Ruuvi.Data6 {

        // temperature
        var temperature: Double?
        if let t = self[5...6].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
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
        if let h = self[7...8].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
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
        if let p = self[9...10].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if p == UInt16.max {
                pressure = nil
            } else {
                pressure = (Double(p) + 50000.0) / 100.0
            }
        } else {
            pressure = nil
        }


        // **PM1.0 (Bytes 11-12)**
        var pm1_0: Double?
        if let pm = self[11...12].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            if pm == Int16.min {
                pm1_0 = nil
            } else {
                pm1_0 = Double(pm) * 0.1
            }
        } else {
            pm1_0 = nil
        }

        // **PM2.5 (Bytes 13-14)**
        var pm2_5: Double?
        if let pm = self[13...14].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            if pm == Int16.min {
                pm2_5 = nil
            } else {
                pm2_5 = Double(pm) * 0.1
            }
        } else {
            pm2_5 = nil
        }

        // **PM4.0 (Bytes 15-16)**
        var pm4_0: Double?
        if let pm = self[15...16].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            if pm == Int16.min {
                pm4_0 = nil
            } else {
                pm4_0 = Double(pm) * 0.1
            }
        } else {
            pm4_0 = nil
        }

        // **PM10 (Bytes 17-18)**
        var pm10: Double?
        if let pm = self[17...18].withUnsafeBytes({ $0.bindMemory(to: Int16.self) }).map(Int16.init(bigEndian:)).first {
            if pm == Int16.min {
                pm10 = nil
            } else {
                pm10 = Double(pm) * 0.1
            }
        } else {
            pm10 = nil
        }

        // **CO2 (Bytes 19-20)**
        var co2: Double?
        if let c = self[19...20].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if c == UInt16.max {
                co2 = nil
            } else {
                co2 = Double(c)
            }
        } else {
            co2 = nil
        }

        // **VOC (Bytes 21-22)**
        var voc: Double?
        if let v = self[21...22].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if v == UInt16.max {
                voc = nil
            } else {
                voc = Double(v)
            }
        } else {
            voc = nil
        }

        // **NOX (Bytes 23-24)**
        var nox: Double?
        if let n = self[23...24].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if n == UInt16.max {
                nox = nil
            } else {
                nox = Double(n)
            }
        } else {
            nox = nil
        }

        // **Luminance (Bytes 25-26)**
        var luminane: Double?
        if let lumi = self[25...26].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if lumi == UInt16.max {
                luminane = nil
            } else {
                luminane = Double(lumi)
            }
        } else {
            luminane = nil
        }

        // **dBA Average (Byte 27)**
        var dbaAvg: Double?
        let dbaAvgByte = self[27]
        if dbaAvgByte == UInt8.max {
            dbaAvg = nil
        } else {
            dbaAvg = Double(dbaAvgByte) * 0.5
        }

        // **dBA Peak (Byte 28)**
        var dbaPeak: Double?
        let dbaPeakByte = self[28]
        if dbaPeakByte == UInt8.max {
            dbaPeak = nil
        } else {
            // Assuming the same scaling factor as dBA Average
            dbaPeak = Double(dbaPeakByte) * 0.5
        }

        // **MeasurementSequenceNumber Number (Bytes 29-30)**
        // measurementSequenceNumber
        var measurementSequenceNumber: Int?
        if let msn = self[29...30].withUnsafeBytes({ $0.bindMemory(to: UInt16.self) }).map(UInt16.init(bigEndian:)).first {
            if msn == UInt16.max {
                measurementSequenceNumber = nil
            } else {
                measurementSequenceNumber = Int(msn)
            }
        } else {
            measurementSequenceNumber = nil
        }

        // **Voltage (Byte 31)**
        var voltage: Double?
        let voltageByte = self[31]
        if voltageByte == UInt8.max {
            voltage = nil
        } else {
            voltage = Double(voltageByte) * 0.03 // 30 mV scaling factor
        }

        // **MAC Address (Bytes 38-43)**
        let macBytes = self[38...43]
        let mac = macBytes.map { String(format: "%02X", $0) }.joined(separator: ":")

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
            lumi: luminane,
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
