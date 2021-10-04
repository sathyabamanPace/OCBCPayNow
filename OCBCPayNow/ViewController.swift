//
//  ViewController.swift
//  OCBCPayNow
//
//  Created by admin on 1/10/21.
//

import UIKit
import PaceNowBank

class ViewController: UIViewController {
    
    let paceAPi = PaceAPIManager()
    let paceOTPView = PaceOTPView()
    let storeView = PacePayNowView()
    
    var email = "yenih10554@ergowiki.com"
    var phone = "+6580000098"
    var requestToken: String = ""
    var onboardingToken: String = ""
    
    let confirmButton: UIButton = {
       let btn = UIButton()
        btn.backgroundColor = .purple
        btn.setTitle("Confirm Email OTP", for: .normal)
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(confirmEmailOtp), for: .touchUpInside)
        return btn
    }()
    
    let urlVerificationButton: UIButton = {
       let btn = UIButton()
        btn.backgroundColor = .brown
        btn.setTitle("Get Verification URL", for: .normal)
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(TempGetVerificationURL), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(storeView)
        storeView.delegate = self
        storeView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 150)
        
        view.addSubview(paceOTPView)
        paceOTPView.anchor(top: storeView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16,  height: 50)
        
        view.addSubview(confirmButton)
        confirmButton.anchor(top: paceOTPView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16,  height: 50)
        
        view.addSubview(urlVerificationButton)
        urlVerificationButton.anchor(top: confirmButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16,  height: 50)
        
        
        ping()
        healthCheck()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func ping(){
        paceAPi.system_ping(completion: { result, error in
            if let error = error {
                print("DEBUG: trying to ping failed: \(error)")
            }
            
            print("DEBUG: message : \(result?.attributes?.message ?? "")")
            print("DEBUG: time : \(result?.attributes?.time ?? "")")
        })
    }
    
    func healthCheck() {
        paceAPi.system_healthCheck(completion: { result, error in
            if let error = error {
                print("DEBUG: trying to ping failed: \(error)")
            }
            
            print("DEBUG: build_no : \(result?.attributes?.build_no ?? "")")
            print("DEBUG: environment : \(result?.attributes?.environment ?? "")")
            print("DEBUG: message : \(result?.attributes?.message ?? "")")
            print("DEBUG: namespace : \(result?.attributes?.namespace ?? "")")
            print("DEBUG: service : \(result?.attributes?.service ?? "")")
            print("DEBUG: sha1 : \(result?.attributes?.sha1 ?? "")")
            print("DEBUG: time : \(result?.attributes?.time ?? "")")
            print("DEBUG: version : \(result?.attributes?.version ?? "")")
        })
    }
    
    
    func callRequestPhoneOTP(){
        paceAPi.auth_requestOTP(phoneNumber: phone, completion: { token, error in
            if let error = error {
                print("DEBUG: failed to get Token: \(error)")
            }
            print("DEBUG: request Token : \(token ?? "")")
            self.requestToken = token ?? ""
            
            self.callConfirmOTP(token: token ?? "")
        })
    }

    func callConfirmOTP(token: String){
        paceAPi.auth_confirmOTP(phoneNumber: phone, otp: "555555", token: token, completion: {result, error in
            if let error = error {
                print("failed to confirm otp: \(error)")
            }
            print("DEBUG: onboardingStatus : \(result?.onboardingStatus ?? "")")
            print("DEBUG: onboardingToken : \(result?.onboardingToken ?? "")")
            print("DEBUG: authToken : \(result?.authToken ?? "")")
            self.onboardingToken = result?.onboardingToken ?? ""
            self.requestEmailOtp()
        })
    }
    
    func requestEmailOtp(){
        paceAPi.kyc_requestEmailOtp(email: email, phoneNumber: phone, onboardingToken: onboardingToken, completion: {result, error in
            if let error = error {
                print("DEBUG: failed to confirm otp: \(error)")
            }
            print("DEBUG: request Token : \(result?.requestToken ?? "")")
            self.requestToken = result?.requestToken ?? ""
        })
    }
    
    
    //MARK:- Actions
    @objc func confirmEmailOtp(){
        paceAPi.kyc_confirmEmailOtp(email: email, phoneNumber: phone, onboardingToken: onboardingToken, otp: paceOTPView.getOTPText(), requestToken: requestToken, completion: {result, error in
            if let error = error {
                print("DEBUG: failed to confirm otp: \(error)")
            }
            print("DEBUG: Email verified : \(result?.success ?? false)")
        })
    }
    
    
    @objc func TempGetVerificationURL(){
        getVerificationURL()
    }
    
    func getVerificationURL(){
        paceAPi.kyc_getVerificationURL(onboardingToken: onboardingToken, completion: {
            result, error in
                if let error = error {
                    print("DEBUG: failed to confirm otp: \(error)")
                }
                print("DEBUG: myInfo Link: \(result?.link ?? "")")
                print("DEBUG: state: \(result?.state ?? "")")
                print("DEBUG: redirectURL: \(result?.redirect_url ?? "")")
        })
    }
    
    
}

extension ViewController: PacePayNowViewDelegate {
    func doPayNow() {
        self.callRequestPhoneOTP()
        
    }
}
