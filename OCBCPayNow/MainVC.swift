//
//  MainVC.swift
//  OCBCPayNow
//
//  Created by admin on 1/10/21.
//

import UIKit
import PaceNowBank

class MainVC: UIViewController {
    
    let paceAPi = DemoPaceAPIManager()
    
    let paceOTPView = PaceOTPView()
    let storeView = PacePayNowView()
    
    var email = "fimoye8384@ofenbuy.com"
    var phone = "+6580001015"
    var requestToken: String = ""
    var onboardingToken: String = ""
    var myInfoURL: String = ""
    
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
    
    lazy var myInfoButton: UIButton = {
       let btn = UIButton()
        btn.backgroundColor = .red
        btn.setTitle("Open Myinfo ", for: .normal)
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(openMyinfo), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemGray5
        view.addSubview(storeView)
        storeView.delegate = self
        storeView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 150)
        
        view.addSubview(paceOTPView)
        paceOTPView.anchor(top: storeView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16,  height: 50)
        
        view.addSubview(confirmButton)
        confirmButton.anchor(top: paceOTPView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16,  height: 50)
        
        view.addSubview(urlVerificationButton)
        urlVerificationButton.anchor(top: confirmButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16,  height: 50)
        
      //  checkDecodeMockData()
        
//        ping()
//        healthCheck()
        

        var pairs = [GenericDatapairs]()
        let pair1 = GenericDatapairs(key: "gind", value: "bugger")
        let pair2 = GenericDatapairs(key: "nirock", value: "deunk")
        let pair3 = GenericDatapairs(key: "sathya", value: "nice guy")
        let pair4 = GenericDatapairs(key: "anjali", value: "biit")

        pairs.append(pair1)
        pairs.append(pair2)
        pairs.append(pair3)
        pairs.append(pair4)
        setProcessApplication(userdata: pairs)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func loadMyInfoButton(){
        DispatchQueue.main.async { [self] in
            view.addSubview(myInfoButton)
            myInfoButton.anchor(top: urlVerificationButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16,  height: 50)
        }
    }
    
//    func checkDecodeMockData(){
//        let data = getDataFromJsonFile(name: "verificationResults")
//        do {
//            let dictonary =  try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
//            if let results = dictonary {
//                for item in results["data"] as! [AnyObject]  {
//                    if item["key"] as! String == "address" {
//                        for address in item["value"] as! [AnyObject] {
//                            print("\(address["key"]) : \(address["value"])")
//                        }
//                    } else {
//                        print("\(item["key"]) : \(item["value"])")
//                    }
//                }
//                print(" onboardingStatus: \(results["onboardingStatus"]!)")
//                print(" idService: \(results["idService"]!)")
//            }
//        } catch let error as NSError {
//            print(error)
//        }
//    }
    
    func getDataFromJsonFile(name: String, withExtension: String = "json") -> Data {
        let bundle = Bundle(for: type(of: self))
        let fileUrl = bundle.url(forResource: name, withExtension: withExtension)
        let data = try! Data(contentsOf: fileUrl!)
        return data
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
            self.loadMyInfoButton()
        })
    }
    
    @objc func openMyinfo(){
        let vc = SingPassVC(url: myInfoURL)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func TempGetVerificationURL(){
        getVerificationURL()
    }
    
    func getVerificationURL(){
        paceAPi.kyc_getVerificationURL(onboardingToken: onboardingToken, completion: {
            result, error in
                if let error = error {
                    print("DEBUG: failed to getVerificationURL: \(error)")
                }
            
            self.myInfoURL = result?.link ?? ""
        })
    }
    
    func getAccountDetails(){
        paceAPi.account_getAccountDetails(completion: {
            result, error in
            if let error = error {
                print("DEBUG: failed to account_getAccountDetails: \(error)")
            }
            
         //   print("result: \(result)")
            
        })
    }
    
    func getMyInfoVerificationResults(){
        paceAPi.kyc_getVerificationResult(onboardingToken: onboardingToken, completion: {
            result, error in
            if let error = error {
                print("DEBUG: failed to getMyInfoVerificationResults: \(error)")
                return
            }
            
            print("onboardingStatus: \(result?.onboardingStatus ?? "")")
            print("idService: \(result?.idService ?? "")")
            guard let userData = result?.data else { return }
            for item in userData {
                print("\(item.key ?? "") : \(item.value ?? "")")
            }
        
            self.getAccountDetails()
            self.setProcessApplication(userdata: userData)
        })
    }
    
    func setProcessApplication(userdata: [GenericDatapairs]){
       
        
//        let value: [String] = userdata.flatMap({ $0.key})
//        print(value)
        
        var userInfo =  [[String: String]]()
        for info in userdata {
            let data: [String: String] = [info.key ?? "" : info.value ?? ""]

        }
        
        var json_string : String = ""
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(userdata) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        }
        
 
        
        paceAPi.account_setProcessApplication(usersPersonalData: userInfo, completion: {
            result, error in
            
            if let error = error {
                print("DEBUG: failed to setProcessApplication: \(error)")
                return
            }
            
            print("Application Status: \(result?.success ?? false)")
            
          //  self.getAccountDetails()
        })
    }
    
}

extension MainVC: PacePayNowViewDelegate {
    func doPayNow() {
        self.callRequestPhoneOTP()
    }
}


extension MainVC: SingPassDelegate {
    func loadMyInforequestResutApi() { [self]
        getAccountDetails()
        getMyInfoVerificationResults()
    }
}
