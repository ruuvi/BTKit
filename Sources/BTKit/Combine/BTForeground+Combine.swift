import Combine

public final class BTKitForegroundPublisher {
    public lazy var ruuviTag: AnyPublisher<RuuviTag, Never> = {
        ruuviTagSubject
            .handleEvents(receiveSubscription: { [weak self] subscription in
                self?.addSubscriber(subscription)
            })
            .eraseToAnyPublisher()
    }()

    private let foreground: BTForeground
    private let ruuviTagSubject = PassthroughSubject<RuuviTag, Never>()
    private var subscriptions = [CombineIdentifier: AnyCancellable]()
    private var cancelable: ObservationToken?

    public init(foreground: BTForeground) {
        self.foreground = foreground
    }

    private func addSubscriber(_ subscription: Subscription) {
        let cancellable = AnyCancellable { [weak self] in
            self?.removeSubscriber(subscription.combineIdentifier)
        }
        subscriptions[subscription.combineIdentifier] = cancellable
        if subscriptions.count == 1 {
            startListening()
        }
    }

    private func removeSubscriber(_ id: CombineIdentifier) {
        subscriptions.removeValue(forKey: id)
        if subscriptions.isEmpty {
            stopListening()
        }
    }

    private func startListening() {
        cancelable = foreground.scan(self) { observer, device in
            if let ruuviTag = device.ruuvi?.tag {
                observer.ruuviTagSubject.send(ruuviTag)
            }
        }
    }

    private func stopListening() {
        cancelable?.invalidate()
        cancelable = nil
    }
}
