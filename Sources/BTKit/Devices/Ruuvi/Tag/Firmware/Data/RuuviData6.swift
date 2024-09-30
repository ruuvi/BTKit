public struct RuuviData6 {
    public var uuid: String
    public var serviceUUID: String?
    public var rssi: Int
    public var isConnectable: Bool
    public var version: Int
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

    init(
        uuid: String,
        serviceUUID: String? = nil,
        rssi: Int,
        isConnectable: Bool,
        version: Int,
        humidity: Double? = nil,
        temperature: Double? = nil,
        pressure: Double? = nil,
        pm1_0: Double? = nil,
        pm2_5: Double? = nil,
        pm4_0: Double? = nil,
        pm10: Double? = nil,
        co2: Double? = nil,
        voc: Double? = nil,
        nox: Double? = nil,
        lumi: Double? = nil,
        dbaAvg: Double? = nil,
        dbaPeak: Double? = nil,
        sequence: Double? = nil,
        voltage: Double? = nil,
        mac: String
    ) {
        self.uuid = uuid
        self.serviceUUID = serviceUUID
        self.rssi = rssi
        self.isConnectable = isConnectable
        self.version = version
        self.humidity = humidity
        self.temperature = temperature
        self.pressure = pressure
        self.pm1_0 = pm1_0
        self.pm2_5 = pm2_5
        self.pm4_0 = pm4_0
        self.pm10 = pm10
        self.co2 = co2
        self.voc = voc
        self.nox = nox
        self.lumi = lumi
        self.dbaAvg = dbaAvg
        self.dbaPeak = dbaPeak
        self.sequence = sequence
        self.voltage = voltage
        self.mac = mac
    }
}
