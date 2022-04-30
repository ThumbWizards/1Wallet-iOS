//
//  MultisigService.swift
//  Timeless-wallet
//
//  Created by Vinh Dang on 1/25/22.
//

import Foundation
import Combine
import web3swift
import BigInt

class MultisigService: BaseRestAPI<MultisigService.RequestType>, MultisigServiceProtocol {
    let web3Service: Web3Service
    static let shared = MultisigService(Web3Service.shared)

    // Addresses copied from
    //  https://github.com/harmony-one/multisig-react/blob/09a4eb00c74876151514e5514e2fd9af623cbc5d/src/logic/contracts/safeContracts.ts
    // swiftlint:disable inclusive_language
    let gnosisSafeMasterAddress = EthereumAddress("0x3736aC8400751bf07c6A2E4db3F4f3D9D422abB2")!
    let gnosisSafeProxyFactoryAddress = EthereumAddress("0x4f9b1dEf3a0f6747bF8C870a27D3DeCdf029100e")!
    let fallbackHandlerAddress = EthereumAddress("0xC5d654bcE1220241FCe1f0F1D6b9E04f75175452")!
    let emptyAddress = EthereumAddress("0x0000000000000000000000000000000000000000")!

    private init(_ web3: Web3Service) {
        self.web3Service = web3
    }

    // swiftlint:disable function_body_length
    func createSafe(wallet: OneWalletService.WalletData,
                    owners: [EthereumAddress],
                    threshold: Int,
                    chatRoomId: String,
                    metadata: [String: String]) -> AnyPublisher<EthereumAddress, MultisigError> {
         let salt = Int(Date().timeIntervalSince1970)

        let safeSetupParams = [owners, // owners
                               threshold, // threshold
                               emptyAddress, // to
                               Data(), // data
                               fallbackHandlerAddress, // fallbackHandler
                               emptyAddress, // paymentToken
                               0, // payment
                               emptyAddress] as [AnyObject] // paymentReceiver
        guard let safeSetupTx = gnosisSafeContract.method("setup", parameters: safeSetupParams),
              let deployTx = gnosisSafeProxyFactoryContract.method(
                "createProxyWithNonce",
                parameters: [gnosisSafeMasterAddress,
                             safeSetupTx.data,
                             salt] as [AnyObject]) else {
                                 return Fail(error: .web3Error).eraseToAnyPublisher()
        }
        let callData = deployTx.data.bytes
        return OneWalletService.shared.callExternalMethod(wallet: wallet,
                                                          amount: 0,
                                                          contractAddress: gnosisSafeProxyFactoryAddress,
                                                          method: "createProxyWithNonce",
                                                          data: callData)
            .mapError { _ in .web3Error }
            .flatMap { [weak self] res -> AnyPublisher<EthereumAddress, MultisigError> in
                guard let self = self,
                      let txId = res.txId else {
                          return Fail(error: .web3Error).eraseToAnyPublisher()
                }
                return self.web3Service.web3Instance.eth.getTransactionReceiptPromise(txId)
                    .publisher
                    .tryMap { receipt in
                        for log in receipt.logs {
                            let (eventName, eventData) = self.gnosisSafeProxyFactoryContract.parseEvent(log)
                            if eventName == "ProxyCreation" {
                                guard let safeAddress = eventData?["proxy"] as? EthereumAddress else {
                                    throw MultisigError.web3Error
                                }
                                return safeAddress
                            }
                        }
                        throw MultisigError.web3Error
                    }
                    .mapError { _ in .web3Error }
                    .eraseToAnyPublisher()
            }
            .flatMap { [weak self] safeAddress -> AnyPublisher<EthereumAddress, MultisigError> in
                guard let self = self else {
                    return Fail(error: .web3Error).eraseToAnyPublisher()
                }
                let safeParams = ["address": safeAddress.address,
                                  "creator": wallet.address.address,
                                  "owners": owners.map { $0.address },
                                  "threshold": threshold,
                                  "chat_room_id": chatRoomId,
                                  "metadata": metadata] as [String: Any]
                return self.call(type: .newSafe, params: safeParams)
                    .map { _ in
                        return safeAddress
                    }
                    .mapError { $0 as? MultisigError ?? .web3Error }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func generateTxHash(safeAddress: EthereumAddress, safeTx: SafeTx) throws -> [UInt8] {
        let domainSeparator = EIP712Domain(verifyingContract: safeAddress)
        let data = try eip712encode(domainSeparator: domainSeparator, message: safeTx)
        return data.bytes
    }

    func initiateTransfer(wallet: OneWalletService.WalletData,
                          safeAddress: EthereumAddress,
                          amount: BigUInt,
                          recipient: EthereumAddress) -> AnyPublisher<TxData, MultisigError> {
        guard let nonce = try? nextNonce(for: safeAddress) else {
            return Fail(error: .web3Error).eraseToAnyPublisher()
        }
        let safeTx = SafeTx(to: recipient,
                            value: amount,
                            data: Data(),
                            operation: 0,
                            safeTxGas: 0, // TODO: Update
                            baseGas: 0,
                            gasPrice: 0,
                            gasToken: emptyAddress,
                            refundReceiver: emptyAddress,
                            nonce: nonce)
        return approveTransfer(wallet: wallet, safeAddress: safeAddress, safeTx: safeTx)
            .mapError { _ in .web3Error }
            .flatMap { [weak self] res -> AnyPublisher<TxData, MultisigError> in
                guard let self = self,
                      res.txId != nil else {
                          return Fail(error: .web3Error).eraseToAnyPublisher()
                }
                let txParams = ["creator": wallet.address.address,
                                "amount": String(amount),
                                "recipient": recipient.address,
                                "nonce": String(nonce),
                                "safe_tx_gas": "0"]
                return self.call(type: .initiateTransfer(safeAddress: safeAddress.address), params: txParams)
                    .map { $0.data }
                    .decodeFromJson(TxData.self)
                    .mapError { _ in .web3Error }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func approveTransfer(wallet: OneWalletService.WalletData,
                         safeAddress: EthereumAddress,
                         txData: TxData) -> AnyPublisher<TxData, MultisigError> {
        return approveTransfer(wallet: wallet, safeAddress: safeAddress, safeTx: txData.toSafeTx())
            .mapError { _ in .web3Error }
            .flatMap { _ -> AnyPublisher<TxData, MultisigError> in
                let txParams = ["user": wallet.address.address,
                                "approved": true] as [String: Any]
                return self.call(type: .updateTransfer(safeAddress: safeAddress.address,
                                                       transactionId: txData.id), params: txParams)
                    .map { $0.data }
                    .decodeFromJson(TxData.self)
                    .mapError {
                        if $0.code == HTTPStatusCode.noInternetConnection.rawValue {
                            return .noInternet
                        } else {
                            return $0 as? MultisigError ?? .web3Error
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func approveTransfer(wallet: OneWalletService.WalletData,
                         safeAddress: EthereumAddress,
                         safeTx: SafeTx) -> AnyPublisher<OneWalletService.APIResponse, OneWalletService.CommitRevealError> {
        let safeInstance = gnosisSafeInstance(safeAddress: safeAddress)
        // swiftlint:disable identifier_name
        guard let txHash = try? generateTxHash(safeAddress: safeAddress, safeTx: safeTx),
              let tx = safeInstance.method("approveHash", parameters: [txHash] as [AnyObject]) else {
                  return Fail(error: OneWalletService.CommitRevealError.web3Error).eraseToAnyPublisher()
        }
        return OneWalletService.shared.callExternalMethod(wallet: wallet,
                                                          amount: 0,
                                                          contractAddress: safeAddress,
                                                          method: "approveHash",
                                                          data: tx.data.bytes)
    }

    func rejectTransfer(wallet: OneWalletService.WalletData,
                        safeAddress: EthereumAddress,
                        txData: TxData) -> AnyPublisher<TxData, MultisigError> {
        let txParams = ["user": wallet.address.address, "approved": false] as [String: Any]
        return self.call(type: .updateTransfer(safeAddress: safeAddress.address, transactionId: txData.id), params: txParams)
            .map { $0.data }
            .decodeFromJson(TxData.self)
            .mapError { _ in .web3Error }
            .eraseToAnyPublisher()
    }

    func pendingTransfer(address: String) -> AnyPublisher<[MultiSigQueue], MultisigError> {
        return call(type: .pendingTransactions(address: address), params: nil)
            .map { $0.data }
            .decodeFromJson([MultiSigQueue].self)
            .mapError {
                if $0.code == HTTPStatusCode.noInternetConnection.rawValue {
                    return .noInternet
                } else {
                    return $0 as? MultisigError ?? .web3Error
                }
            }
            .eraseToAnyPublisher()
    }

    func executeTransfer(wallet: OneWalletService.WalletData,
                         safeAddress: EthereumAddress,
                         txData: TxData) -> AnyPublisher<TxData, MultisigError> {
        let safeInstance = gnosisSafeInstance(safeAddress: safeAddress)
        var sigs = Data()
        for approvalAddress in txData.approvals.map({ $0.lowercased() }).sorted() {
            sigs += Data(count: 12) + EthereumAddress(approvalAddress)!.addressData + Data(count: 32) + Data(repeating: 1, count: 1)
        }
        let safeTx = txData.toSafeTx()
        let txParams = [safeTx.to,
                        safeTx.value,
                        safeTx.data,
                        safeTx.operation,
                        safeTx.safeTxGas,
                        safeTx.baseGas,
                        safeTx.gasPrice,
                        safeTx.gasToken,
                        safeTx.refundReceiver,
                        sigs] as [AnyObject]
        // swiftlint:disable identifier_name
        guard let tx = safeInstance.method("execTransaction", parameters: txParams) else {
            return Fail(error: .web3Error).eraseToAnyPublisher()
        }
        return OneWalletService.shared.callExternalMethod(wallet: wallet,
                                                          amount: 0,
                                                          contractAddress: safeAddress,
                                                          method: "execTransaction",
                                                          data: tx.data.bytes)
            .mapError { _ in .web3Error }
            .flatMap { res -> AnyPublisher<TxData, MultisigError> in
                let txParams = ["user": wallet.address.address,
                                "tx_id": res.txId as Any] as [String: Any]
                return self.call(type: .updateTransfer(safeAddress: safeAddress.address,
                                                       transactionId: txData.id), params: txParams)
                    .map { $0.data }
                    .decodeFromJson(TxData.self)
                    .mapError { _ in .web3Error }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    override func createPublisher(
        for request: URLRequest,
        type: RequestType,
        requestModifier:@escaping RequestModifier) -> URLSession.ErasedDataTaskPublisher {
            // TODO: Refactor duplicated code
            Future<URLRequest, Error> { promise in
                promise(.success(request))
                // There is no authentication requires for now
                // promise(.failure(API.APIError.unauthorized))
            }.eraseToAnyPublisher()
                .flatMap { [self] in
                    urlSession.erasedDataTaskPublisher(for: requestModifier($0))
                }
                .eraseToAnyPublisher()
        }
}

extension MultisigService {
    var gnosisSafeContract: EthereumContract {
        EthereumContract(web3Service.gnosisSafeAbi, at: gnosisSafeMasterAddress)!
    }

    var gnosisSafeProxyFactoryContract: EthereumContract {
        EthereumContract(web3Service.gnosisSafeProxyFactoryAbi, at: gnosisSafeProxyFactoryAddress)!
    }

    func gnosisSafeInstance(safeAddress: EthereumAddress) -> EthereumContract {
        EthereumContract(web3Service.gnosisSafeAbi, at: safeAddress)!
    }

    func nextNonce(for safeAddress: EthereumAddress) throws -> BigUInt {
        let safeInstance = web3Service.web3Instance.contract(web3Service.gnosisSafeAbi, at: safeAddress, abiVersion: 2)!
        guard let nonceTx = safeInstance.read("nonce") else {
            throw MultisigError.web3Error
        }
        guard let result = try? nonceTx.call(),
              let nonce = result["0"] as? BigUInt else {
                  throw MultisigError.web3Error
        }
        return nonce
    }
}

extension MultisigService {
    enum RequestType: EndPointType {
        case newSafe
        case initiateTransfer(safeAddress: String)
        case getTransfer(safeAddress: String, transactionId: String)
        case updateTransfer(safeAddress: String, transactionId: String)
        case pendingTransactions(address: String)

        var baseURL: String {
            AppConstant.serverURL
        }

        var version: String {
            "v1/"
        }

        var path: String {
            switch self {
            case .newSafe:
                return "safes/"
            case .initiateTransfer(let safeAddress):
                return "safes/\(safeAddress)/transactions/"
            case let .getTransfer(safeAddress, transactionId):
                return "safes/\(safeAddress)/transactions/\(transactionId)/"
            case let .updateTransfer(safeAddress, transactionId):
                return "safes/\(safeAddress)/transactions/\(transactionId)/"
            case let .pendingTransactions(address):
                return "safes/pending_transactions/?wallet_address=\(address)"
            }
        }

        var httpMethod: HTTPMethod {
            switch self {
            case .newSafe, .initiateTransfer:
                return .post
            case .getTransfer, .pendingTransactions:
                return .get
            default:
                return .put
            }
        }

        var headers: [String: String] {
            return NetworkHelper.httpWalletHeader
        }
    }

    struct TxData: Codable {
        let id: String
        let amount: String
        let recipient: String
        let nonce: String
        let safeTxGas: String
        let approvals: [String]
        let rejections: [String]
        let txId: String?

        enum CodingKeys: String, CodingKey {
            case id, amount, recipient, nonce, approvals, rejections
            case safeTxGas = "safe_tx_gas"
            case txId = "tx_id"
        }
    }
}

extension MultisigService.TxData {
    func toSafeTx() -> SafeTx {
        SafeTx(to: EthereumAddress(recipient)!,
               value: BigUInt(amount)!,
               data: Data(),
               operation: 0,
               safeTxGas: BigUInt(safeTxGas)!,
               baseGas: 0,
               gasPrice: 0,
               gasToken: EthereumAddress("0x0000000000000000000000000000000000000000")!,
               refundReceiver: EthereumAddress("0x0000000000000000000000000000000000000000")!,
               nonce: BigUInt(nonce)!)
    }
}
