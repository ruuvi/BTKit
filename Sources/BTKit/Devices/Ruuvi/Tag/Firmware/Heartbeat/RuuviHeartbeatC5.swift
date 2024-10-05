public struct RuuviHeartbeatC5 {
    public var uuid: String
    public var isConnectable: Bool
    public var version: Int
    public var humidity: Double?
    public var temperature: Double?
    public var pressure: Double?
    public var voltage: Double?
    public var movementCounter: Int?
    public var measurementSequenceNumber: Int?
    public var txPower: Int?

    init(
        uuid: String,
        isConnectable: Bool,
        version: Int,
        humidity: Double? = nil,
        temperature: Double? = nil,
        pressure: Double? = nil,
        voltage: Double? = nil,
        movementCounter: Int? = nil,
        measurementSequenceNumber: Int? = nil,
        txPower: Int? = nil
    ) {
        self.uuid = uuid
        self.isConnectable = isConnectable
        self.version = version
        self.humidity = humidity
        self.temperature = temperature
        self.pressure = pressure
        self.voltage = voltage
        self.movementCounter = movementCounter
        self.measurementSequenceNumber = measurementSequenceNumber
        self.txPower = txPower
    }
}

