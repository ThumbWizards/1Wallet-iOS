//
//  SimplexService.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/12/22.
//

import Foundation
import Combine

class SimplexService: BaseRestAPI<SimplexService.RequestType>, SimplexServiceProtocol {
    static let shared = SimplexService()
    private var _session: URLSession?

    override var urlSession: URLSession {
        return _session!
    }

    override init() {
        super.init()
        let sessionConfig = URLSessionConfiguration.default
        _session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
    }

    func getPaymentId(walletAddress: String, quoteResponse: QuoteSimplex) -> AnyPublisher<Result<PaymentResponse, Error>, Never> {
        let req = ReqPaymentId()
        req.walletaddress = walletAddress
        req.quoteResponse = quoteResponse
        return self.call(type: .payment, params: req.toDictionary())
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(PaymentResponse.self)
            .receive(on: DispatchQueue.main)
            .map { data in
                return .success(data)
            }
            .catch { error in
                Just(.failure(error))
            }
            .eraseToAnyPublisher()
    }

    func getNewQuote(amount: Double, uid: String) -> AnyPublisher<Result<QuoteSimplex, Error>, Never> {
        let req = ReqQuoteSimplex()
        req.uid = uid
        req.sourceAmount = amount
        return self.call(type: .quote, params: req.toDictionary())
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(QuoteSimplex.self)
            .receive(on: DispatchQueue.main)
            .map { data in
                return .success(data)
            }
            .catch { error in
                Just(.failure(error))
            }
            .eraseToAnyPublisher()
    }

    func getCheckout(paymentId: String) -> AnyPublisher<Result<String, Error>, Never> {
        let req = "payment_id=\(paymentId)"
        return self.callByFormType(type: .checkout, params: req)
            .unwrapResultJSONFromAPI()
            .map {
                if let reponse = $0.response as? HTTPURLResponse {
                    if let location = reponse.allHeaderFields["Location"] as? String {
                        return location
                    }
                }
                return ""
            }
            .receive(on: DispatchQueue.main)
            .map { data in
                return .success(data)
            }
            .catch { error in
                Just(.failure(error))
            }
            .eraseToAnyPublisher()
    }
}

extension SimplexService: URLSessionDelegate, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Swift.Void) {
        completionHandler(nil)
    }
}

extension SimplexService {
    enum RequestType: EndPointType {
        case quote
        case payment
        case checkout
        var baseURL: String {
            switch self {
            case .quote, .payment :
                return "https://iframe.simplex-affiliates.com/api/"
            case .checkout:
                return "https://checkout.simplexcc.com"
            }
        }

        var path: String {
            switch self {
            case .quote:
                return "quote"
            case .payment:
                return "payment"
            case .checkout:
                return "/payments/new?widget=true&sdk_version=v1.0.9&public_key=\(AppConstant.simplexApiKey)"
            }
        }

        var httpMethod: HTTPMethod {
            switch self {
            case .quote, .payment, .checkout:
                return .post
            }
        }

        var headers: [String: String] {
            switch self {
            case .quote, .payment:
                return NetworkHelper.httpPreTokenHeader
            case .checkout:
                return NetworkHelper.httpFormHeader
            }
        }
    }
}
