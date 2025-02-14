import Foundation

enum SignalError: Error {
    case listenerNotFound
    case invalidOperation(String)
}
/// A type-safe, thread-safe, memory-efficient implementation of Signals in Swift.
/// Fully replicates the JavaScript version, including memorization, activation toggling, and listener management.
class Signal<T> {
    typealias Listener = (T) -> Void
    private var listeners: [Listener] = []
    private var lastValue: T?
    private var isMemorized: Bool = false
    private let queue = DispatchQueue(label: "com.signal.serialQueue")
    private var isActive: Bool = true  // Controls whether the signal is active

    // Adds a listener to the signal
    func add(listener: @escaping Listener) {
        queue.async {
            self.listeners.append(listener)
            if self.isMemorized, let value = self.lastValue {
                listener(value)  // Immediately invoke with last memorized value
            }
        }
    }

    // Adds a listener that will be called only once
    func addOnce(listener: @escaping Listener) {
        let onceListener: Listener = { [weak self, weak listener] value in
            guard let strongSelf = self, let strongListener = listener else { return }
            do {
                try strongSelf.remove(listener: strongListener)
            } catch {
                // Handle error if needed
            }
            strongListener(value)
        }
        add(listener: onceListener)
    }

    // Removes a specific listener
    func remove(listener: @escaping Listener) throws {
        queue.sync {
            guard let index = self.listeners.firstIndex(where: { $0 as AnyObject === listener as AnyObject }) else {
                throw SignalError.listenerNotFound
            }
            self.listeners.remove(at: index)
        }
    }

    // Removes all listeners
    func removeAll() {
        queue.async {
            self.listeners.removeAll()
        }
    }

    // Dispatches the signal to all listeners if active
    func dispatch(value: T) {
        queue.async {
            guard self.isActive else { return }
            self.lastValue = value  // Memorize the last dispatched value
            self.isMemorized = true
            for listener in self.listeners {
                listener(value)
            }
        }
    }

    // Checks if a specific listener is already added
    func has(listener: @escaping Listener) -> Bool {
        var exists = false
        queue.sync {
            exists = self.listeners.contains { $0 as AnyObject === listener as AnyObject }
        }
        return exists
    }

    // Returns the number of active listeners
    func getNumListeners() -> Int {
        var count = 0
        queue.sync {
            count = self.listeners.count
        }
        return count
    }

    // Enable or disable the signal
    func setActive(_ active: Bool) {
        queue.async {
            self.isActive = active
        }
    }
}