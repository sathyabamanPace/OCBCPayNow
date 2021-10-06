//
//  RequestModel.swift
//  PaceNowBank
//
//  Created by sathyabaman on 29/9/21.
//

import Foundation


//endpoint enumerator
enum EndPoint: String, CaseIterable {
    
    case requestOtp
    case confirmOtp
    case requestEmailOtp
    case confirmEmailOtp
    case getVerificationUrl
    case getVerificationResult
    case callbacksMyinfo
    case setProcessApplication
    case health
    case ping
    case account
    
    var url: String {
        switch self {
            case .requestOtp: return "/v1/api/requestOtp"
            case .confirmOtp: return "/v1/api/confirmOtp"
            case .requestEmailOtp: return "/v2/api/userInfo"
            case .confirmEmailOtp: return "/v2/api/userInfo"
            case .getVerificationUrl: return "/v2/api/getVerificationUrl"
            case .getVerificationResult: return "/v2/api/getVerificationResult"
            case .callbacksMyinfo: return "/v2/api/getVerificationResult?"
            case .setProcessApplication: return "/v2/api/setProcessApplication"
            case .health: return "/health"
            case .ping: return "/ping"
            case .account: return "/v1/api/account"
        }
    }
}

// User registration response

public struct UserInfo: Codable {
    public let phoneNumber: String?
    public let locationId: String?
    public var otp: String?
    public var requestToken: String?
    public var authToken: String?
    public var onboardingToken: String?
    public var onboardingStatus: String?
    public var email: String?
    public var toVerify: Bool?
    public var referralCode: String?
    public var success:Bool?
    public var link: String?
    public var state: String?
    public var redirect_url: String?
    
}

struct customError: Codable  {
    var code : String?
    var message: String?
}

struct paceError: Codable {
    var correlation_id: String?
    var error: customError?
}



// ping syste mresponse

public struct SystemInfo: Codable {
    public let type: String
    public let attributes: SystemAttributes?
}

public struct SystemAttributes: Codable {
    public var build_no : String?
    public var environment: String?
    public var message : String?
    public var namespace: String?
    public var service : String?
    public var sha1: String?
    public var time : String?
    public var version: String?
}



// MARK: - Welcome
public struct Welcome: Codable {
    public let data: [Datum]
    public let onboardingStatus, idService: String
}

// MARK: - Datum
public struct Datum: Codable {
    public let key: String
    public let value: ValueUnion
}

public enum ValueUnion: Codable {
    case string(String)
    case valueElementArray([ValueElement])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([ValueElement].self) {
            self = .valueElementArray(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(ValueUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ValueUnion"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .valueElementArray(let x):
            try container.encode(x)
        }
    }
}

// MARK: - ValueElement
public struct ValueElement: Codable {
    let key, value: String
}





//Account Response
public struct AccountResponse: Codable {
    public let user: AccountUser?
    public let toggleFlag: AccountVirtualCard?
}

public struct AccountUser: Codable {
    public var id : String?
    public var firstName : String?
    public var lastName : String?
    public var email : String?
    public var emailVerifiedAt : String?
    public var emailVerifiedAtUTC : String?
    public var phoneVerifiedAt : String?
    public var phoneVerifiedAtUTC : String?
    public var nricFin : String?
    public var nationality : String?
    public var dateOfBirth : String?
    public var mobileNumber : String?
    public var countryCode : String?
    public var creditLimitString : String?
    public var isRestricted : Bool?
    public var onboardingReference : String?
    public var onboardingStatus : String?
    public var debitLimitString : String?
}

public struct AccountVirtualCard: Codable {
    public var shownHomepage : String?
    public var hasVirtualCard : String?
    public var isVirtualCardUser : String?
    public var compliance : String?
}




class PacePrint {
    static let shared = PacePrint()
    
    private init(){}
    
    func printIdDebug(_ message: String) {
        print("Debug: \(message)")
    }
}
