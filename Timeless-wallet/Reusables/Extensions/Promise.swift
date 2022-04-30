//
//  Promise.swift
//  Timeless-wallet
//
//  Created by Vinh Dang on 11/29/21.
//

import Foundation
import Combine
import PromiseKit

extension Promise {
    var publisher: AnyPublisher<T, Error> {
        Future<T, Error> { promise in
            self.done { body in
                promise(.success(body))
            }
            .catch { error in
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
