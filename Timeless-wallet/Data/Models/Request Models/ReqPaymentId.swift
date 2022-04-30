//
//  ReqPaymentId.swift
//  Timeless-wallet
//
//  Created by Tu Nguyen on 1/12/22.
//

import Foundation

class ReqPaymentId {
    var walletaddress: String?
    var quoteResponse: QuoteSimplex?

    func toDictionary() -> [String: Any] {
        var dictOut = [String: Any]()
        dictOut["walletaddress"] = walletaddress
        dictOut["walletaddresstag"] = ""
        dictOut["last_quote_response"] = lastResponse
        dictOut["g-recaptcha-response"] = ""
        dictOut["abTests"] = [String: String]()
        dictOut["hostname"] = "https://www.harmony.one/"

        return dictOut
    }

    var lastResponse: [String: Any] {
        var res = [String: Any]()
        var fiat = [String: Any]()
        var digital = [String: Any]()
        fiat["currency"] = quoteResponse?.fiatMoney?.currency
        fiat["base_amount"] = quoteResponse?.fiatMoney?.baseAmount
        fiat["total_amount"] = quoteResponse?.fiatMoney?.totalAmount
        fiat["amount"] = quoteResponse?.fiatMoney?.amount
        digital["currency"] = quoteResponse?.digitalMoney?.currency
        digital["amount"] = quoteResponse?.digitalMoney?.amount
        res["user_id"] = quoteResponse?.userID
        res["quote_id"] = quoteResponse?.quoteID
        res["digital_money"] = digital
        res["fiat_money"] = fiat
        res["supported_digital_currencies"] = quoteResponse?.supportedDigitalCurrencies
        res["supported_fiat_currencies"] = quoteResponse?.supportedFiatCurrencies

        return res
    }
}
