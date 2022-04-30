//
//  Web3Service.swift
//  Timeless-wallet
//
//  Created by Vinh Dang on 10/28/21.
//

import Foundation
import Combine
import web3swift
import BigInt

class Web3Service: Web3ServiceProtocol {

    static let shared = Web3Service(HarmonyNetwork.mainNet)

    let network: RPCNetwork
    let web3Instance: web3

    init(_ network: RPCNetwork) {
        let web3Network = Networks.Custom(networkID: network.networkID)
        let httpProvider = Web3HttpProvider(network.rpcUrl, network: web3Network)!

        self.network = network
        self.web3Instance = web3(provider: httpProvider)
        self.web3Instance.transactionOptions = defaultTransactionOptions
    }

    func getBalance(at address: EthereumAddress) throws -> BigUInt {
        return try web3Instance.eth.getBalance(address: address) // in wei unit
    }

    func getErc20TokenBalance(for token: Erc20Token,
                              at address: EthereumAddress) throws -> BigUInt {
        // swiftlint:disable identifier_name
        guard let contract = erc20Contract(at: token.contractAddress),
              let tx = contract.read("balanceOf", parameters: [address] as [AnyObject]),
              let result = try? tx.call(transactionOptions: self.defaultTransactionOptions),
              let balance = result["0"] as? BigUInt else {
                  throw Web3Error.invalidContract
              }
        return balance
    }

    func getBalance(at address: EthereumAddress) -> AnyPublisher<BigUInt, Error> {
        return web3Instance.eth.getBalancePromise(address: address) // in wei unit
            .publisher
    }

    func getErc20TokenBalance(for token: Erc20Token,
                              at address: EthereumAddress) -> AnyPublisher<BigUInt, Error> {
        // swiftlint:disable identifier_name
        guard let contract = erc20Contract(at: token.contractAddress),
              let tx = contract.read("balanceOf", parameters: [address] as [AnyObject]) else {
                  return Fail(error: Web3Error.invalidContract).eraseToAnyPublisher()
              }
        return tx.callPromise(transactionOptions: self.defaultTransactionOptions)
            .publisher
            .tryMap { result in
                guard let balance = result["0"] as? BigUInt else {
                    throw Web3Error.invalidContract
                }
                return balance
            }
            .eraseToAnyPublisher()
    }

    func decimalAmountFromWeiUnit(amount: BigUInt, weiUnit: Int) -> Decimal {
        let amountDict = amount.quotientAndRemainder(dividingBy: BigUInt(weiUnit))
        return (Decimal(string: String(amountDict.quotient))!
                + Decimal(string: String(amountDict.remainder))! / Decimal(weiUnit))
    }

    func amountFromWeiUnit(amount: BigUInt, weiUnit: Int) -> Double {
        // rounding down to 10 decimal digits to avoid rounding issue
        var decimalAmount = decimalAmountFromWeiUnit(amount: amount, weiUnit: weiUnit)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &decimalAmount, 10, .down)
        return NSDecimalNumber(decimal: rounded).doubleValue
    }

    func amountToWeiUnit(amount: Double, weiUnit: Int) -> BigUInt {
        // TODO: use web3swift formatter to handle this
        //  Ref: https://github.com/skywinder/web3swift/issues/294
        return BigUInt(amount * Double(weiUnit))
    }

    func getTokenAllowance(for token: Web3Service.Erc20Token,
                           at wallet: EthereumAddress,
                           spender: EthereumAddress) -> AnyPublisher<BigUInt, Error> {
        // swiftlint:disable identifier_name
        guard let contract = erc20Contract(at: token.contractAddress),
              let tx = contract.read("allowance", parameters: [wallet, spender] as [AnyObject]) else {
                  return Fail(error: Web3Error.invalidContract).eraseToAnyPublisher()
              }
        return tx.callPromise(transactionOptions: self.defaultTransactionOptions)
          .publisher
          .tryMap { result in
              guard let balance = result["0"] as? BigUInt else {
                  throw Web3Error.invalidContract
              }
              return balance
          }
          .eraseToAnyPublisher()
    }
}

// MARK: Enums
extension Web3Service {
    enum Erc20Token: String, CaseIterable {
        case ETH
        case WBTC
        case USDC
        case BUSD
        case USDT
        case bscBUSD
        case SUSHI
        case DAI
        case AAVE
        case bscUSDT

        var weiUnit: Int {
            switch self {
            case .USDC, .USDT:
                return 1_000_000 // 10^6
            case .WBTC:
                return 100_000_000 // 10^8
            default:
                return 1_000_000_000_000_000_000 // 10^18
            }
        }

        var isStableCoin: Bool {
            switch self {
            case .USDC, .BUSD, .USDT, .bscBUSD, .DAI, .bscUSDT:
                return true
            default:
                return false
            }
        }

        var symbol: String {
            rawValue
        }

        var trackedSymbol: String {
            switch self {
            case .WBTC:
                return "BTC"
            default:
                return symbol
            }
        }

        var wrappedSymbol: String {
            switch self {
            case .ETH, .WBTC, .USDC, .USDT, .SUSHI, .DAI, .AAVE:
                return "1" + symbol
            default:
                return symbol
            }
        }

        var name: String {
            switch self {
            case .ETH:
                return "Ethereum ETH"
            case .WBTC:
                return "Wrapped BTC"
            case .USDC:
                return "USD Coin"
            case .BUSD:
                return "Binance USD"
            case .USDT:
                return "Tether USD"
            case .bscBUSD:
                return "BUSD Token"
            case .SUSHI:
                return "SushiToken"
            case .DAI:
                return "Dai Stablecoin"
            case .AAVE:
                return "Aave Token"
            case .bscUSDT:
                return "Binance USDT"
            }
        }

        var contractAddress: EthereumAddress {
            var addr: String
            switch self {
            case .ETH:
                addr = "0x6983D1E6DEf3690C4d616b13597A09e6193EA013"
            case .WBTC:
                addr = "0x3095c7557bCb296ccc6e363DE01b760bA031F2d9"
            case .USDC:
                addr = "0x985458E523dB3d53125813eD68c274899e9DfAb4"
            case .BUSD:
                addr = "0xE176EBE47d621b984a73036B9DA5d834411ef734"
            case .USDT:
                addr = "0x3C2B8Be99c50593081EAA2A724F0B8285F5aba8f"
            case .bscBUSD:
                addr = "0x0aB43550A6915F9f67d0c454C2E90385E6497EaA"
            case .SUSHI:
                addr = "0xBEC775Cb42AbFa4288dE81F387a9b1A3c4Bc552A"
            case .DAI:
                addr = "0xEf977d2f931C1978Db5F6747666fa1eACB0d0339"
            case .AAVE:
                addr = "0xcF323Aad9E522B93F11c352CaA519Ad0E14eB40F"
            case .bscUSDT:
                addr = "0x9a89d0e1b051640c6704dde4df881f73adfef39a"
            }
            return EthereumAddress(addr)!
        }
    }

    enum Web3Error: Error {
        case invalidContract
    }
}

// MARK: Contract ABIs
extension Web3Service {
    func getAbiFromFile(fileName: String) -> String {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json"),
              let content = try? String(contentsOfFile: path) else {
            return "[]"
        }
        return content
    }

    var oneWalletAbi: String {
        return getAbiFromFile(fileName: "IONEWallet")
    }

    var erc20Abi: String {
        return getAbiFromFile(fileName: "IERC20")
    }

    var sushiSwapAbi: String {
        return getAbiFromFile(fileName: "IUniswapV2Router02")
    }

    var gnosisSafeAbi: String {
        return getAbiFromFile(fileName: "GnosisSafe")
    }

    var gnosisSafeProxyFactoryAbi: String {
        return getAbiFromFile(fileName: "GnosisSafeProxyFactory")
    }

    var giftPacketAbi: String {
        return getAbiFromFile(fileName: "OneWalletGiftPacket")
    }
}

// MARK: Helpers
extension Web3Service {
    func oneWalletContract(at address: EthereumAddress) -> web3.web3contract? {
        return web3Instance.contract(oneWalletAbi, at: address, abiVersion: 2)
    }

    func erc20Contract(at address: EthereumAddress) -> web3.web3contract? {
        return web3Instance.contract(erc20Abi, at: address, abiVersion: 2)
    }

    func erc721Contract(at address: EthereumAddress) -> web3.web3contract? {
        return web3Instance.contract(Web3.Utils.erc721ABI, at: address, abiVersion: 2)
    }
    
    func giftPacketContract(at address: EthereumAddress) -> web3.web3contract? {
        return web3Instance.contract(giftPacketAbi, at: address, abiVersion: 2)
    }

    func erc1155Contract(at address: EthereumAddress) -> web3.web3contract? {
        // TODO: Supply full contract abi
        // swiftlint:disable line_length
        let contractAbi = "[{\"constant\":true,\"inputs\":[{\"name\":\"_tokenId\",\"type\":\"uint256\"}],\"name\":\"uri\",\"outputs\":[{\"name\":\"\",\"type\":\"string\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
        return web3Instance.contract(contractAbi, at: address, abiVersion: 2)
    }

    var sushiSwapRouterAddress: EthereumAddress {
        return EthereumAddress("0x1b02da8cb0d097eb8d57a175b88c7d8b47997506")!
    }

    var sushiSwapContract: web3.web3contract? {
        return web3Instance.contract(sushiSwapAbi, at: sushiSwapRouterAddress, abiVersion: 2)
    }

    var defaultTransactionOptions: TransactionOptions {
        var options = TransactionOptions.defaultOptions
        options.callOnBlock = .latest
        return options
    }
}
