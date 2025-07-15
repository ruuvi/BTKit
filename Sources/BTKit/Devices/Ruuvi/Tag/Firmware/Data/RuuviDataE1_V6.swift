public struct RuuviDataE1_V6 {
    public var uuid: String
    public var serviceUUID: String?
    public var rssi: Int
    public var isConnectable: Bool
    public var version: Int
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
        pm1: Double? = nil,
        pm25: Double? = nil,
        pm4: Double? = nil,
        pm10: Double? = nil,
        co2: Double? = nil,
        voc: Double? = nil,
        nox: Double? = nil,
        luminance: Double? = nil,
        dbaInstant: Double? = nil,
        dbaAvg: Double? = nil,
        dbaPeak: Double? = nil,
        sequence: Int? = nil,
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
        self.pm1 = pm1
        self.pm25 = pm25
        self.pm4 = pm4
        self.pm10 = pm10
        self.co2 = co2
        self.voc = voc
        self.nox = nox
        self.luminance = luminance
        self.dbaInstant = dbaInstant
        self.dbaAvg = dbaAvg
        self.dbaPeak = dbaPeak
        self.measurementSequenceNumber = sequence
        self.mac = mac
    }
}
