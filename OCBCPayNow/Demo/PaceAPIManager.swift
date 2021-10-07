//
//  PaceAPIManager.swift
//  PaceNowBank
//
//  Created by sathyabaman on 29/9/21.
//

import UIKit


//Api request
public class DemoPaceAPIManager {
    //Mark:- Properties
    public var baseURL: String
    public var isDebug: Bool
    public var location: String
    
    let service = DemoPaceServiceManager()
    
    public init(){
        baseURL = "https://staging-consumer-api.pacenow.co"
        isDebug = true
        location = "SG"
    }
    
    //Mark:- Endpoints
    public func system_ping(completion: @escaping (SystemInfo?, Error?) -> Void) {
        service.getRequest(url: "\(baseURL)\(EndPoint.ping.url)") { result, error in
            if let error = error {
                PacePrint.shared.printIdDebug("Unable to Submit : \(error)")
                completion(nil, error)
            }
             
             do {
                 let json = try JSONDecoder().decode(SystemInfo.self, from: result!)
                 PacePrint.shared.printIdDebug("sytem type: \(json.type)")
                 completion(json, nil)
             } catch {
                 PacePrint.shared.printIdDebug("decode failure")
             }
        }
    }
    
    
    public func system_healthCheck(completion: @escaping (SystemInfo?, Error?) -> Void) {
        service.getRequest(url: "\(baseURL)\(EndPoint.health.url)") { result, error in
            if let error = error {
                PacePrint.shared.printIdDebug("Health Check failed : \(error)")
                completion(nil, error)
            }
             
             do {
                 let json = try JSONDecoder().decode(SystemInfo.self, from: result!)
                 PacePrint.shared.printIdDebug("sytem type: \(json.type)")
                 completion(json, nil)
             } catch {
                 PacePrint.shared.printIdDebug("decode failure")
             }
        }
    }
    
    public func auth_requestOTP(phoneNumber: String, completion: @escaping (String?, Error?) -> Void) {
        
        let userInfo = UserInfo(phoneNumber: phoneNumber, locationId: location)
        guard let jsonData = try? JSONEncoder().encode(userInfo) else {  return }
        
        service.submitPost(url: "\(baseURL)\(EndPoint.requestOtp.url)", data: jsonData) { result, error in
           if let error = error {
               PacePrint.shared.printIdDebug("Unable to request OTP : \(error)")
               completion(nil, error)
               return
           }
            
            do {
                let json = try JSONDecoder().decode(UserInfo.self, from: result!)
                completion(json.requestToken, nil)
                return
            } catch {
                completion(nil, error)
            }
        }
    }
    
    
    
    public func auth_confirmOTP(phoneNumber: String, otp: String, token requestToken: String? = "", completion: @escaping (UserInfo?, Error?) -> Void) {
        
        let headers: HeaderValues = [ "X_PACE_DEVICEID": "Stimulator" ]
        
        let userInfo = UserInfo(phoneNumber: phoneNumber, locationId: location, otp: otp, requestToken: requestToken)
        guard let jsonData = try? JSONEncoder().encode(userInfo) else {  return }
        
        service.submitPost(url: "\(baseURL)\(EndPoint.confirmOtp.url)", data: jsonData, headers: headers) { result, error in
            if let error = error {
                PacePrint.shared.printIdDebug("Unable to confirm OTP : \(error)")
                completion(nil, error)
                return
            }
            
            do {
                let json = try JSONDecoder().decode(UserInfo.self, from: result!)
                PacePrint.shared.printIdDebug("onboardingToken: \(json.onboardingToken ?? "")")
                PacePrint.shared.printIdDebug("authToken: \(json.authToken ?? "")")
                PacePrint.shared.printIdDebug("onboardingStatus: \(json.onboardingStatus ?? "")")
                
                completion(json, nil)
                return
            } catch {
                completion(nil, error)
            }
        }
    }
    
    
    public func kyc_requestEmailOtp(email: String, phoneNumber: String, onboardingToken: String, completion: @escaping (UserInfo?, Error?) -> Void) {
        let headers: HeaderValues = [ "X_PACE_DEVICEID": "Stimulator" ]
        
        let requestInfo = UserInfo(phoneNumber: phoneNumber, locationId: location, onboardingToken: onboardingToken, email: email, toVerify: true)
        guard let requestBodyData = try? JSONEncoder().encode(requestInfo) else {  return }
        
        service.submitPost(url: "\(baseURL)\(EndPoint.requestEmailOtp.url)", data: requestBodyData, headers: headers) { result, error in
            if let error = error {
                PacePrint.shared.printIdDebug("Unable to request email confirm OTP : \(error)")
                completion(nil, error)
                return
            }
            
            do {
                let json = try JSONDecoder().decode(UserInfo.self, from: result!)
                PacePrint.shared.printIdDebug("email request Token: \(json.requestToken ?? "")")
                completion(json, nil)
                return
            } catch {
                completion(nil, error)
            }
        }
    }
    
    
    public func kyc_confirmEmailOtp(email: String, phoneNumber: String, onboardingToken: String, otp: String, requestToken: String, completion: @escaping (UserInfo?, Error?) -> Void) {
        let headers: HeaderValues = [ "X_PACE_DEVICEID": "Stimulator" ]

        let requestInfo = UserInfo(phoneNumber: phoneNumber, locationId: location, otp: otp, requestToken: requestToken, onboardingToken: onboardingToken, email: email, toVerify: true, referralCode: "")
        guard let requestBodyData = try? JSONEncoder().encode(requestInfo) else {  return }

        service.submitPost(url: "\(baseURL)\(EndPoint.confirmEmailOtp.url)", data: requestBodyData, headers: headers) { result, error in
            if let error = error {
                PacePrint.shared.printIdDebug("Unable to confirm email OTP Submit : \(error)")
                completion(nil, error)
                return
            }

            do {
                let json = try JSONDecoder().decode(UserInfo.self, from: result!)
                PacePrint.shared.printIdDebug("email request Token: \(json.requestToken ?? "")")
                completion(json, nil)
                return
            } catch {
                completion(nil, error)
            }
        }
    }
    
    
    
    public func kyc_getVerificationURL(onboardingToken: String, completion: @escaping (UserInfo?, Error?) -> Void){
        let sgMyInforURL = "?onboardingToken=\(onboardingToken)&type=myinfo&locationId=SG&countryIsoCode=SGP&redirectUrl=https:%2F%2Fassets.pacenow.co%2Fr.html&referrer=*&applicantionId=co.pacenow.app.staging"
        
        service.getRequest(url: "\(baseURL)\(EndPoint.getVerificationUrl.url)\(sgMyInforURL)") { result, error in
            if let error = error {
                PacePrint.shared.printIdDebug("Unable to getURL for verification : \(error)")
                completion(nil, error)
            }
             
             do {
                 let json = try JSONDecoder().decode(UserInfo.self, from: result!)
                 PacePrint.shared.printIdDebug("link: \(json.link ?? "")")
                 PacePrint.shared.printIdDebug("state: \(json.state ?? "")")
                 PacePrint.shared.printIdDebug("redirect URL: \(json.redirect_url ?? "")")
                 completion(json, nil)
             } catch {
                 PacePrint.shared.printIdDebug("decode failure")
             }
        }
    }
    
    public func kyc_getVerificationResult(onboardingToken: String, completion: @escaping (Welcome?, Error?) -> Void){
        let sgMyInforVerificationURL = "?locationId=SG&countryIsoCode=SGP&onboardingToken=\(onboardingToken)"
        service.getRequest(url: "\(baseURL)\(EndPoint.getVerificationResult.url)\(sgMyInforVerificationURL)") { result, error in
            if let error = error {
                PacePrint.shared.printIdDebug("Unable to get user deatils for verification : \(error)")
                completion(nil, error)
            }
            
            do {
                let json = try JSONDecoder().decode(Welcome.self, from: result!)
                PacePrint.shared.printIdDebug("idService: \(json.idService )")
                PacePrint.shared.printIdDebug("onboardingStatus: \(json.onboardingStatus )")
                PacePrint.shared.printIdDebug("data: \(json.data)")
                completion(json, nil)
            } catch {
                PacePrint.shared.printIdDebug("decode failure")
            }
        }
    }
    
    public func account_getAccountDetails(completion: @escaping (AccountResponse?, Error?) -> Void){
        
        service.getRequest(url: "\(baseURL)\(EndPoint.account.url)") { result, error in
            if let error = error {
                PacePrint.shared.printIdDebug("Unable to get account details: \(error)")
                completion(nil, error)
            }
             
             do {
                 let json = try JSONDecoder().decode(AccountResponse.self, from: result!)
                 PacePrint.shared.printIdDebug("id: \(json.user?.id ?? "")")
                 PacePrint.shared.printIdDebug("firstName: \(json.user?.firstName ?? "")")
                 PacePrint.shared.printIdDebug("lastName: \(json.user?.lastName ?? "")")
                 PacePrint.shared.printIdDebug("email: \(json.user?.email ?? "")")
                 PacePrint.shared.printIdDebug("emailVerifiedAt: \(json.user?.emailVerifiedAt ?? "")")
                 PacePrint.shared.printIdDebug("emailVerifiedAtUTC: \(json.user?.emailVerifiedAtUTC ?? "")")
                 PacePrint.shared.printIdDebug("phoneVerifiedAt: \(json.user?.phoneVerifiedAt ?? "")")
                 PacePrint.shared.printIdDebug("phoneVerifiedAtUTC: \(json.user?.phoneVerifiedAtUTC ?? "")")
                 PacePrint.shared.printIdDebug("nricFin: \(json.user?.nricFin ?? "")")
                 PacePrint.shared.printIdDebug("nationality: \(json.user?.nationality ?? "")")
                 PacePrint.shared.printIdDebug("dateOfBirth: \(json.user?.dateOfBirth ?? "")")
                 PacePrint.shared.printIdDebug("mobileNumber: \(json.user?.mobileNumber ?? "")")
                 PacePrint.shared.printIdDebug("countryCode: \(json.user?.countryCode ?? "")")
                 PacePrint.shared.printIdDebug("creditLimitString: \(json.user?.creditLimitString ?? "")")
                 PacePrint.shared.printIdDebug("isRestricted: \(json.user?.isRestricted ?? false)")
                 PacePrint.shared.printIdDebug("onboardingReference: \(json.user?.onboardingReference ?? "")")
                 PacePrint.shared.printIdDebug("onboardingStatus: \(json.user?.onboardingStatus ?? "")")
                 PacePrint.shared.printIdDebug("debitLimitString: \(json.user?.debitLimitString ?? "")")
                 completion(json, nil)
             } catch {
                 PacePrint.shared.printIdDebug("decode failure")
             }
        }
    }
    
    
    public func account_setProcessApplication(usersPersonalData: NSMutableDictionary, completion: @escaping (UserInfo?, Error?) -> Void){
        
        let headers: HeaderValues = [ "X_PACE_DEVICEID": "Stimulator" ]

        guard let requestBodyData = try? JSONSerialization.data(withJSONObject: usersPersonalData, options: [JSONSerialization.WritingOptions.sortedKeys,JSONSerialization.WritingOptions.prettyPrinted]) else { return}

        service.submitPost(url: "\(baseURL)\(EndPoint.setProcessApplication.url)", data: requestBodyData, headers: headers) { result, error in
            if let error = error {
                PacePrint.shared.printIdDebug("Unable to submit process Application : \(error)")
                completion(nil, error)
                return
            }

            do {
                let json = try JSONDecoder().decode(UserInfo.self, from: result!)
                completion(json, nil)
                return
            } catch {
                completion(nil, error)
            }
        }
    }
    
    
    
}
