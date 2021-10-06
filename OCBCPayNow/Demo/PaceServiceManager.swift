//
//  PaceServiceManager.swift
//  PaceNowBank
//
//  Created by sathyabaman on 29/9/21.
//

import Foundation


typealias HeaderValues = [String: String]?
typealias PostCompletionHandler = (Data?, Error?) -> Void
var sessionId: String = ""
var clientToken: String = ""


public class DemoPaceServiceManager {
    

    func submitPost(url: String, data: Data, headers: HeaderValues = nil, completion: @escaping PostCompletionHandler) {
    
        guard let getURL = URL(string: url) else { return }
        var urlRequest = URLRequest(url: getURL)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue(sessionId, forHTTPHeaderField: "x-pace-sessionid")
        urlRequest.addValue("consumerapp", forHTTPHeaderField: "x-pace-clientid")
        urlRequest.addValue("co.pacenow.PaceNowBank", forHTTPHeaderField: "x-pace-appid")
        urlRequest.addValue("SG", forHTTPHeaderField: "x-pace-location-id")
        urlRequest.addValue(clientToken, forHTTPHeaderField: "x-pace-clienttoken")

        //Add More headers from parameters
        if let headers = headers{
            for item in headers {
                urlRequest.addValue(item.value, forHTTPHeaderField: item.key)
            }
        }
        
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data
    
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("DEBUG: get request failed with error : \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            let response2 = response as? HTTPURLResponse
            print("---------------------------------------------------------------")
            print("DEBUG:  Request URL: \(url)")
            print("DEBUG:  Status code: \(response2?.statusCode ?? 0 )")
            
            
            guard let response = response as? HTTPURLResponse, [403, 422, 400, 200].contains(response.statusCode) else {
                print("DEBUG: Oops!! there is server error!")
                completion(nil, error)
                return
            }
            
            if let session = response.allHeaderFields["x-pace-sessionid"] as? String {
                sessionId = session
                print("DEBUG:  SessionID: \(sessionId)")
            }
            
            
            if let cToken = response.allHeaderFields["x-pace-clienttoken"] as? String, cToken.count > 3 {
                print("DEBUG: Client Token: \(cToken)")
                clientToken = cToken
            }
            
            if [403, 422].contains(response.statusCode) {
                do {
                    let errorResponse = try JSONDecoder().decode(paceError.self, from: data!)
                    print("DEBUG: CorrelationID: \(errorResponse.correlation_id ?? "" )")
                    print("DEBUG: Error Code: \(errorResponse.error?.code ?? "" )")
                    print("DEBUG: Error Message: \(errorResponse.error?.message ?? "" )")
                }catch {
                    print("DEBUG: Oops! Something wrong with the request")
                }
            }

            guard let data = data, error == nil  else { return }
            completion(data, nil)
        }
        task.resume()
    }
    
    
    
    

    func getRequest(url: String, completion: @escaping PostCompletionHandler) {
        guard let getURL = URL(string: url) else { return }
        var request = URLRequest(url: getURL)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(sessionId, forHTTPHeaderField: "x-pace-sessionid")
        request.addValue("consumerapp", forHTTPHeaderField: "x-pace-clientid")
        request.addValue("co.pacenow.app.staging-co.pacenow.app.staging", forHTTPHeaderField: "x-pace-appid")
        request.addValue("SG", forHTTPHeaderField: "x-pace-location-id")
        request.addValue("0e636fba-f3c2-4c1a-8f1a-a053d67d82d9", forHTTPHeaderField: "x-pace-deviceid")
        request.addValue("en-SG", forHTTPHeaderField: "x-pace-locale")
        request.addValue("{}", forHTTPHeaderField: "x-pace-metadata")
        request.addValue(clientToken, forHTTPHeaderField: "x-pace-clienttoken")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
    
            if let error = error {
                print("DEBUG: get request failed with error : \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            let response2 = response as? HTTPURLResponse
            print("---------------------------------------------------------------")
            print("DEBUG:  Request URL: \(url)")
            print("DEBUG:  Status code: \(response2?.statusCode ?? 0 )")
            print("DEBUG:  SessionID: \(sessionId)")
            
            guard let response = response as? HTTPURLResponse, [403, 422, 400, 405, 200].contains(response.statusCode) else {
                print("DEBUG: Oops!! there is server error!")
                completion(nil, error)
                return
            }
    

            if [403, 405, 422].contains(response.statusCode) {
                do {
                    let errorResponse = try JSONDecoder().decode(paceError.self, from: data!)
                    print("DEBUG: CorrelationID: \(errorResponse.correlation_id ?? "" )")
                    print("DEBUG: Error Code: \(errorResponse.error?.code ?? "" )")
                    print("DEBUG: Error Message: \(errorResponse.error?.message ?? "" )")
                }catch {
                    print("DEBUG: Oops! Something wrong with the request")
                }
            }
            
            guard let data = data, error == nil  else { return }
            completion(data, nil)
            
        }
        task.resume()
    }
    
    
//    func getRequest<T: Codable> (model: T, url: String, completion: @escaping ([T]) -> Void) {
//        guard let getURL = URL(string: url) else { return }
//
//        let task = URLSession.shared.dataTask(with: getURL) { (data, response, error) in
//
//            if let error = error {
//                print("DEBUG: get request failed with error : \(error.localizedDescription)")
//                return
//            }
//
//            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
//                print("DEBUG: Oops!! there is server error!")
//                return
//            }
//
//            guard let data = data, error == nil  else { return }
//
//            do {
//                let jsonData = try JSONDecoder().decode([T].self, from: data)
//                completion(jsonData)
//            } catch {
//                print("DEBUG: Json Decode failure")
//            }
//        }
//        task.resume()
//    }
    
}
