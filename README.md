# Signal Library

## Overview
The Signal library provides a type-safe, thread-safe, and memory-efficient implementation of signals in Swift. It is designed to fully replicate the JavaScript version, including features like memorization, activation toggling, and listener management.

## Features
- **Type-Safe**: Ensures that the data passed through signals is of the expected type.
- **Thread-Safe**: Can safely be used across multiple threads.
- **Memory-Efficient**: Optimized to use minimal memory.
- **Memorization**: Optionally remembers the last dispatched value and passes it to new listeners.
- **Activation Toggling**: Allows enabling or disabling the dispatch functionality.

## Usage

### Creating a Signal
To create a `Signal` instance, you need to specify the type of data it will handle. Here is an example of creating a signal for integer values:
```swift
import Foundation

// Create a signal for Int payloads
let intSignal = Signal<Int>()
```
### Adding Listeners
To add a listener that will be called every time the signal is dispatched:
```swift
let listenerID = intSignal.add { value in
    print("Received value: \(value)")
}
```
