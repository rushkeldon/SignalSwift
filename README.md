# Signal.swift

## Overview

**Signal.swift** is a type-safe, thread-safe, and memory-efficient implementation of the Signals pattern in Swift. It fully replicates the JavaScript version, including key features such as:
- **Listener management**: Add, remove, and manage event listeners.
- **Memorization**: Ensures the last dispatched value is stored and immediately passed to new listeners.
- **Activation toggling**: Enables or disables signal dispatching dynamically.
- **Thread safety**: Utilizes a serial queue to ensure proper synchronization.

This library is ideal for event-driven architectures, reactive programming, and decoupled communication between components.

## Features

- **`add(listener:)`**: Adds a listener to the signal.
- **`addOnce(listener:)`**: Adds a listener that will only be called once.
- **`remove(listener:)`**: Removes a specific listener.
- **`removeAll()`**: Removes all listeners.
- **`dispatch(value:)`**: Dispatches a value to all listeners (if active).
- **`has(listener:)`**: Checks if a listener is already registered.
- **`getNumListeners()`**: Returns the number of active listeners.
- **`setActive(_:)`**: Activates or deactivates the signal.

## Installation

Simply copy `Signal.swift` into your project.

### Swift Package Manager (SPM)
_(SPM support coming soon)_

## Usage

### 1. Creating a Signal
```swift
let signal = Signal<String>()
```

### 2. Adding Listeners

```swift
signal.add { value in
    print("Received: \(value)")
}

let listener: (String) -> Void = { value in
    print("Another listener: \(value)")
}
signal.add(listener: listener)
```

### 3. Dispatching Events

```swift
signal.dispatch(value: "Hello, Signals!")
```

### 4. Adding a One-Time Listener

```swift
signal.addOnce { value in
    print("This will only be triggered once: \(value)")
}

signal.dispatch(value: "Event 1") // Triggers all listeners
signal.dispatch(value: "Event 2") // One-time listener does not trigger again
```

### 5. Removing Listeners

```swift
try? signal.remove(listener: listener)
```

### 6. Removing All Listeners

```swift
signal.removeAll()
```

### 7. Checking for Listeners

```swift
if signal.has(listener: listener) {
    print("Listener is still registered.")
} else {
    print("Listener has been removed.")
}
```

### 8. Getting the Number of Listeners

```swift
print("Number of active listeners: \(signal.getNumListeners())")
```

### 9. Activating & Deactivating Signals

```swift
signal.setActive(false) // Disables dispatching

signal.dispatch(value: "This won't be received by listeners.")

signal.setActive(true) // Enables dispatching again
signal.dispatch(value: "Now listeners will receive this.")
```

## License

This project is released under [The Unlicense](https://unlicense.org/), which places the code in the public domain. This means:

- You can use, modify, distribute, and sublicense it without restriction.
- No attribution is required, though it is appreciated.
- The software is provided "as is," without warranty of any kind.

---

Enjoy using **Signal.swift**! 🚀
