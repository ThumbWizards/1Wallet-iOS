//
//  SilentState.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 29/11/2021.
//

import Foundation


/// A state that doesn't publish the value, this can be used to create state in a view that
///  can be updated during the View's `body` but not trigger a refresh, example:
///  ```
///  struct BodyCountView: View {
///     @State @SilentState var bodyCount: Int = 0
///     var body: some View {
///         bodyCount += 1
///         return Text("Body Count \(bodyCount)")
///     }
///  }
///  ```
/// Requires Swift 5.3 for: https://github.com/apple/swift/pull/26572
@propertyWrapper
class SilentState<ValueType> {
    // swiftlint:disable identifier_name
    var _wrappedValue: ValueType?
    // swiftlint:enable identifier_name
    var wrappedValue: ValueType {
        get {
            if case .none = _wrappedValue {
                _wrappedValue = .some(initializer())
            }
            return _wrappedValue!
        }
        set {
            _wrappedValue = newValue
        }
    }

    var initializer: () -> ValueType

    init(wrappedValue: @autoclosure @escaping () -> ValueType) {
        self.initializer = wrappedValue
    }

    init(initializer: @escaping () -> ValueType) {
        self.initializer = initializer
    }
}
