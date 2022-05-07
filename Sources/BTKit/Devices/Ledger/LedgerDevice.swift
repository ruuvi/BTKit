import Foundation

public enum LedgerDevice {
    case nanoX(LedgerNanoX)
}

public struct LedgerNanoX {
    public var uuid: String
    public var name: String?
    public var rssi: Int?
    public var isConnectable: Bool

    public init(
        uuid: String,
        name: String?,
        rssi: Int?,
        isConnectable: Bool
    ) {
        self.uuid = uuid
        self.name = name
        self.rssi = rssi
        self.isConnectable = isConnectable
    }
}

extension LedgerNanoX: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

extension LedgerNanoX: Equatable {
    public static func ==(lhs: LedgerNanoX, rhs: LedgerNanoX) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

#if compiler(>=5.5) && canImport(_Concurrency)

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension LedgerNanoX {
    public func address<T: AnyObject>(
        _ observer: T,
        path: String = "44'/60'/0'/0/0",
        verify: Bool = false,
        progress: ((BTServiceProgress) -> Void)? = nil,
        options: BTScannerOptionsInfo? = [.connectionTimeout(10), .serviceTimeout(10)]
    ) async throws -> LedgerAddressResult {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<LedgerAddressResult, Error>) in
            if !isConnectable {
                continuation.resume(throwing: BTLogicError.notConnectable)
            } else {
                var alreadyCalled = false
                BTKit.background.services.ledger.fetchAddress(observer, uuid, options, path: path, verify, progress: progress) { observer, result in
                    guard !alreadyCalled else { return }
                    alreadyCalled = true
                    switch result {
                    case let .success(addressResult):
                        continuation.resume(returning: addressResult)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    public func signMessageHash<T: AnyObject>(
        _ observer: T,
        messageHash: String,
        path: String = "44'/60'/0'/0/0",
        progress: ((BTServiceProgress) -> Void)? = nil,
        options: BTScannerOptionsInfo? = [.connectionTimeout(10), .serviceTimeout(10)]
    ) async throws -> LedgerSignMessageResult {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<LedgerSignMessageResult, Error>) in
            if !isConnectable {
                continuation.resume(throwing: BTLogicError.notConnectable)
            } else {
                var alreadyCalled = false
                BTKit.background.services.ledger.signMessageHash(observer, uuid, messageHash: messageHash, path: path, options, progress: progress) { observer, result in
                    guard !alreadyCalled else { return }
                    alreadyCalled = true
                    switch result {
                    case let .success(signMessageResult):
                        continuation.resume(returning: signMessageResult)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
#endif

