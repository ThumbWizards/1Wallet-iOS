//
//  IdentityAPIOperators.swift
//  Timeless-wallet
//
//  Created by Ajay Ghodadra on 23/10/21.
//

import Foundation
import Combine

extension URLSession.ErasedDataTaskPublisher {
    func retryOnceOnUnauthorizedResponse(chainedRequest: AnyPublisher<Output, Error>? = nil) -> AnyPublisher<Output, Error> {
        tryMap { data, response -> URLSession.ErasedDataTaskPublisher.Output in
            if let res = response as? HTTPURLResponse,
               res.statusCode == HTTPStatusCode.unauthorized.rawValue {
                throw API.APIError.unauthorized
            } else if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let errors = json["errors"] as? [[String: Any]] {
                if (errors.contains(where: { ($0["extensions"] as? [String: Any])?["code"] as? String == "not-authorized" })) {
                    throw API.APIError.unauthorized
                }
            }
            return (data:data, response:response)
        }
        .retryOn(API.APIError.unauthorized, retries: 1, chainedPublisher: chainedRequest)
        .eraseToAnyPublisher()
    }
}
