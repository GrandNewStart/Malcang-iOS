import Foundation
import Alamofire

struct APIManager {
    
    private let BASE_URL = "https://www.malcang.com"
    typealias CompletionHandler = (_ data: String?, _ error: String?)->Void
    
    static func getFCMToken(completionHandler: @escaping CompletionHandler) {
        guard let jwt = AppStorage.jwt else {
            completionHandler(nil, "no access token")
            return
        }
        var url = URLComponents()
        url.scheme = "https"
        url.host = "www.malcang.com"
        url.path = "/v1/fcm/getToken"
        AF.request(
            url,
            method: .get,
            encoding: JSONEncoding.default,
            headers: ["token": jwt]
        ).response { response in
            switch response.result {
            case .success(let response):
                do {
                    if let data = response,
                       let dict = try JSONSerialization.jsonObject(with: data) as? Dictionary<String,Any>,
                       let code = dict["code"] as? String {
                        if code == "1" {
                            if let fcmToken = dict["fcm_token"] as? String {
                                print("(DEBUG) APIManager.getFCMToken: \(fcmToken)")
                                completionHandler(fcmToken, nil)
                                return
                            }
                        }
                    }
                    print("(ERROR) APIManager.getFCMToken: unknown error")
                    completionHandler(nil, "unknown error")
                } catch {
                    print("(ERROR) APIManager.getFCMToken: \(error.localizedDescription)")
                    completionHandler(nil, error.localizedDescription)
                }
            case .failure(let error):
                print("(ERROR) APIManager.getFCMToken: \(error.localizedDescription)")
                completionHandler(nil, error.localizedDescription)
            }
        }
    }
    
    static func setFCMToken(fcmToken: String, completionHandler: @escaping CompletionHandler) {
        guard let jwt = AppStorage.jwt else {
            completionHandler(nil, "no access token")
            return
        }
        var url = URLComponents()
        url.scheme = "https"
        url.host = "www.malcang.com"
        url.path = "/v1/fcm/saveToken"
        let body = [
            "fcm_token": fcmToken,
            "device_id": AppStorage.deviceId
        ]
        AF.request(
            url,
            method: .post,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: ["token": jwt]
        ).response { response in
            switch response.result {
            case .success(let response):
                do {
                    if let data = response,
                       let dict = try JSONSerialization.jsonObject(with: data) as? Dictionary<String,Any>,
                       let code = dict["code"] as? String {
                        if code == "1" {
                            print("(DEBUG) APIManager.setFCMToken: success")
                            completionHandler(nil, nil)
                            return
                        }
                    }
                    print("(ERROR) APIManager.setFCMToken: unknown error")
                    completionHandler(nil, "unknown error")
                } catch {
                    print("(ERROR) APIManager.setFCMToken: \(error.localizedDescription)")
                    completionHandler(nil, error.localizedDescription)
                }
            case .failure(let error):
                print("(ERROR) APIManager.setFCMToken: \(error.localizedDescription)")
                completionHandler(nil, error.localizedDescription)
            }
        }
    }
    
    static func updateFCMToken(fcmToken: String, completionHandler: @escaping CompletionHandler) {
        guard let jwt = AppStorage.jwt else {
            completionHandler(nil, "no access token")
            return
        }
        var url = URLComponents()
        url.scheme = "https"
        url.host = "www.malcang.com"
        url.path = "/v1/fcm/refreshToken"
        let body = [
            "fcm_token": fcmToken,
            "device_id": AppStorage.deviceId
        ]
        AF.request(
            url,
            method: .put,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: ["token": jwt]
        ).response { response in
            switch response.result {
            case .success(let response):
                do {
                    if let data = response,
                       let dict = try JSONSerialization.jsonObject(with: data) as? Dictionary<String,Any>,
                       let code = dict["code"] as? String {
                        if code == "1" {
                            print("(DEBUG) APIManager.updateFCMToken: success")
                            completionHandler(nil, nil)
                            return
                        }
                    }
                    print("(ERROR) APIManager.updateFCMToken: unknown error")
                    completionHandler(nil, "unknown error")
                } catch {
                    print("(ERROR) APIManager.updateFCMToken: \(error.localizedDescription)")
                    completionHandler(nil, error.localizedDescription)
                }
            case .failure(let error):
                print("(ERROR) APIManager.updateFCMToken: \(error.localizedDescription)")
                completionHandler(nil, error.localizedDescription)
            }
        }
    }
    
    static func deleteFCMToken(fcmToken: String, completionHandler: @escaping CompletionHandler) {
        guard let jwt = AppStorage.jwt else {
            completionHandler(nil, "no access token")
            return
        }
        var url = URLComponents()
        url.scheme = "https"
        url.host = "www.malcang.com"
        url.path = "/v1/fcm/refreshToken"
        let body = [
            "device_id": AppStorage.deviceId
        ]
        AF.request(
            url,
            method: .put,
            parameters: body,
            encoding: JSONEncoding.default,
            headers: ["token": jwt]
        ).response { response in
            switch response.result {
            case .success(let response):
                do {
                    if let data = response,
                       let dict = try JSONSerialization.jsonObject(with: data) as? Dictionary<String,Any>,
                       let code = dict["code"] as? String {
                        if code == "1" {
                            print("(DEBUG) APIManager.deleteFCMToken: success")
                            completionHandler(nil, nil)
                            return
                        }
                    }
                    print("(ERROR) APIManager.updateFCMToken: unknown error")
                    completionHandler(nil, "unknown error")
                } catch {
                    print("(ERROR) APIManager.updateFCMToken: \(error.localizedDescription)")
                    completionHandler(nil, error.localizedDescription)
                }
            case .failure(let error):
                print("(ERROR) APIManager.updateFCMToken: \(error.localizedDescription)")
                completionHandler(nil, error.localizedDescription)
            }
        }
    }
    
    
}
