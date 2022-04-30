//
//  String.swift
//  Timeless-wallet
//
//  Created by Phu Tran on 29/10/2021.
//

import Foundation
import web3swift
import SwiftUI

extension String {
    public var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var isAlphabet: Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    // For example: https://www.youtube.com/watch?v=0we7kcmgDOw
    // youtubeID = 0we7kcmgDOw
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)
        guard let result = regex?.firstMatch(in: self, range: range) else {
            return nil
        }
        return (self as NSString).substring(with: result.range)
    }

    var isYoutubeVideo: Bool {
        guard let url = URL(string: self) else { return false }
        return url.host?.hasSuffix("youtu.be") ?? false || url.host?.hasSuffix("youtube.com") ?? false
    }

    var isVideo: Bool {
        let mediaType = self.isYoutubeVideo ? "youtube" : self.split(separator: ".").last ?? ""
        let videoTypes = Constants.DataType.videos
        return videoTypes.contains(String(mediaType))
    }

    var isValidEmail: Bool {
        let name = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,320}[A-Z0-9a-z])?"
        let domain = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let emailRegEx = name + "@" + domain + "[A-Za-z]{2,8}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }

    func containsLowercasedString(_ string: String) -> Bool {
        return self.lowercased().contains(string.lowercased())
    }

    var isOneWalletAddress: Bool {
        let pattern = "^one1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{38}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: count)
        if regex?.firstMatch(in: self, range: range) != nil {
            return true
        }

        let pattern0x = "^0x[0-9a-fA-F]{40}$"
        let regex0x = try? NSRegularExpression(pattern: pattern0x)
        let range0x = NSRange(location: 0, length: count)
        if regex0x?.firstMatch(in: self, range: range0x) != nil {
            return true
        }

        return false
    }

    func trimStringByCount(count: Int) -> String {
        let newString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if self.count > count * 2 {
            let prefix = String(newString.prefix(count))
            let suffix = String(newString.suffix(count))
            return "\(prefix)...\(suffix)"
        }
        return self
    }

    func trimStringByFirstLastCount(firstCount: Int, lastCount: Int) -> String {
        let newString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if self.count > firstCount * 2 {
            let prefix = String(newString.prefix(firstCount))
            let suffix = String(newString.suffix(lastCount))
            return "\(prefix)...\(suffix)"
        }
        return self
    }

    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    func toCrazyOne() -> String? {
        return self
// Todo
//        return self.isBlank ? nil : self.appending(".crazy.one")
    }

    func convertBech32ToEthereum() -> String {
        if self.prefix(2) != "0x" {
            let bech32 = Bech32()
            do {
                let decoded = try bech32.decode(self)
                let decodedData = try bech32.convertBits(from: 5, to: 8, pad: false, idata: decoded.checksum)
                if let result = EthereumAddress(decodedData) {
                    return result.address
                }
            } catch {
                print("error", error)
            }
        }
        return self
    }

    func convertEthereumToBech32() -> String {
        if self.prefix(2) == "0x" {
            let bech32 = Bech32()
            do {
                if let ethAddr = EthereumAddress(self) {
                    let data = try bech32.convertBits(from: 8, to: 5, pad: false, idata: ethAddr.addressData)
                    return bech32.encode("one", values: data)
                }
            } catch {
                print("error", error)
            }
        }
        return self
    }

    func openWalletExplorer() {
        if let address = EthereumAddress(self.convertBech32ToEthereum()) {
            if let explorer = URL(string: "\(Constants.harmony.baseWalletAddress)\(address.address)") {
                if UIApplication.shared.canOpenURL(explorer) {
                    UIApplication.shared.open(explorer)
                }
            }
        }
    }

    func replace(string: String, replacement: String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }

    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
}

// MARK: - Wallet formatter 
extension String {
    var isHexFormat: Bool {
        @AppStorage(ASSettings.Settings.hexFormat.key)
        var hexFormat = ASSettings.Settings.hexFormat.defaultValue
        return hexFormat
    }

    func convertToWalletAddress() -> String {
        if isHexFormat {
            return self.convertBech32ToEthereum()
        } else {
            return self.convertEthereumToBech32()
        }
    }
}

extension CharacterSet {
    /// Characters valid in at least one part of a URL.
    ///
    /// These characters are not allowed in ALL parts of a URL; each part has different requirements. This set is useful for checking for Unicode characters that need to be percent encoded before performing a validity check on individual URL components.
    static var urlAllowedCharacters: CharacterSet {
        // Start by including hash, which isn't in any set
        var characters = CharacterSet(charactersIn: "#")
        // All URL-legal characters
        characters.formUnion(.urlUserAllowed)
        characters.formUnion(.urlPasswordAllowed)
        characters.formUnion(.urlHostAllowed)
        characters.formUnion(.urlPathAllowed)
        characters.formUnion(.urlQueryAllowed)
        characters.formUnion(.urlFragmentAllowed)
        return characters
    }
}

extension String {
    /// Converts a string to a percent-encoded URL, including Unicode characters.
    ///
    /// - Returns: An encoded URL if all steps succeed, otherwise nil.
    func encodedUrl() -> URL? {
        // Remove preexisting encoding,
        guard let decodedString = self.removingPercentEncoding,
              // encode any Unicode characters so URLComponents doesn't choke,
              let unicodeEncodedString = decodedString.addingPercentEncoding(withAllowedCharacters: .urlAllowedCharacters),
              // break into components to use proper encoding for each part,
              let components = URLComponents(string: unicodeEncodedString),
              // and reencode, to revert decoding while encoding missed characters.
              let percentEncodedUrl = components.url else {
            // Encoding failed
            return nil
        }
        return percentEncodedUrl
    }

    /// Returns a new string made by replacing in the `String`
    /// all HTML character entity references with the corresponding
    /// character.
    var stringByDecodingHTMLEntities: String {

        // ===== Utility functions =====

        // Convert the number in the string to the corresponding
        // Unicode character, e.g.
        //    decodeNumeric("64", 10)   --> "@"
        //    decodeNumeric("20ac", 16) --> "€"
        func decodeNumeric(_ string: Substring, base : Int) -> Character? {
            guard let code = UInt32(string, radix: base),
                let uniScalar = UnicodeScalar(code) else { return nil }
            return Character(uniScalar)
        }

        // Decode the HTML character entity to the corresponding
        // Unicode character, return `nil` for invalid input.
        //     decode("&#64;")    --> "@"
        //     decode("&#x20ac;") --> "€"
        //     decode("&lt;")     --> "<"
        //     decode("&foo;")    --> nil
        func decode(_ entity: Substring) -> Character? {

            if entity.hasPrefix("&#x") || entity.hasPrefix("&#X") {
                return decodeNumeric(entity.dropFirst(3).dropLast(), base: 16)
            } else if entity.hasPrefix("&#") {
                return decodeNumeric(entity.dropFirst(2).dropLast(), base: 10)
            } else {
                return characterEntities[entity]
            }
        }

        // ===== Method starts here =====

        var result = ""
        var position = startIndex

        // Find the next '&' and copy the characters preceding it to `result`:
        while let ampRange = self[position...].range(of: "&") {
            result.append(contentsOf: self[position ..< ampRange.lowerBound])
            position = ampRange.lowerBound

            // Find the next ';' and copy everything from '&' to ';' into `entity`
            guard let semiRange = self[position...].range(of: ";") else {
                // No matching ';'.
                break
            }
            let entity = self[position ..< semiRange.upperBound]
            position = semiRange.upperBound

            if let decoded = decode(entity) {
                // Replace by decoded character:
                result.append(decoded)
            } else {
                // Invalid entity, copy verbatim:
                result.append(contentsOf: entity)
            }
        }
        // Copy remaining characters to `result`:
        result.append(contentsOf: self[position...])
        return result
    }
}

// Mapping from XML/HTML character entity reference to character
// From http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
private let characterEntities: [ Substring : Character ] = [
    // XML predefined entities:
    "&quot;"    : "\"",
    "&amp;"     : "&",
    "&apos;"    : "'",
    "&lt;"      : "<",
    "&gt;"      : ">",

    // HTML character entity references:
    "&nbsp;"    : "\u{00a0}",
    // ...
    "&diams;"   : "♦",
]

extension Optional where Wrapped == String {
    func verifyUrl() -> Bool {
        if let urlString = self {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
}
