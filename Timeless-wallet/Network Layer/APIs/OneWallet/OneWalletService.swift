//
//  OneWalletService.swift
//  Timeless-wallet
//
//  Created by Vo Trong Nghia on 26/10/2021.
//

import Foundation
import Combine
import web3swift
import BigInt
import CryptoSwift
import CryptoKit

// swiftlint:disable type_body_length
class OneWalletService: BaseRestAPI<OneWalletService.RequestType>, OneWalletServiceProtocol {
    static let shared = OneWalletService()
    static let weiUnit = 1_000_000_000_000_000_000 // 10^18
    static let sushiONEContractAddress = EthereumAddress("0xcF664087a5bB0237a0BAd6742852ec6c8d69A27a")!
    var subscriptionQueue: DispatchQueue

    override private init() {
        subscriptionQueue = DispatchQueue(
            label: "One Wallet Service",
            qos: .default
        )
    }

    var newWallet: AnyPublisher<Result<Wallet, OneWalletService.NewWalletError>, Never> {
        guard let seed = CryptoHelper.shared.newWalletSeed,
              let req = CryptoHelper.shared.newWalletReq else {
                  return Just(.failure(OneWalletService.NewWalletError.missingWalletPayload)).eraseToAnyPublisher()
              }
        CryptoHelper.shared.viewModel.onboardWalletState = .pingingHarmonyChain
        return self.call(type: .newWallet, params: req.toDictionary())
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(Wallet.self)
            .receive(on: DispatchQueue.main)
            .map { wallet in
                guard wallet.isValid else {
                    return .failure(OneWalletService.NewWalletError.missingWalletAddress)
                }
                CryptoHelper.shared.viewModel.onboardWalletState = .chainPinged(wallet: wallet,
                                                                                seed: seed,
                                                                                t0: req.t0)
                return .success(wallet)
            }
            .catch { error in
                Just(.failure((error as? OneWalletService.NewWalletError) ?? .apiBorked))
            }
            .eraseToAnyPublisher()
    }

    func transferWithProgress(from wallet: WalletData? = nil,
                              to destination: EthereumAddress,
                              amount: BigUInt) -> AnyPublisher<CommitRevealProgress, CommitRevealError> {
        guard let walletData = wallet ?? getCurrentUserWalletData() else {
            return Fail(error: .unknownError).eraseToAnyPublisher()
        }
        let paramsHash = calculateTransferParamsHash(dest: destination, amount: amount)
        guard let commitData = try? prepareCommitData(wallet: walletData, paramsHash: paramsHash) else {
            return Fail(error: .unknownError).eraseToAnyPublisher()
        }
        return commitReveal(wallet: walletData,
                            commitData: commitData,
                            operationType: 4, // TRANSFER
                            tokenType: TokenType.none.id, // NONE
                            tokenId: 0,
                            dest: destination,
                            amount: amount)
    }

    func getCurrentUserWalletData() -> WalletData? {
        guard let wallet = Wallet.currentWallet,
              let markleTree = Wallet.currentMerkleTree,
              let myWalletAddress = EthereumAddress(wallet.address.convertBech32ToEthereum()) else {
                  return nil
              }
        do {
            var effectiveTime = wallet.effectiveTime
            if effectiveTime == nil {
                let walletInfo = try OneWalletService.shared.getWalletInfo(address: myWalletAddress)
                effectiveTime = Date(timeIntervalSince1970: TimeInterval(walletInfo.t0 * 30))
                Wallet.allEffectiveTimes[wallet.address] = effectiveTime
            }
            let walletData = OneWalletService.WalletData(address: myWalletAddress,
                                                         merkleTree: markleTree,
                                                         effectiveTime: effectiveTime!)
            return walletData
        } catch {
            return nil
        }
    }

    func getUserWalletData(for wallet: Wallet) -> WalletData? {
        guard let merkleTree = wallet.merkelTree,
              let myWalletAddress = EthereumAddress(wallet.address.convertBech32ToEthereum()) else {
                  return nil
              }
        do {
            var effectiveTime = wallet.effectiveTime
            if effectiveTime == nil {
                let walletInfo = try OneWalletService.shared.getWalletInfo(address: myWalletAddress)
                effectiveTime = Date(timeIntervalSince1970: TimeInterval(walletInfo.t0 * 30))
                Wallet.allEffectiveTimes[wallet.address] = effectiveTime
            }
            let walletData = OneWalletService.WalletData(address: myWalletAddress,
                                                         merkleTree: merkleTree,
                                                         effectiveTime: effectiveTime!)
            return walletData
        } catch {
            return nil
        }
    }

    func callExternalMethod(wallet: WalletData,
                            amount: BigUInt,
                            contractAddress: EthereumAddress,
                            method: String,
                            data: [UInt8]) -> AnyPublisher<APIResponse, CommitRevealError> {
        let operationType = 21 // CALL
        let emptyAddress = EthereumAddress("0x0000000000000000000000000000000000000000")!
        let paramsHash = calculateGeneralParamsHash(operationType: operationType,
                                                    tokenType: TokenType.none.id,
                                                    contractAddress: contractAddress,
                                                    tokenId: 0,
                                                    dest: emptyAddress,
                                                    amount: amount,
                                                    data: data)
        guard let commitData = try? prepareCommitData(wallet: wallet, paramsHash: paramsHash) else {
            return Fail(error: .unknownError).eraseToAnyPublisher()
        }

        return commitReveal(wallet: wallet,
                            commitData: commitData,
                            operationType: operationType,
                            tokenType: TokenType.none.id,
                            contractAddress: contractAddress,
                            tokenId: 0,
                            dest: emptyAddress,
                            amount: amount,
                            data: "0x" + data.toHexString())
            .last()
            .map { progress -> APIResponse in
                if case.done(let txId) = progress {
                    return APIResponse(
                        success: true,
                        error: nil,
                        txId: txId
                    )
                }
                return APIResponse(
                    success: false,
                    error: "Something went wrong",
                    txId: nil
                )
            }
            .eraseToAnyPublisher()
    }

    func callExternalMethodWithProgress(wallet: WalletData,
                                        amount: BigUInt,
                                        contract: web3.web3contract,
                                        method: String,
                                        parameters: [AnyObject]) -> AnyPublisher <CommitRevealProgress, CommitRevealError> {
        guard let methodTx = contract.method(method, parameters: parameters),
              let contractAddress = contract.transactionOptions?.to else {
                  return Fail(error: CommitRevealError.web3Error).eraseToAnyPublisher()
              }
        let data = methodTx.transaction.data.bytes
        let operationType = 21 // CALL
        let emptyAddress = EthereumAddress("0x0000000000000000000000000000000000000000")!
        let paramsHash = calculateGeneralParamsHash(operationType: operationType,
                                                    tokenType: TokenType.none.id,
                                                    contractAddress: contractAddress,
                                                    tokenId: 0,
                                                    dest: emptyAddress,
                                                    amount: amount,
                                                    data: data)
        guard let commitData = try? prepareCommitData(wallet: wallet, paramsHash: paramsHash) else {
            return Fail(error: .unknownError).eraseToAnyPublisher()
        }

        return commitReveal(wallet: wallet,
                            commitData: commitData,
                            operationType: operationType,
                            tokenType: TokenType.none.id,
                            contractAddress: contractAddress,
                            tokenId: 0,
                            dest: emptyAddress,
                            amount: amount,
                            data: "0x" + data.toHexString())
    }

    func createSignature(wallet: WalletData, message: String) -> AnyPublisher<MessageSignature, CommitRevealError> {
        let operationType = 19 // SIGN
        let emptyAddress = EthereumAddress("0x0000000000000000000000000000000000000000")!
        let messageHash = [UInt8](message.utf8).sha3(.keccak256)
        let hashBigInt = BigUInt(Data(messageHash))
        let expiryBytes: [UInt8] = [0xff, 0xff, 0xff, 0xff] + [UInt8](repeating: 0, count: 16)
        let expiryEncoded = EthereumAddress(Data(expiryBytes))!
        // tokenId: message-hash, keccak(message)
        // dest: expiry-at, padding to eth address
        // amount: signature, keccak(eotp + hash)
        let commitData = try? prepareCommitData(wallet: wallet, paramsHash: nil) { eotp in
            let input = eotp + messageHash
            let signature = input.sha3(.keccak256)
            return self.calculateGeneralParamsHash(operationType: operationType,
                                                   tokenType: TokenType.none.id,
                                                   contractAddress: emptyAddress,
                                                   tokenId: hashBigInt,
                                                   dest: expiryEncoded,
                                                   amount: BigUInt(Data(signature)),
                                                   data: [])
        }
        guard let commitData = commitData else {
            return Fail(error: .unknownError).eraseToAnyPublisher()
        }
        // TODO: Refactor code to remove the repeated code below
        let signature = (commitData.eotp + messageHash).sha3(.keccak256)
        let signatureBigInt = BigUInt(Data(signature))

        return commitReveal(wallet: wallet,
                            commitData: commitData,
                            operationType: operationType,
                            tokenType: TokenType.none.id,
                            tokenId: hashBigInt,
                            dest: expiryEncoded,
                            amount: signatureBigInt)
            .last()
            .flatMap { [weak self] progress -> AnyPublisher<MessageSignature, CommitRevealError> in
                if let self = self,
                   case .done(let txId) = progress,
                   let txId = txId {
                    return self.getTxStatus(txId,
                                       walletAddress: wallet.address.address,
                                       isOneTransfer: false)
                        .tryMap { status in
                            guard status == .ok else {
                                throw CommitRevealError.unknownError
                            }
                            return MessageSignature(message: message, hash: messageHash, signature: signature, expiry: nil)
                        }
                        .mapError {
                            $0 as? CommitRevealError ?? .unknownError
                        }
                        .eraseToAnyPublisher()
                }
                return Fail(error: CommitRevealError.unknownError).eraseToAnyPublisher()
            }
            .mapError {
                $0 as? CommitRevealError ?? .unknownError
            }
            .eraseToAnyPublisher()
    }

    // swiftlint:disable function_parameter_count
    func swapONEToToken(wallet: WalletData,
                        token: Web3Service.Erc20Token,
                        amountIn: BigUInt,
                        expectedAmountOut: BigUInt,
                        slippage: Double,
                        deadline: TimeInterval) -> AnyPublisher<APIResponse, CommitRevealError> {
        // swiftlint:disable number_separator
        let reverseSlippage = BigUInt((1 - slippage) * 100_00)
        let expectedAmountOutWithSlippage = expectedAmountOut * reverseSlippage / BigUInt(100_00)
        let callParameters = [
            expectedAmountOutWithSlippage,
            [OneWalletService.sushiONEContractAddress, token.contractAddress],
            wallet.address,
            Int(Date(timeIntervalSinceNow: deadline).timeIntervalSince1970)
        ] as [AnyObject]
        guard let sushiContract = Web3Service.shared.sushiSwapContract,
              let methodTx = sushiContract.method("swapExactETHForTokens",
                                                  parameters: callParameters) else {
                  return Fail(error: CommitRevealError.web3Error).eraseToAnyPublisher()
              }
        let data = methodTx.transaction.data.bytes
        return callExternalMethod(wallet: wallet,
                                  amount: amountIn,
                                  contractAddress: Web3Service.shared.sushiSwapRouterAddress,
                                  method: "swapExactETHForTokens",
                                  data: data)
    }

    // swiftlint:disable function_parameter_count
    func swapTokenToONE(wallet: WalletData,
                        token: Web3Service.Erc20Token,
                        amountIn: BigUInt,
                        expectedAmountOut: BigUInt,
                        slippage: Double,
                        deadline: TimeInterval) -> AnyPublisher<APIResponse, CommitRevealError> {
        // swiftlint:disable number_separator
        let reverseSlippage = BigUInt((1 - slippage) * 100_00)
        let expectedAmountOutWithSlippage = expectedAmountOut * reverseSlippage / BigUInt(100_00)
        guard let sushiContract = Web3Service.shared.sushiSwapContract else {
            return Fail(error: CommitRevealError.web3Error).eraseToAnyPublisher()
        }
        return Web3Service.shared.getTokenAllowance(for: token,
                                                       at: wallet.address,
                                                       spender: Web3Service.shared.sushiSwapRouterAddress)
            .mapError { $0 as? CommitRevealError ?? .web3Error }
            .flatMap { [self] allowance -> AnyPublisher<Bool, CommitRevealError> in
                if allowance < amountIn {
                    // keep track of current time so that we can ensure the 2nd commit-reveal flow
                    //  doesn't overlap with the 1st one (we can only do 1 "transaction" every 30s)
                    let now = Date() + TimeInterval(2) // Add 2s to the future as safeguard
                    let nextInterval = Date(timeIntervalSince1970: (floor(now.timeIntervalSince1970 / 30) + 1) * 30)
                    let maxAmountData = Data([UInt8](repeating: 0xff, count: 32))
                    return approveTokenAllowance(wallet: wallet,
                                                 token: token,
                                                 spender: Web3Service.shared.sushiSwapRouterAddress,
                                                 amount: BigUInt(maxAmountData))
                        .flatMap { approved -> AnyPublisher<Bool, CommitRevealError> in
                            return Just(approved)
                                .setFailureType(to: CommitRevealError.self)
                                .delay(for: .seconds(max(nextInterval.timeIntervalSinceNow, 0)),
                                          scheduler: self.subscriptionQueue)
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
                return Just(true).setFailureType(to: CommitRevealError.self).eraseToAnyPublisher()
            }
            .flatMap { [self] _ -> AnyPublisher<APIResponse, CommitRevealError> in
                let callParameters = [
                    amountIn,
                    expectedAmountOutWithSlippage,
                    [token.contractAddress, OneWalletService.sushiONEContractAddress],
                    wallet.address,
                    Int(Date(timeIntervalSinceNow: deadline).timeIntervalSince1970)
                ] as [AnyObject]
                guard let methodTx = sushiContract.method("swapExactTokensForETH", parameters: callParameters) else {
                    return Fail(error: CommitRevealError.web3Error).eraseToAnyPublisher()
                }
                let data = methodTx.transaction.data.bytes
                return callExternalMethod(wallet: wallet,
                                          amount: 0,
                                          contractAddress: Web3Service.shared.sushiSwapRouterAddress,
                                          method: "swapExactTokensForETH",
                                          data: data)
            }
            .eraseToAnyPublisher()
    }

    func approveTokenAllowance(wallet: OneWalletService.WalletData,
                               token: Web3Service.Erc20Token,
                               spender: EthereumAddress,
                               amount: BigUInt) -> AnyPublisher <Bool, CommitRevealError> {
        let callParameters = [spender, amount] as [AnyObject]
        guard let tokenContract = Web3Service.shared.erc20Contract(at: token.contractAddress),
              let methodTx = tokenContract.method("approve",
                                                  parameters: callParameters) else {
                  return Fail(error: CommitRevealError.web3Error).eraseToAnyPublisher()
              }
        let data = methodTx.transaction.data.bytes
        return callExternalMethod(wallet: wallet,
                                  amount: 0,
                                  contractAddress: token.contractAddress,
                                  method: "approve",
                                  data: data)
            .flatMap { [self] _ -> AnyPublisher<Bool, CommitRevealError> in
                return verifyTokenAllowance(wallet: wallet, token: token,
                                            amount: amount, spender: spender, retries: 3, delay: 2)
            }
            .eraseToAnyPublisher()
    }

    func getNFTTokens(walletAddress: EthereumAddress) -> AnyPublisher <[NFTInfo: [BigUInt]], Never> {
        let web3 = Web3Service.shared
        // swiftlint:disable identifier_name
        guard let contract = web3.oneWalletContract(at: walletAddress),
              let tx = contract.read("getTrackedTokens") else {
                  return Just([:]).eraseToAnyPublisher()
              }
        return tx.callPromise(transactionOptions: web3.defaultTransactionOptions)
            .publisher
            .map { result -> [EthereumAddress: (type: NFTType, tokens: [BigUInt])] in
                guard let tokenTypes = result["0"] as? [BigUInt],
                      let tokenAddresses = result["1"] as? [EthereumAddress],
                      let tokenIds = result["2"] as? [BigUInt] else {
                          return [:]
                      }
                var tokenMapping = [EthereumAddress: (type: NFTType, tokens: [BigUInt])]()
                for i in 0..<tokenTypes.count {
                    // token type: 0=ERC20, 1=ERC721, 2=ERC1155, 3=NONE
                    var tokenType: NFTType
                    switch tokenTypes[i] {
                    case 1:
                        tokenType = .erc721
                    case 2:
                        tokenType = .erc1155
                    default:
                        continue
                    }
                    let tokenAddress = tokenAddresses[i], tokenId = tokenIds[i]
                    if tokenMapping[tokenAddress] == nil {
                        tokenMapping[tokenAddress] = (type: tokenType, tokens: [])
                    }
                    tokenMapping[tokenAddress]!.tokens += [tokenId]
                }
                return tokenMapping
            }
            .flatMap { tokensMapping -> AnyPublisher<[NFTInfo: [BigUInt]], Never> in
                let tokenAddresses = Array(tokensMapping.keys)
                var tokenInfoFetches = [AnyPublisher<NFTInfo, Never>]()
                for address in tokenAddresses {
                    let tokenData = tokensMapping[address]!
                    tokenInfoFetches += [NFTService.shared.contractDetails(contractAddress: address, tokenType: tokenData.type)]
                }
                return Publishers.SafeZipMany(tokenInfoFetches)
                    .map { contractsData -> [NFTInfo: [BigUInt]] in
                        var contractsMapping = [NFTInfo: [BigUInt]]()
                        for idx in 0..<contractsData.count {
                            switch contractsData[idx] {
                            case .success(let contractData):
                                let tokenAddress = tokenAddresses[idx]
                                contractsMapping[contractData] = tokensMapping[tokenAddress]!.tokens
                            default:
                                continue
                            }
                        }
                        return contractsMapping
                    }
                    .eraseToAnyPublisher()
            }
            .replaceError(with: [:])
            .eraseToAnyPublisher()
    }

    func getWalletInfo(address: EthereumAddress) throws -> WalletPublicInfo {
        let web3 = Web3Service.shared
        // swiftlint:disable identifier_name
        guard let contract = web3.oneWalletContract(at: address),
              let tx = contract.read("getInfo") else {
                  throw GeneralError.web3Error
              }
        let result = try tx.call(transactionOptions: web3.defaultTransactionOptions)
        // root, height, interval, t0, lifespan, maxOperationsPerInterval, lastResortAddress, -- dailyLimit
        guard let root = result["0"] as? Data,
              let height = result["1"] as? BigUInt,
              let interval = result["2"] as? BigUInt,
              let t0 = result["3"] as? BigUInt,
              let lifespan = result["4"] as? BigUInt,
              let maxOperationsPerInterval = result["5"] as? BigUInt,
              let lastResortAddress = result["6"] as? EthereumAddress else {
                  throw GeneralError.web3Error
              }
        return WalletPublicInfo(
            root: root.bytes,
            height: Int(height),
            interval: Int(interval),
            t0: Int(t0),
            lifespan: Int(lifespan),
            maxOperationsPerInterval: Int(maxOperationsPerInterval),
            lastResortAddress: lastResortAddress)
    }

    func getWalletVersion(address: EthereumAddress) throws -> (major: Int, minor: Int) {
        let web3 = Web3Service.shared
        let contract = web3.oneWalletContract(at: address)
        // swiftlint:disable identifier_name
        let tx = contract?.read("getVersion")
        guard let result = try tx?.call(transactionOptions: web3.defaultTransactionOptions),
              let majorVersion = result["0"] as? BigUInt,
              let minorVersion = result["1"] as? BigUInt else {
                  throw GeneralError.web3Error
              }
        return (Int(majorVersion), Int(minorVersion))
    }

    func verifySignature(address: EthereumAddress, message: String, signature: [UInt8]) throws -> Bool {
        let web3 = Web3Service.shared
        let messageHash = [UInt8](message.utf8).sha3(.keccak256)
        // swiftlint:disable identifier_name
        guard let contract = web3.oneWalletContract(at: address),
              let tx = contract.read("isValidSignature", parameters: [messageHash, signature] as [AnyObject]) else {
                  throw GeneralError.web3Error
              }
        let result = try tx.call(transactionOptions: web3.defaultTransactionOptions)
        //
        guard let output = result["0"] as? Data else {
            throw GeneralError.web3Error
        }
        // magic value for valid signature, eip-1271
        return output.bytes == [0x16, 0x26, 0xba, 0x7e]
    }

    func transactionHistory(address: EthereumAddress, page: Int = 0) -> AnyPublisher<(transactions: [TransactionInfo], nextPage: Int?), Error> {
        // TODO: Implement per the docs here:
        //  https://docs.harmony.one/home/developers/api/methods/transaction-related-methods/hmy_gettransactionshistory#api-v2
        guard let oneWalletContract = EthereumContract(Web3Service.shared.oneWalletAbi, at: address),
              let sushiContract = EthereumContract(Web3Service.shared.sushiSwapAbi, at: Web3Service.shared.sushiSwapRouterAddress) else {
            return Fail(error: GeneralError.web3Error).eraseToAnyPublisher()
        }
        return HarmonyService.shared.transactionHistory(for: address, page: page)
            .map { (rawTransactions, nextPage) in
                let transactions = rawTransactions.reduce(into: [TransactionInfo]()) { res, rawTx in
                    guard let params = oneWalletContract.decodeInputData(Data(rawTx.input)) else {
                        // either our abi is incomplete or this is a receive transaction
                        if rawTx.to == address && rawTx.value != 0 {
                            let tx = TransactionInfo(
                                type: .received,
                                from: rawTx.from,
                                to: rawTx.to,
                                token: nil,
                                amount: rawTx.value,
                                time: Date(timeIntervalSince1970: TimeInterval(rawTx.timestamp)))
                            res.append(tx)
                        }
                        return
                    }
                    guard let operation = params["op"] as? [AnyObject],
                          let operationType = operation[0] as? BigUInt,
                          let contractAddress = operation[2] as? EthereumAddress,
                          let dest = operation[4] as? EthereumAddress,
                          let amount = operation[5] as? BigUInt,
                          let callData = operation[6] as? Data else {
                              return
                    }
                    let isEmptyContract = contractAddress == EthereumAddress("0x0000000000000000000000000000000000000000")
                    // if we have "op" params, then this is a reveal transaction - check for error and decode the payload
                    // TODO: Call hmy_getTransactionReceipt for each of them to fetch final tx status

                    // Operations mapping:
//                    0: 'TRACK',
//                    1: 'UNTRACK',
//                    2: 'TRANSFER_TOKEN',
//                    3: 'OVERRIDE_TRACK',
//                    4: 'TRANSFER',
//                    5: 'SET_RECOVERY_ADDRESS',
//                    6: 'RECOVER',
//                    7: 'DISPLACE',
//                    8: 'UPGRADE',
//                    9: 'RECOVER_SELECTED_TOKENS',
//                    10: 'BUY_DOMAIN',
//                    11: 'COMMAND',
//                    12: 'BACKLINK_ADD',
//                    13: 'BACKLINK_DELETE',
//                    14: 'BACKLINK_OVERRIDE',
//                    15: 'RENEW_DOMAIN',
//                    16: 'TRANSFER_DOMAIN',
//                    17: 'RECLAIM_REVERSE_DOMAIN',
//                    18: 'RECLAIM_DOMAIN_FROM_BACKLINK',
//                    19: 'SIGN',
//                    20: 'REVOKE',
//                    21: 'CALL',
//                    22: 'BATCH'
                    // Tracking for now:
                    //  4: 'TRANSFER'
                    //  21: 'CALL' -- check contract address to identify swap
                    var tx: TransactionInfo
                    switch operationType {
                    case 4:
                        tx = TransactionInfo(type: .send,
                                             from: address,
                                             to: dest,
                                             token: nil,
                                             amount: amount,
                                             time: Date(timeIntervalSince1970: TimeInterval(rawTx.timestamp)))
                    case 21:
                        guard contractAddress == Web3Service.shared.sushiSwapRouterAddress,
                              let params = sushiContract.decodeInputData(callData),
                              let path = params["path"] as? [EthereumAddress] else {
                                  tx = TransactionInfo(type: .contract,
                                                       from: address,
                                                       to: isEmptyContract ? nil : contractAddress,
                                                       token: nil,
                                                       amount: amount,
                                                       time: Date(timeIntervalSince1970: TimeInterval(rawTx.timestamp)))
                                  break
                        }
                        let amountIn = (params["amountIn"] ?? params["amountInMax"]) as? BigUInt ?? amount
                        let tokenContractAddress = path[0]
                        let token = Web3Service.Erc20Token.allCases.first(where: { $0.contractAddress == tokenContractAddress })
                        if token != nil || tokenContractAddress == OneWalletService.sushiONEContractAddress {
                            tx = TransactionInfo(type: .swap,
                                                 from: address,
                                                 to: contractAddress,
                                                 token: token,
                                                 amount: amountIn,
                                                 time: Date(timeIntervalSince1970: TimeInterval(rawTx.timestamp)))
                        } else {
                            // Fallback to .contract type for unknown token swap
                            tx = TransactionInfo(type: .contract,
                                                 from: address,
                                                 to: isEmptyContract ? nil : contractAddress,
                                                 token: nil,
                                                 amount: amount,
                                                 time: Date(timeIntervalSince1970: TimeInterval(rawTx.timestamp)))
                        }
                    default:
                        tx = TransactionInfo(type: .contract,
                                             from: address,
                                             to: isEmptyContract ? nil : contractAddress,
                                             token: nil,
                                             amount: amount,
                                             time: Date(timeIntervalSince1970: TimeInterval(rawTx.timestamp)))
                    }
                    res.append(tx)
                }
                return (transactions: transactions, nextPage: nextPage)
            }
            .eraseToAnyPublisher()
    }

    func walletAssets(for address: EthereumAddress) -> AnyPublisher<[WalletAssetInfo], Error> {
        var assetsFetching = [AnyPublisher<BigUInt, Error>]()
        assetsFetching.append(Web3Service.shared.getBalance(at: address))
        let tokens = Web3Service.Erc20Token.allCases as [Web3Service.Erc20Token]
        for token in tokens {
            assetsFetching.append(Web3Service.shared.getErc20TokenBalance(for: token, at: address))
        }
        return Publishers.ZipMany(assetsFetching)
            .map { balances -> [(token: Web3Service.Erc20Token?, amount: BigUInt)] in
                var assets = [(token: Web3Service.Erc20Token?, amount: BigUInt)]()
                assets.append((token: nil, amount: balances[0]))
                for i in 0..<tokens.count {
                    let balance = balances[i + 1]
                    if balance > 0 {
                        assets.append((token: tokens[i], amount: balances[i + 1]))
                    }
                }
                return assets
            }
            .flatMap { assetsData -> AnyPublisher<[WalletAssetInfo], Error> in
                Publishers.ZipMany(assetsData.map { ExchangeRateService.shared.marketData(for: $0.token) })
                    .map { marketData -> [WalletAssetInfo] in
                        var assets = [WalletAssetInfo]()
                        for i in 0..<assetsData.count {
                            let assetData = assetsData[i]
                            let assetPrice = marketData[i]
                            var weiUnit: Int
                            if assetData.token != nil {
                                weiUnit = assetData.token!.weiUnit
                            } else {
                                weiUnit = OneWalletService.weiUnit
                            }
                            let displayAmount = Web3Service.shared.amountFromWeiUnit(amount: assetData.amount, weiUnit: weiUnit)
                            assets.append(WalletAssetInfo(token: assetData.token,
                                                          amount: assetData.amount,
                                                          displayAmount: displayAmount,
                                                          usdAmount: displayAmount * assetPrice.usdPrice,
                                                          priceChangePercentage24h: assetPrice.priceChangePercentage24h))
                        }
                        return assets
                    }
                    .mapError({ error -> Error in
                        return error
                    })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

extension OneWalletService {
    typealias ParamsHashBuilder = (_ eotp: [UInt8]) -> [UInt8]

    public func getEthereumAddress(_ value: String) -> EthereumAddress? {
        var result: EthereumAddress?
        let bech32 = Bech32()
        // Convert Bech32 Address to Ethereum Address
        if value.prefix(2) != "0x" {
            do {
                let decoded = try bech32.decode(value)
                let decodedData = try bech32.convertBits(from: 5, to: 8, pad: false, idata: decoded.checksum)
                result = EthereumAddress(decodedData)
            } catch {
                print("error", error)
            }
        } else {
            result = EthereumAddress(value)
        }
        return result
    }

    func prepareCommitData(wallet: WalletData, paramsHash: [UInt8]?, paramHashBuilder: ParamsHashBuilder? = nil) throws -> CommitData {
        guard paramsHash != nil || paramHashBuilder != nil else {
            // Invalid external call?
            throw CommitRevealError.unknownError
        }
        let now = Date()
        let effectiveTimeIndex = Int(floor(wallet.effectiveTime.timeIntervalSince1970 / 30))
        let otpIndex = Int(floor(now.timeIntervalSince1970 / 30))
        let index = otpIndex - effectiveTimeIndex

        guard let eotp = calculateEotp(wallet: wallet, otpIndex: otpIndex, index: index) else {
            // Invalid seed?
            throw CommitRevealError.unknownError
        }
        let neighbors = wallet.merkleTree.getNeighborsFor(index: index)
        let neighbor = neighbors[0]

        let commitHash = calculateCommitHash(neighbor: neighbor, index: index, eotp: eotp)
        let strongParamsHash = paramsHash ?? paramHashBuilder!(eotp)
        let verificationHash = calculateVerificationHash(paramsHash: strongParamsHash, eotp: eotp)
        return CommitData(
            index: index,
            eotp: eotp,
            neighbors: neighbors,
            hash: commitHash,
            paramsHash: strongParamsHash,
            verificationHash: verificationHash)
    }

    func commit(wallet: WalletData, commitData: CommitData) -> AnyPublisher<APIResponse, CommitRevealError> {
        let req = [
            "address": wallet.address.address,
            "hash": "0x" + commitData.hash.toHexString(),
            "paramsHash": "0x" + commitData.paramsHash.toHexString(),
            "verificationHash": "0x" + commitData.verificationHash.toHexString()
        ]
        return self.call(type: .commit, params: req)
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(APIResponse.self)
            .tryMap { res in
                if res.success ?? false {
                    return res
                } else {
                    throw CommitRevealError.unknownError
                }
            }
            .mapError {
                if $0.code == HTTPStatusCode.noInternetConnection.rawValue {
                    return .noInternet
                } else {
                    return $0 as? CommitRevealError ?? .unknownError
                }
            }
            .eraseToAnyPublisher()
    }

    func verifyCommit(wallet: WalletData,
                      data: CommitData,
                      retries: Int = 1,
                      delay: Int = 4) -> AnyPublisher<Void, CommitRevealError> {
        // swiftlint:disable identifier_name
        let web3 = Web3Service.shared
        guard let contract = web3.oneWalletContract(at: wallet.address),
              let tx = contract.read("lookupCommit", parameters: ["0x" + data.hash.toHexString()] as [AnyObject]) else {
                  return Fail(error: .web3Error).eraseToAnyPublisher()
              }
        var verifier: ((Int) -> AnyPublisher<Void, CommitRevealError>)!
        verifier = { [weak self] retriesLeft in
            guard let self = self else {
                return Fail(error: .unknownError).eraseToAnyPublisher()
            }
            return Deferred {
                tx.callPromise(transactionOptions: web3.defaultTransactionOptions)
                    .publisher
                    .mapError({ error -> OneWalletService.CommitRevealError in
                        if error.code == HTTPStatusCode.noInternetConnection.rawValue {
                            return .noInternet
                        } else {
                            return error as? CommitRevealError ?? .web3Error
                        }
                    })
                    .flatMap { result -> AnyPublisher<Void, CommitRevealError> in
                        guard let hashes = result["0"] as? [Data],
                              let paramsHashes = result["1"] as? [Data],
                              let verificationHashes = result["2"] as? [Data],
                              let timestamps = result["3"] as? [BigUInt],
                              let completeds = result["4"] as? [Bool] else {
                                  return Fail(error: .web3Error).eraseToAnyPublisher()
                              }
                        for i in 0..<hashes.count {
                            if paramsHashes[i].bytes == data.paramsHash && verificationHashes[i].bytes == data.verificationHash {
                                guard timestamps[i] > 0 else {
                                    return Fail(error: .corruptedTimestamp).eraseToAnyPublisher()
                                }
                                guard !completeds[i] else {
                                    return Fail(error: .commitAlreadyCompleted).eraseToAnyPublisher()
                                }
                                return Just(()).setFailureType(to: CommitRevealError.self).eraseToAnyPublisher()
                            }
                        }
                        if retriesLeft > 0 {
                            return Just(())
                                .delay(for: .seconds(delay), scheduler: self.subscriptionQueue)
                                .flatMap { _ in verifier(retriesLeft - 1) }
                                .eraseToAnyPublisher()
                        } else {
                            return Fail(error: .commitNotConfirmed)
                                .eraseToAnyPublisher()
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }
        return verifier(retries)
    }

    func verifyTokenAllowance(wallet: WalletData,
                              token: Web3Service.Erc20Token,
                              amount: BigUInt,
                              spender: EthereumAddress,
                              retries: Int = 1,
                              delay: Int = 4) -> AnyPublisher<Bool, CommitRevealError> {
        // swiftlint:disable identifier_name
        var verifier: ((Int) -> AnyPublisher<Bool, CommitRevealError>)!
        verifier = { [weak self] retriesLeft in
            guard let self = self else {
                return Fail(error: .unknownError).eraseToAnyPublisher()
            }
            return Web3Service.shared.getTokenAllowance(for: token,
                                                           at: wallet.address,
                                                           spender: spender)
                .mapError { $0 as? CommitRevealError ?? .web3Error }
                .flatMap { allowance -> AnyPublisher<Bool, CommitRevealError> in
                    return Just(allowance >= amount).setFailureType(to: CommitRevealError.self).eraseToAnyPublisher()
                }
                .flatMap { approved -> AnyPublisher<Bool, CommitRevealError> in
                    if !approved {
                        if retriesLeft > 0 {
                            return Just(())
                                .delay(for: .seconds(delay), scheduler: self.subscriptionQueue)
                                .flatMap { _ in verifier(retriesLeft - 1) }
                                .eraseToAnyPublisher()
                        } else {
                            return Fail(error: .web3Error)
                                .eraseToAnyPublisher()
                        }
                    }
                    return Just(true).setFailureType(to: CommitRevealError.self).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        return verifier(retries)
    }

    // swiftlint:disable function_parameter_count
    func reveal(wallet: WalletData,
                index: Int,
                eotp: [UInt8],
                neighbors: [MerkleTree.TreeNode],
                operationType: Int,
                tokenType: Int,
                contractAddress: EthereumAddress? = nil,
                tokenId: BigUInt,
                dest: EthereumAddress,
                amount: BigUInt,
                data: String = "0x") -> AnyPublisher<APIResponse, CommitRevealError> {
        let emptyAddress = "0x0000000000000000000000000000000000000000"
        let req: [String: Any] = [
            "address": wallet.address.address,
            "index": index,
            "eotp": "0x" + eotp.toHexString(),
            "neighbors": neighbors.map { "0x" + $0.toHexString() },
            "operationType": operationType,
            "tokenType": tokenType,
            "contractAddress": contractAddress?.address ?? emptyAddress,
            "tokenId": String(tokenId), // one-wallet code uses hex string for this during sign operation, that seems redundant?
            "dest": dest.address,
            "amount": String(amount),
            "data": data
        ]
        return self.call(type: .reveal, params: req)
            .unwrapResultJSONFromAPI()
            .map { $0.data }
            .decodeFromJson(APIResponse.self)
            .tryMap { res in
                if res.success ?? false {
                    return res
                } else {
                    throw CommitRevealError.revealError
                }
            }
            .mapError {
                if $0.code == HTTPStatusCode.noInternetConnection.rawValue {
                    return .noInternet
                } else {
                    return $0 as? CommitRevealError ?? .unknownError
                }
            }
            .eraseToAnyPublisher()
    }

    // @deprecated
    func revealTransfer(wallet: WalletData,
                        destination: EthereumAddress,
                        amount: BigUInt,
                        commitData: CommitData) -> AnyPublisher<APIResponse, CommitRevealError> {
        return reveal(wallet: wallet,
                      index: commitData.index,
                      eotp: commitData.eotp,
                      neighbors: commitData.neighbors,
                      operationType: 4, // TRANSFER
                      tokenType: TokenType.none.id, // NONE
                      tokenId: 0, dest: destination, amount: amount)
    }

    func commitReveal(wallet: WalletData,
                      commitData: CommitData,
                      operationType: Int,
                      tokenType: Int,
                      contractAddress: EthereumAddress? = nil,
                      tokenId: BigUInt,
                      dest: EthereumAddress,
                      amount: BigUInt,
                      data: String = "0x") -> AnyPublisher<CommitRevealProgress, CommitRevealError> {
        return Just<CommitRevealProgress>(.committing)
            .setFailureType(to: CommitRevealError.self)
            .append(commit(wallet: wallet, commitData: commitData)
                        .map { _ in CommitRevealProgress.verifyingCommit })
            .append(verifyCommit(wallet: wallet, data: commitData, retries: 4, delay: 4)
                        .map { _ in CommitRevealProgress.pendingReveal })
            .append(
                Just<CommitRevealProgress>(.revealing)
                    .flatMap { progress -> AnyPublisher<CommitRevealProgress, Never> in
                        //let effectiveTimeIndex = Int(floor(wallet.effectiveTime.timeIntervalSince1970 / 30))
                        //let nextIndex = commitData.index + 1
                        //let revealTime = Date(timeIntervalSince1970: TimeInterval((effectiveTimeIndex + nextIndex) * 30))
                        //let delay = revealTime.timeIntervalSinceNow
                        // Let's add a minimum 0.5 second delay here for better UI transition
                        return Just(progress)
                            .delay(for: .seconds(0), scheduler: self.subscriptionQueue)
                            .eraseToAnyPublisher()
                    }
                    .setFailureType(to: CommitRevealError.self))
            .append(reveal(wallet: wallet,
                           index: commitData.index,
                           eotp: commitData.eotp,
                           neighbors: commitData.neighbors,
                           operationType: operationType,
                           tokenType: tokenType,
                           contractAddress: contractAddress,
                           tokenId: tokenId,
                           dest: dest,
                           amount: amount,
                           data: data)
                        .map { res in CommitRevealProgress.done(txId: res.txId) })
            .eraseToAnyPublisher()
    }

    func calculateEotp(wallet: WalletData, otpIndex: Int, index: Int) -> [UInt8]? {
        var eotp: [UInt8]?
        if let eotpCached = Tables.EOTP.fetchEOTP(mTreeRootHex: wallet.merkleTree.rootHex, index: index) {
            if let encryptKeyData = KeyChain.shared.encryptKey,
               let encryptedEOTPData = eotpCached.encryptedEOTP.base64Decoded?.bytes,
               let sealedBox = try? ChaChaPoly.SealedBox(combined: encryptedEOTPData) {
                eotp = (try? ChaChaPoly.open(sealedBox,
                                             using: SymmetricKey(data: encryptKeyData)))?.bytes
            }
        }
        if eotp == nil,
           let seed = WalletInfo.shared.allWallets.first(where: { $0.address == wallet.address.address })?.seed {
            let otp = TOTP(secret: seed).generateCode(counter: UInt64(otpIndex))
            let leaf = wallet.merkleTree.layers[0][index]
            let hseed = Array(seed.fastSHA256().prefix(22))
            var eotp: [UInt8]
            // 18 bits of randomness
            for i in 0...1 << 18 {
                eotp = CryptoHelper.shared.generateEotp(otp: otp, hseed: hseed, rand: UInt32(i))
                let eotpHash = eotp.fastSHA256()
                if eotpHash == leaf {
                    return eotp
                }
            }
        }
        return eotp
    }

    func calculateCommitHash(neighbor: MerkleTree.TreeNode, index: Int, eotp: [UInt8]) -> [UInt8] {
        // 96 bytes input
        // 32 bytes: neighbor
        // 4 bytes: index
        // 32 bytes -- starting from 64th index: eotp
        var indexBigEndian = UInt32(index).bigEndian

        var input: [UInt8] = []
        input += neighbor
        input += indexBigEndian.byteArray()
        input += [UInt8](repeating: 0, count: 28) // fill up next 28 bytes from 36 -> 63
        input += eotp

        return input.sha3(.keccak256)
    }

    func calculateVerificationHash(paramsHash: [UInt8], eotp: [UInt8]) -> [UInt8] {
        // 64 bytes input
        // 32 bytes: paramsHash
        // 32 bytes: eotp
        let input: [UInt8] = paramsHash + eotp
        return input.sha3(.keccak256)
    }

    func calculateTransferParamsHash(dest: EthereumAddress, amount: BigUInt) -> [UInt8] {
        // 64 bytes input
        // 20 bytes: destination address
        // 12 bytes: empty
        // 32 bytes: amount - big endian
        let destBytes = dest.addressData.bytes
        var input: [UInt8] = []
        input += destBytes
        input += [UInt8](repeating: 0, count: 12)
        input += numberToBytes(amount, length: 32)
        return input.sha3(.keccak256)
    }

    func calculateGeneralParamsHash(operationType: Int,
                                    tokenType: Int,
                                    contractAddress: EthereumAddress,
                                    tokenId: BigUInt,
                                    dest: EthereumAddress,
                                    amount: BigUInt,
                                    data: [UInt8]) -> [UInt8] {
        // 192 bytes + data length
        //   bytes32(uint256(operationType)),
        //   bytes32(uint256(tokenType)),
        //   bytes32(bytes20(contractAddress)),
        //   bytes32(tokenId),
        //   bytes32(bytes20(dest)),
        //   bytes32(amount),
        //   data
        var input: [UInt8] = []
        input += numberToBytes(BigUInt(operationType), length: 32)
        input += numberToBytes(BigUInt(tokenType), length: 32)
        input += contractAddress.addressData.bytes + [UInt8](repeating: 0, count: 12)
        input += numberToBytes(tokenId, length: 32)
        input += dest.addressData.bytes + [UInt8](repeating: 0, count: 12)
        input += numberToBytes(amount, length: 32)
        input += data
        return input.sha3(.keccak256)
    }

    func numberToBytes(_ num: BigUInt, length: Int) -> [UInt8] {
        let output = num.serialize().bytes // in big endian
        if output.count < length {
            return [UInt8](repeating: 0, count: length - output.count) + output
        }
        return output
    }

    func getTxStatus(_ txID: String, walletAddress: String, isOneTransfer: Bool = false) -> AnyPublisher<TransactionReceipt.TXStatus, Error> {
        guard let oneWalletContract = EthereumContract(
            Web3Service.shared.oneWalletAbi,
            at: EthereumAddress(walletAddress.convertBech32ToEthereum())) else {
                return Fail(error: CommitRevealError.web3Error).eraseToAnyPublisher()
        }

        var receiptFetching: ((Int) -> AnyPublisher<TransactionReceipt.TXStatus, Error>)!
        receiptFetching = { [weak self] retriesLeft in
            guard let self = self else {
                return Fail(error: CommitRevealError.web3Error).eraseToAnyPublisher()
            }
            return Deferred {
                Web3Service.shared.web3Instance.eth.getTransactionReceiptPromise(txID)
                    .publisher
                    .map { receipt -> TransactionReceipt.TXStatus in
                        guard isOneTransfer && receipt.status == .ok else {
                            return receipt.status
                        }
                        guard let receiptLogs = receipt.logs.first else {
                            return TransactionReceipt.TXStatus.failed
                        }
                        let (eventName, _) = oneWalletContract.parseEvent(receiptLogs)
                        if eventName == "PaymentSent" {
                            return TransactionReceipt.TXStatus.ok
                        } else {
                            return TransactionReceipt.TXStatus.failed
                        }
                    }
                    .catch { _ -> AnyPublisher<TransactionReceipt.TXStatus, Error> in
                        // Replace error by .notYetProcessed status for retry handler down below
                        return Just(.notYetProcessed).setFailureType(to: Error.self).eraseToAnyPublisher()
                    }
                    .flatMap { result -> AnyPublisher<TransactionReceipt.TXStatus, Error> in
                        if result == .notYetProcessed && retriesLeft > 0 {
                            return Just(())
                                .delay(for: .seconds(0.5), scheduler: self.subscriptionQueue)
                                .flatMap { _ in receiptFetching(retriesLeft - 1) }
                                .eraseToAnyPublisher()
                        } else {
                            return Just(result).setFailureType(to: Error.self).eraseToAnyPublisher()
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }
        return receiptFetching(9)
    }
}


// MARK: - enums
extension OneWalletService {
    struct WalletData {
        let address: EthereumAddress
        let merkleTree: MerkleTree
        let effectiveTime: Date
    }

    struct WalletPublicInfo {
        // root, height, interval, t0, lifespan, maxOperationsPerInterval, lastResortAddress, -- dailyLimit
        let root: [UInt8]
        let height: Int
        let interval: Int
        let t0: Int
        let lifespan: Int
        let maxOperationsPerInterval: Int
        let lastResortAddress: EthereumAddress
    }

    struct CommitData {
        let index: Int
        let eotp: [UInt8]
        let neighbors: [MerkleTree.TreeNode]
        let hash: [UInt8]
        let paramsHash: [UInt8]
        let verificationHash: [UInt8]
    }

    struct APIResponse: Codable {
        let success: Bool?
        let error: String?
        let txId: String?
    }

    enum CommitRevealProgress {
        case none
        case committing
        case verifyingCommit
        case pendingReveal
        case revealing
        case done(txId: String?)
    }

    enum NewWalletError: Error {
        case couldNotGenerateSeed
        case couldNotGenerateWalletPayload
        case missingWalletPayload
        case missingWalletAddress
        case apiBorked
    }

    enum GeneralError: Error {
        case web3Error
    }

    enum CommitRevealError: Error {
        case commitNotConfirmed
        case corruptedTimestamp
        case commitAlreadyCompleted
        case web3Error
        case revealError
        case unknownError
        case noInternet
        case transactionFail
    }

    enum TokenType {
        case erc20
        case erc721
        case erc1155
        case none // ONE token

        var id: Int {
            switch self {
            case .erc20:
                return 0
            case .erc721:
                return 1
            case .erc1155:
                return 2
            case .none:
                return 3
            }
        }
    }

    enum RequestType: EndPointType {
        case newWallet
        case commit
        case reveal

        // MARK: Vars & Lets
        var baseURL: String {
            return AppConstant.oneWalletServiceUrl
        }

        var path: String {
            switch self {
            case .newWallet:
                return "new"
            case .commit:
                return "commit"
            case .reveal:
                return "reveal"
            }
        }

        var httpMethod: HTTPMethod {
            switch self {
            case .newWallet, .commit, .reveal:
                return .post
            }
        }

        var headers: [String: String] {
            return NetworkHelper.httpCryptoHeader
        }
    }
}
