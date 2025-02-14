import Foundation

/// A type-safe, thread-safe, memory-efficient implementation of Signals in Swift.
/// Fully replicates the JavaScript version, including memorization, activation toggling, and listener management.
class Signal<T> {
    private var listeners: [(id: UUID, callback: (T) -> Void, isOnce: Bool)] = [] // (ID, Callback, isOnce)
    private var lastDispatchedValue: T?
    private let queue = DispatchQueue(label: "com.signal.concurrentQueue", attributes: .concurrent)
    
    var memorize: Bool = false
    var active: Bool = true
    
    /// Adds a listener that will be called every time the signal is dispatched.
    func add(_ listener: @escaping (T) -> Void) -> UUID {
        let id = UUID()
        queue.async(flags: .barrier) {
            self.listeners.append((id: id, callback: listener, isOnce: false))
            if self.memorize, let lastValue = self.lastDispatchedValue {
                DispatchQueue.main.async { listener(lastValue) }
            }
        }
        return id
    }
    
    /// Adds a listener that will be called only once, then automatically removed.
    func addOnce(_ listener: @escaping (T) -> Void) -> UUID {
        let id = UUID()
        queue.async(flags: .barrier) {
            self.listeners.append((id: id, callback: listener, isOnce: true))
            if self.memorize, let lastValue = self.lastDispatchedValue {
                DispatchQueue.main.async { listener(lastValue) }
            }
        }
        return id
    }
    
    /// Removes a specific listener by its UUID.
    func remove(by id: UUID) {
        queue.async(flags: .barrier) {
            self.listeners.removeAll { $0.id == id }
        }
    }
    
    /// Removes all listeners from the signal.
    func removeAll() {
        queue.async(flags: .barrier) {
            self.listeners.removeAll()
        }
    }
    
    /// Calls all listeners with the provided argument.
    func dispatch(_ value: T) {
        guard active else { return }
        
        queue.async(flags: .barrier) {
            if self.memorize {
                self.lastDispatchedValue = value
            }
            
            for (index, listener) in self.listeners.enumerated().reversed() {
                DispatchQueue.main.async {
                    listener.callback(value)
                }
                if listener.isOnce {
                    self.listeners.remove(at: index)
                }
            }
        }
    }
    
    /// Checks if a specific listener is already added.
    func has(_ id: UUID) -> Bool {
        var exists = false
        queue.sync {
            exists = self.listeners.contains { $0.id == id }
        }
        return exists
    }
    
    /// Returns the number of active listeners.
    func getNumListeners() -> Int {
        var count = 0
        queue.sync {
            count = self.listeners.count
        }
        return count
    }
}