//
//  Publishers.swift
//  Timeless-wallet
//
//  Created by Vinh Dang on 1/17/22.
//

import Foundation
import Combine

extension Publishers {
    struct SafeZipMany<Element, F: Error>: Publisher {
        typealias Output = [Result<Element, F>]
        typealias Failure = Never

        private let upstreams: [AnyPublisher<Element, F>]

        init(_ upstreams: [AnyPublisher<Element, F>]) {
            self.upstreams = upstreams
        }

        func receive<S: Subscriber>(subscriber: S) where Self.Failure == S.Failure, Self.Output == S.Input {
            let initial = Just<[Result<Element, F>]>([])
                .eraseToAnyPublisher()

            let zipped = upstreams.reduce(into: initial) { result, upstream in
                let transformedUpstream: AnyPublisher<Result<Element, F>, Never> = upstream
                    .map {
                        Result.success($0)
                    }
                    .catch { Just(.failure($0)) }
                    .eraseToAnyPublisher()
                result = result.zip(transformedUpstream) { elements, element in
                    elements + [element]
                }
                .eraseToAnyPublisher()
            }

            zipped.subscribe(subscriber)
        }
    }

    struct ZipMany<Element, F: Error>: Publisher {
        typealias Output = [Element]
        typealias Failure = F

        private let upstreams: [AnyPublisher<Element, F>]

        init(_ upstreams: [AnyPublisher<Element, F>]) {
            self.upstreams = upstreams
        }

        func receive<S: Subscriber>(subscriber: S) where Self.Failure == S.Failure, Self.Output == S.Input {
            let initial = Just<[Element]>([])
                .setFailureType(to: F.self)
                .eraseToAnyPublisher()

            let zipped = upstreams.reduce(into: initial) { result, upstream in
                result = result.zip(upstream) { elements, element in
                    elements + [element]
                }
                .eraseToAnyPublisher()
            }

            zipped.subscribe(subscriber)
        }
    }
}
