//
//  SimplexServiceProtocol.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/12/22.
//

import Foundation
import Combine

protocol SimplexServiceProtocol {
    func getNewQuote(amount: Double, uid: String) -> AnyPublisher<Swift.Result<QuoteSimplex, Error>, Never>
    func getPaymentId(walletAddress: String, quoteResponse: QuoteSimplex) -> AnyPublisher<Swift.Result<PaymentResponse, Error>, Never>
    func getCheckout(paymentId: String) -> AnyPublisher<Swift.Result<String, Error>, Never>
}
