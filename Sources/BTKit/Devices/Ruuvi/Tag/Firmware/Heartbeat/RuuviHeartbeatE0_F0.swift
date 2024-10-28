public struct RuuviHeartbeatE0_F0 {
    public var uuid: String
    public var isConnectable: Bool
    public var version: Int
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

    init(
        uuid: String,
        serviceUUID: String? = nil,
        rssi: Int,
        isConnectable: Bool,
        version: Int,
        humidity: Double? = nil,
        temperature: Double? = nil,
        pressure: Double? = nil,
        pm1: Double? = nil,
        pm2_5: Double? = nil,
        pm4: Double? = nil,
        pm10: Double? = nil,
        co2: Double? = nil,
        voc: Double? = nil,
        nox: Double? = nil,
        luminance: Double? = nil,
        dbaAvg: Double? = nil,
        dbaPeak: Double? = nil,
        measurementSequenceNumber: Int? = nil,
        voltage: Double? = nil
    ) {
        self.uuid = uuid
        self.isConnectable = isConnectable
        self.version = version
        self.humidity = humidity
        self.temperature = temperature
        self.pressure = pressure
        self.pm1 = pm1
        self.pm2_5 = pm2_5
        self.pm4 = pm4
        self.pm10 = pm10
        self.co2 = co2
        self.voc = voc
        self.nox = nox
        self.luminance = luminance
        self.dbaAvg = dbaAvg
        self.dbaPeak = dbaPeak
        self.measurementSequenceNumber = measurementSequenceNumber
        self.voltage = voltage
    }
}
